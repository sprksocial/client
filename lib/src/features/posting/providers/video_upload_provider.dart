import 'package:atproto/core.dart';
import 'package:bluesky/app_bsky_richtext_facet.dart';
import 'package:bluesky/com_atproto_repo_strongref.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/network/atproto/data/adapters/bsky/feed_adapter.dart';
import 'package:spark/src/core/utils/bluesky_crosspost_text.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/share_urls.dart';

part 'video_upload_provider.g.dart';

const _bskyFeedAdapter = BskyFeedAdapter();

/// Process a video file and upload it to the video service
@riverpod
Future<VideoUploadResult?> processVideo(Ref ref, String videoPath) async {
  final feedRepository = GetIt.I<SprkRepository>().feed;
  final logger = GetIt.I<LogService>().getLogger('Processing Video');
  try {
    logger.d('Processing video: $videoPath');
    final result = await feedRepository.uploadVideo(videoPath);
    logger.i(
      'Video processed (size=${result.videoBlob.size}, '
      'mime=${result.videoBlob.mimeType}, '
      'hasAudio=${result.audioBlob != null})',
    );
    return result;
  } catch (error, stackTrace) {
    logger.e(
      'Error processing video ($videoPath)',
      error: error,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

/// Post a video to the feed using the processed blob reference
@riverpod
Future<RepoStrongRef?> postVideo(
  Ref ref, {
  required Blob blob,
  String description = '',
  String altText = '',
  String? videoPath,
  bool crosspostToBsky = false,
  RepoStrongRef? soundRef,
  List<Facet> facets = const [],
}) async {
  final logger = GetIt.I<LogService>().getLogger('Posting Video');
  try {
    logger.d(
      'Posting video (size=${blob.size}, crosspost=$crosspostToBsky, '
      'sound=${soundRef?.uri})',
    );

    final postRecord = PostRecord(
      caption: CaptionRef(
        text: description.isNotEmpty ? description : '',
        facets: facets,
      ),
      media: Media.video(video: blob, alt: altText),
      createdAt: DateTime.now().toUtc(),
      sound: soundRef,
    );

    final result = await GetIt.I<SprkRepository>().repo.createRecord(
      collection: 'so.sprk.feed.post',
      record: postRecord.toJson(),
    );

    var finalResult = result;

    if (crosspostToBsky) {
      try {
        final bskyResult = await _crosspostVideoToBlueSky(
          ref,
          description,
          blob,
          altText,
          result.uri.rkey,
          facets,
        );
        finalResult = await GetIt.I<SprkRepository>().repo.editRecord(
          uri: result.uri,
          record: postRecord.copyWith(crossposts: [bskyResult]),
        );
      } catch (e, s) {
        logger.w('Crosspost to Bluesky failed: $e', error: e, stackTrace: s);
      }
    }
    logger.i('Video posted successfully: ${finalResult.uri}');
    return finalResult;
  } catch (error, stackTrace) {
    logger.e('Error posting video', error: error, stackTrace: stackTrace);
    rethrow;
  }
}

/// Process video and post it in one step
@riverpod
Future<RepoStrongRef?> processAndPostVideo(
  Ref ref, {
  required String videoPath,
  String description = '',
  String altText = '',
  bool crosspostToBsky = false,
  bool storyMode = false,
  RepoStrongRef? soundRef,
  List<Facet> facets = const [],
  List<StoryEmbed> storyEmbeds = const [],
}) async {
  final logger = GetIt.I<LogService>().getLogger('Process/Post Video')
    ..d(
      'Processing then posting video: $videoPath (storyMode=$storyMode, '
      'sound=${soundRef?.uri})',
    );
  final uploadResult = await processVideo(ref, videoPath);
  if (uploadResult == null) {
    logger.e('Aborting: processing failed');
    throw Exception('Failed to process video');
  }

  final videoBlob = uploadResult.videoBlob;

  // If no sound selected & video has extracted audio, create new sound record
  var effectiveSoundRef = soundRef;
  if (soundRef == null && uploadResult.audioBlob != null) {
    logger.d('Creating new sound record from extracted audio');
    try {
      final soundRepository = GetIt.I<SprkRepository>().sound;
      effectiveSoundRef = await soundRepository.createSound(
        sound: uploadResult.audioBlob!,
        title: 'Original Sound',
        details: uploadResult.audioDetails,
      );
      logger.i('Sound record created: ${effectiveSoundRef.uri}');
    } catch (e, s) {
      logger.w(
        'Failed to create sound record, proceeding without sound',
        error: e,
        stackTrace: s,
      );
    }
  }

  if (storyMode) {
    try {
      final storyRepository = GetIt.I<StoryRepository>();
      final res = await storyRepository.postStory(
        Media.video(video: videoBlob),
        soundRef: effectiveSoundRef,
        embeds: storyEmbeds,
      );
      logger.i('Story posted: ${res.uri}');
      return res;
    } catch (e, s) {
      logger.e('Failed to post story', error: e, stackTrace: s);
      rethrow;
    }
  } else {
    final res = await postVideo(
      ref,
      blob: videoBlob,
      description: description,
      altText: altText,
      videoPath: videoPath,
      crosspostToBsky: crosspostToBsky,
      soundRef: effectiveSoundRef,
      facets: facets,
    );
    logger.i('Video flow complete (storyMode=false) success=${res != null}');
    return res;
  }
}

/// Crosspost video to Bluesky using same blob but Bluesky models
@riverpod
Future<RepoStrongRef> _crosspostVideoToBlueSky(
  Ref ref,
  String text,
  Blob blob,
  String altText,
  String rkey,
  List<Facet> sparkFacets,
) async {
  final logger = GetIt.I<LogService>().getLogger('Crosspost Video')
    ..d('Crossposting video to Bluesky');

  final sprkRepository = GetIt.I<SprkRepository>();
  final sparkDid = sprkRepository.authRepository.did;
  if (sparkDid == null) {
    throw Exception('User session DID not available');
  }
  final linkUrl = buildSparkShareUrl('$sparkDid/$rkey');
  final crosspostText = buildBlueskyCrosspostText(text: text, linkUrl: linkUrl);

  final bskyFacets = <RichtextFacet>[];
  for (final facet in sparkFacets) {
    if (facet.index.byteEnd > crosspostText.facetTextByteEnd) {
      continue;
    }

    for (final feature in facet.features) {
      feature.map(
        mention: (m) {
          bskyFacets.add(
            _bskyFeedAdapter.createMentionFacet(
              did: m.did,
              byteStart: facet.index.byteStart,
              byteEnd: facet.index.byteEnd,
            ),
          );
        },
        link: (_) {},
        tag: (_) {},
        bskyMention: (m) {
          bskyFacets.add(
            _bskyFeedAdapter.createMentionFacet(
              did: m.did,
              byteStart: facet.index.byteStart,
              byteEnd: facet.index.byteEnd,
            ),
          );
        },
        bskyLink: (_) {},
        bskyTag: (_) {},
      );
    }
  }

  bskyFacets.add(
    _bskyFeedAdapter.createLinkFacet(
      linkUrl: linkUrl,
      byteStart: crosspostText.linkByteStart,
    ),
  );

  final bskyPostRecord = <String, dynamic>{
    r'$type': 'app.bsky.feed.post',
    'text': crosspostText.text,
    if (bskyFacets.isNotEmpty)
      'facets': bskyFacets.map((facet) => facet.toJson()).toList(),
    'embed': {
      r'$type': 'app.bsky.embed.video',
      'video': blob.toJson(),
      'alt': altText,
    },
    'createdAt': DateTime.now().toUtc().toIso8601String(),
  };

  final result = await sprkRepository.repo.createRecord(
    collection: 'app.bsky.feed.post',
    record: bskyPostRecord,
    rkey: rkey,
  );
  logger.i('Crossposted video to Bluesky: ${result.uri}');
  return result;
}
