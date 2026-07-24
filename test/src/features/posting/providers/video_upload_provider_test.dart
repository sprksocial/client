import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/repo_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sound_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/story_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/posting/providers/video_upload_provider.dart';
import 'package:sprk_poptart/so/sprk/sound/defs/audio_details.dart';

void main() {
  late _FakeFeedRepository feedRepository;
  late _FakeRepoRepository repoRepository;
  late _FakeSoundRepository soundRepository;
  late _FakeStoryRepository storyRepository;
  late _FakeSprkRepository sprkRepository;

  setUp(() async {
    await GetIt.I.reset();
    feedRepository = _FakeFeedRepository();
    repoRepository = _FakeRepoRepository();
    soundRepository = _FakeSoundRepository();
    storyRepository = _FakeStoryRepository();
    sprkRepository = _FakeSprkRepository(
      feedRepository: feedRepository,
      repoRepository: repoRepository,
      soundRepository: soundRepository,
    );
    GetIt.I
      ..registerSingleton<LogService>(LogService())
      ..registerSingleton<SprkRepository>(sprkRepository)
      ..registerSingleton<StoryRepository>(storyRepository);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test(
    'processVideo delegates the source path and returns upload data',
    () async {
      final upload = VideoUploadResult(videoBlob: _blob('video/mp4'));
      feedRepository.uploadResult = upload;

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        processVideoProvider('/videos/source.mp4').future,
      );

      expect(result, same(upload));
      expect(feedRepository.uploadPaths, ['/videos/source.mp4']);
    },
  );

  test(
    'story posting creates extracted sound and forwards story metadata',
    () async {
      final createdSound = _strongRef('so.sprk.sound.audio', 'sound-1');
      soundRepository.createdSound = createdSound;
      final embed = StoryEmbed(
        placement: const StoryEmbedPlacement(
          frame: StoryEmbedFrame(x: 100, y: 200, w: 300, h: 400),
          zIndex: 1,
        ),
        did: 'did:plc:mentioned',
      );
      final upload = VideoUploadResult(
        videoBlob: _blob('video/mp4'),
        audioBlob: _blob('audio/mpeg'),
      );

      final result = await postProcessedVideo(
        uploadResult: upload,
        storyMode: true,
        storyEmbeds: [embed],
      );

      expect(result, storyRepository.result);
      expect(soundRepository.createdBlobs, [upload.audioBlob]);
      expect(storyRepository.soundRef, createdSound);
      expect(storyRepository.embeds, [embed]);
      expect(storyRepository.media, isA<MediaVideo>());
      expect((storyRepository.media! as MediaVideo).video, upload.videoBlob);
      expect(repoRepository.createCalls, isEmpty);
    },
  );

  test('story posting continues when extracted sound creation fails', () async {
    soundRepository.createError = StateError('sound unavailable');
    final upload = VideoUploadResult(
      videoBlob: _blob('video/mp4'),
      audioBlob: _blob('audio/mpeg'),
    );

    final result = await postProcessedVideo(
      uploadResult: upload,
      storyMode: true,
    );

    expect(result, storyRepository.result);
    expect(storyRepository.soundRef, isNull);
  });

  test('feed posting writes the expected Spark record', () async {
    final sound = _strongRef('so.sprk.sound.audio', 'selected-sound');
    final upload = VideoUploadResult(videoBlob: _blob('video/mp4'));

    final result = await postProcessedVideo(
      uploadResult: upload,
      description: 'hello spark',
      altText: 'a short clip',
      aspectRatio: const MediaAspectRatio(width: 9, height: 16),
      soundRef: sound,
    );

    expect(result, repoRepository.sparkResult);
    expect(repoRepository.createCalls, hasLength(1));
    final call = repoRepository.createCalls.single;
    expect(call.collection, 'so.sprk.feed.post');
    expect(call.record['caption']['text'], 'hello spark');
    expect(call.record['media']['alt'], 'a short clip');
    expect(call.record['media']['aspectRatio'], {
      r'$type': 'so.sprk.media.defs#aspectRatio',
      'width': 9,
      'height': 16,
    });
    expect(call.record['sound'], sound.toJson());
    expect(repoRepository.editCalls, isEmpty);
  });

  test(
    'successful crosspost edits the Spark record with its reference',
    () async {
      final upload = VideoUploadResult(videoBlob: _blob('video/mp4'));

      final result = await postProcessedVideo(
        uploadResult: upload,
        description: 'crosspost me',
        crosspostToBsky: true,
      );

      expect(result, repoRepository.editedResult);
      expect(repoRepository.createCalls.map((call) => call.collection), [
        'so.sprk.feed.post',
        'app.bsky.feed.post',
      ]);
      expect(repoRepository.createCalls.last.rkey, 'spark-rkey');
      expect(repoRepository.editCalls, hasLength(1));
      expect(
        repoRepository.editCalls.single.uri,
        repoRepository.sparkResult.uri,
      );
      final crossposts =
          repoRepository.editCalls.single.record['crossposts'] as List<dynamic>;
      expect(crossposts, [repoRepository.bskyResult.toJson()]);
    },
  );

  test('failed crosspost preserves the original Spark post', () async {
    repoRepository.failBskyCreate = true;
    final upload = VideoUploadResult(videoBlob: _blob('video/mp4'));

    final result = await postProcessedVideo(
      uploadResult: upload,
      crosspostToBsky: true,
    );

    expect(result, repoRepository.sparkResult);
    expect(repoRepository.editCalls, isEmpty);
  });
}

Blob _blob(String mimeType) => Blob.fromJson({
  r'$type': 'blob',
  'mimeType': mimeType,
  'size': 42,
  'ref': {r'$link': 'bafkreigh2akiscaildc2'},
});

RepoStrongRef _strongRef(String collection, String rkey) => RepoStrongRef(
  uri: AtUri.parse('at://did:plc:test/$collection/$rkey'),
  cid: 'cid-$rkey',
);

class _FakeFeedRepository implements FeedRepository {
  VideoUploadResult? uploadResult;
  final List<String> uploadPaths = [];

  @override
  Future<VideoUploadResult> uploadVideo(
    String videoPath, {
    void Function(double progress)? onUploadProgress,
  }) async {
    uploadPaths.add(videoPath);
    return uploadResult!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSoundRepository implements SoundRepository {
  RepoStrongRef createdSound = _strongRef('so.sprk.sound.audio', 'created');
  Object? createError;
  final List<Blob> createdBlobs = [];

  @override
  Future<RepoStrongRef> createSound({
    required Blob sound,
    String? title,
    AudioDetails? details,
  }) async {
    createdBlobs.add(sound);
    if (createError case final error?) throw error;
    return createdSound;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStoryRepository implements StoryRepository {
  final RepoStrongRef result = _strongRef('so.sprk.story.post', 'story-1');
  Media? media;
  RepoStrongRef? soundRef;
  List<StoryEmbed>? embeds;

  @override
  Future<RepoStrongRef> postStory(
    Media media, {
    List<SelfLabel>? selfLabels,
    List<String>? tags,
    RepoStrongRef? soundRef,
    List<StoryEmbed>? embeds,
  }) async {
    this.media = media;
    this.soundRef = soundRef;
    this.embeds = embeds;
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRepoRepository implements RepoRepository {
  final RepoStrongRef sparkResult = _strongRef(
    'so.sprk.feed.post',
    'spark-rkey',
  );
  final RepoStrongRef bskyResult = _strongRef(
    'app.bsky.feed.post',
    'spark-rkey',
  );
  final RepoStrongRef editedResult = _strongRef(
    'so.sprk.feed.post',
    'spark-rkey-edited',
  );
  bool failBskyCreate = false;
  final List<_CreateCall> createCalls = [];
  final List<_EditCall> editCalls = [];

  @override
  Future<RepoStrongRef> createRecord({
    required String collection,
    required Map<String, dynamic> record,
    String? rkey,
    String? repo,
  }) async {
    createCalls.add(
      _CreateCall(collection: collection, record: record, rkey: rkey),
    );
    if (collection == 'app.bsky.feed.post') {
      if (failBskyCreate) throw StateError('bsky unavailable');
      return bskyResult;
    }
    return sparkResult;
  }

  @override
  Future<RepoStrongRef> editRecordJson({
    required AtUri uri,
    required Map<String, dynamic> record,
  }) async {
    editCalls.add(_EditCall(uri: uri, record: record));
    return editedResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSprkRepository implements SprkRepository {
  _FakeSprkRepository({
    required this.feedRepository,
    required this.repoRepository,
    required this.soundRepository,
  });

  final FeedRepository feedRepository;
  final RepoRepository repoRepository;
  final SoundRepository soundRepository;
  final AuthRepository auth = _FakeAuthRepository();

  @override
  FeedRepository get feed => feedRepository;

  @override
  RepoRepository get repo => repoRepository;

  @override
  SoundRepository get sound => soundRepository;

  @override
  AuthRepository get authRepository => auth;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  @override
  String? get did => 'did:plc:test';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CreateCall {
  const _CreateCall({
    required this.collection,
    required this.record,
    required this.rkey,
  });

  final String collection;
  final Map<String, dynamic> record;
  final String? rkey;
}

class _EditCall {
  const _EditCall({required this.uri, required this.record});

  final AtUri uri;
  final Map<String, dynamic> record;
}
