import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/posting/providers/post_story.dart';

part 'video_upload_provider.g.dart';

/// Process a video file and upload it to the video service
@riverpod
Future<Blob?> processVideo(Ref ref, String videoPath) async {
  final feedRepository = GetIt.I<SprkRepository>().feed;
  final logger = GetIt.I<LogService>().getLogger('Processing Video');
  try {
    logger.d('Processing video: $videoPath');
    final blob = await feedRepository.uploadVideo(videoPath);
    logger.i('Video processed (size=${blob.size}, mime=${blob.mimeType})');
    return blob;
  } catch (error, stackTrace) {
    logger.e('Error processing video ($videoPath)', error: error, stackTrace: stackTrace);
    return null;
  }
}

/// Post a video to the feed using the processed blob reference
@riverpod
Future<StrongRef?> postVideo(
  Ref ref, {
  required Blob blob,
  String description = '',
  String altText = '',
  String? videoPath,
  bool crosspostToBsky = false,
}) async {
  final logger = GetIt.I<LogService>().getLogger('Posting Video');
  try {
    logger.d('Posting video (size=${blob.size}, crosspost=$crosspostToBsky)');
    final authRepository = GetIt.I<AuthRepository>();
    final authAtProto = authRepository.atproto;
    if (authAtProto == null || authAtProto.session == null) {
      throw Exception('AtProto not initialized');
    }

    final postRecord = PostRecord(
      caption: CaptionRef(text: description.isNotEmpty ? description : '', facets: []),
      media: Media.video(video: blob, alt: altText),
      createdAt: DateTime.now().toUtc(),
    );

    final recordRes = await authAtProto.repo.createRecord(
      collection: NSID.parse('so.sprk.feed.post'),
      record: postRecord.toJson(),
    );

    if (recordRes.status != HttpStatus.ok) {
      throw Exception('Failed to post video: ${recordRes.status}');
    }

    if (crosspostToBsky) {
      try {
        await _crosspostVideoToBlueSky(ref, description, blob, altText, recordRes.data.uri.rkey);
      } catch (e, s) {
        logger.w('Crosspost to Bluesky failed: $e', error: e, stackTrace: s);
      }
    }
    logger.i('Video posted successfully: ${recordRes.data.uri}');
    return recordRes.data;
  } catch (error, stackTrace) {
    logger.e('Error posting video', error: error, stackTrace: stackTrace);
  }
  return null;
}

/// Process video and post it in one step
@riverpod
Future<StrongRef?> processAndPostVideo(
  Ref ref, {
  required String videoPath,
  String description = '',
  String altText = '',
  bool crosspostToBsky = false,
  bool storyMode = false,
}) async {
  final logger = GetIt.I<LogService>().getLogger('Process/Post Video');
  logger.d('Processing then posting video: $videoPath (storyMode=$storyMode)');
  final blob = await processVideo(ref, videoPath);
  if (blob == null) {
    logger.e('Aborting: processing failed');
    throw Exception('Failed to process video');
  }

  if (storyMode) {
    try {
      final res = await ref.read(
        postStoryProvider(
          Media.video(video: blob),
          selfLabels: [],
          tags: [],
        ).future,
      );
      logger.i('Story posted: ${res?.uri}');
      return res;
    } catch (e, s) {
      logger.e('Failed to post story', error: e, stackTrace: s);
      rethrow;
    }
  } else {
    final res = await postVideo(
      ref,
      blob: blob,
      description: description,
      altText: altText,
      videoPath: videoPath,
      crosspostToBsky: crosspostToBsky,
    );
    logger.i('Video flow complete (storyMode=false) success=${res != null}');
    return res;
  }
}

/// Crosspost video to Bluesky using same blob but Bluesky models
@riverpod
Future<void> _crosspostVideoToBlueSky(
  Ref ref,
  String text,
  Blob blob,
  String altText,
  String rkey,
) async {
  final logger = GetIt.I<LogService>().getLogger('Crosspost Video');
  final authRepository = GetIt.I<AuthRepository>();
  logger.d('Crossposting video to Bluesky');
  final session = authRepository.session;
  if (session == null) {
    throw Exception('No session available for Bluesky crosspost');
  }
  final bskyPostRecord = <String, dynamic>{
    r'$type': 'app.bsky.feed.post',
    'text': text,
    'embed': {r'$type': 'app.bsky.embed.video', 'video': blob.toJson(), 'alt': altText},
    'createdAt': DateTime.now().toUtc().toIso8601String(),
  };
  try {
    final bskyAtProto = authRepository.atproto!;
    final bskyResult = await bskyAtProto.repo.createRecord(
      collection: NSID.parse('app.bsky.feed.post'),
      record: bskyPostRecord,
      rkey: rkey,
    );
    logger.i('Crossposted video to Bluesky: ${bskyResult.data.uri}');
  } catch (e, s) {
    logger.w('Failed to crosspost video: $e', error: e, stackTrace: s);
  }
}
