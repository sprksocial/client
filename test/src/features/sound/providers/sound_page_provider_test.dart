import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sound_repository.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/sound/providers/sound_page_provider.dart';
import 'package:spark/src/features/sound/providers/sound_page_state.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

void main() {
  final uri = AtUri('at://did:plc:author/so.sprk.sound.audio/sound');
  late _FakeSoundRepository repository;

  ProviderContainer createContainer() {
    final container = ProviderContainer.test(
      retry: (retryCount, error) => null,
      overrides: [
        soundPageRepositoryProvider.overrideWithValue(repository),
        soundPageLoggerProvider.overrideWithValue(SparkLogger()),
      ],
    );
    final subscription = container.listen(
      soundPageProvider(uri),
      (previous, next) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    addTearDown(container.dispose);
    return container;
  }

  setUp(() => repository = _FakeSoundRepository());

  test('initial load stores audio, posts, cursor, and fetch limit', () async {
    final audio = _audio();
    final post = _post('first');
    repository.responses.add(
      () async =>
          AudioPostsResponse(audio: audio, posts: [post], cursor: 'next'),
    );
    final container = createContainer();

    final state = await container.read(soundPageProvider(uri).future);

    expect(state.audio, audio);
    expect(state.posts, [post]);
    expect(state.cursor, 'next');
    expect(state.isEndOfNetwork, isFalse);
    expect(repository.calls.single.limit, SoundPageState.fetchLimit);
    expect(repository.calls.single.cursor, isNull);
  });

  test('initial load fails when the response omits audio', () async {
    repository.responses.add(() async => const AudioPostsResponse(posts: []));
    final container = createContainer();

    await expectLater(
      container.read(soundPageProvider(uri).future),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Audio not returned'),
        ),
      ),
    );
  });

  test('loadMore appends posts and marks the final page', () async {
    final audio = _audio();
    repository.responses
      ..add(
        () async => AudioPostsResponse(
          audio: audio,
          posts: [_post('first')],
          cursor: 'next',
        ),
      )
      ..add(() async => AudioPostsResponse(posts: [_post('second')]));
    final container = createContainer();
    await container.read(soundPageProvider(uri).future);

    await container.read(soundPageProvider(uri).notifier).loadMore();

    final state = container.read(soundPageProvider(uri)).requireValue;
    expect(state.posts.map((post) => post.cid), ['cid-first', 'cid-second']);
    expect(state.isEndOfNetwork, isTrue);
    expect(repository.calls.last.cursor, 'next');
  });

  test('concurrent loadMore calls coalesce into one request', () async {
    final nextPage = Completer<AudioPostsResponse>();
    repository.responses
      ..add(
        () async => AudioPostsResponse(
          audio: _audio(),
          posts: [_post('first')],
          cursor: 'next',
        ),
      )
      ..add(() => nextPage.future);
    final container = createContainer();
    await container.read(soundPageProvider(uri).future);

    final first = container.read(soundPageProvider(uri).notifier).loadMore();
    final second = container.read(soundPageProvider(uri).notifier).loadMore();
    expect(repository.calls, hasLength(2));
    nextPage.complete(const AudioPostsResponse(posts: []));
    await Future.wait([first, second]);
  });

  test('pagination failure preserves the current page', () async {
    final first = _post('first');
    repository.responses
      ..add(
        () async =>
            AudioPostsResponse(audio: _audio(), posts: [first], cursor: 'next'),
      )
      ..add(() async => throw StateError('offline'));
    final container = createContainer();
    await container.read(soundPageProvider(uri).future);

    await container.read(soundPageProvider(uri).notifier).loadMore();

    final state = container.read(soundPageProvider(uri)).requireValue;
    expect(state.posts, [first]);
    expect(state.cursor, 'next');
  });

  test('refresh replaces data and exposes refresh failures', () async {
    final audio = _audio();
    repository.responses
      ..add(() async => AudioPostsResponse(audio: audio, posts: [_post('old')]))
      ..add(
        () async => AudioPostsResponse(
          audio: audio,
          posts: [_post('new')],
          cursor: 'next',
        ),
      )
      ..add(() async => throw StateError('refresh failed'));
    final container = createContainer();
    await container.read(soundPageProvider(uri).future);

    await container.read(soundPageProvider(uri).notifier).refresh();
    expect(
      container.read(soundPageProvider(uri)).requireValue.posts.single.cid,
      'cid-new',
    );

    await container.read(soundPageProvider(uri).notifier).refresh();
    expect(
      container.read(soundPageProvider(uri)),
      isA<AsyncError<SoundPageState>>(),
    );
  });
}

AudioView _audio() => AudioView(
  uri: AtUri('at://did:plc:author/so.sprk.sound.audio/sound'),
  cid: 'audio-cid',
  author: const ProfileViewBasic(did: 'did:plc:author', handle: 'author.test'),
  record: const <String, dynamic>{},
  indexedAt: DateTime.utc(2026, 7, 22),
  audio: 'https://cdn.test/audio.mp3',
  coverArt: 'https://cdn.test/cover.jpg',
);

PostView _post(String id) => PostView(
  uri: AtUri('at://did:plc:author/so.sprk.feed.post/$id'),
  cid: 'cid-$id',
  author: const ProfileViewBasic(did: 'did:plc:author', handle: 'author.test'),
  record: const <String, dynamic>{},
  indexedAt: DateTime.utc(2026, 7, 22),
);

class _FakeSoundRepository implements SoundRepository {
  final List<Future<AudioPostsResponse> Function()> responses = [];
  final List<({AtUri uri, int limit, String? cursor})> calls = [];

  @override
  Future<AudioPostsResponse> getAudioPosts(
    AtUri uri, {
    int limit = 50,
    String? cursor,
  }) {
    calls.add((uri: uri, limit: limit, cursor: cursor));
    return responses.removeAt(0)();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
