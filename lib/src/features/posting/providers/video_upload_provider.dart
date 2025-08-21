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
    logger.i('Starting video processing for: $videoPath');

    final res = await feedRepository.uploadVideo(videoPath);

    logger.i('Video processed successfully');
    return res.video;
  } catch (error, stackTrace) {
    logger.e('Error processing video', error: error, stackTrace: stackTrace);
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
  ({Map<String, String>? details, Blob blob})? audio,
}) async {
  final logger = GetIt.I<LogService>().getLogger('Posting Video');
  try {
    final feedRepository = GetIt.I<SprkRepository>().feed;
    final postText = description.isNotEmpty ? description : '';

    // Create the Sprk post (repo will also create the audio record if provided)
    final postRef = await feedRepository.postVideo(
      blob,
      text: postText,
      alt: altText,
      audio: audio,
    );

    // Crosspost to Bluesky if enabled
    if (crosspostToBsky) {
      try {
        await _crosspostVideoToBlueSky(ref, postText, blob, altText, postRef.uri.rkey);
      } catch (e) {
        logger.w('Failed to crosspost video to Bluesky: $e');
        // Don't fail the entire operation if Bluesky crossposting fails
      }
    }
    logger.i('Video posted successfully');
    return postRef;
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
  final feedRepository = GetIt.I<SprkRepository>().feed;
  final upload = await feedRepository.uploadVideo(videoPath);

  if (storyMode) {
    // Post as a story
    return ref
        .read(
          postStoryProvider(
            EmbedVideo(video: upload.video),
            selfLabels: [],
            tags: [],
          ),
        )
        .value;
  } else {
    // Post as a regular video
    return postVideo(
      ref,
      blob: upload.video,
      audio: upload.audio,
      description: description,
      altText: altText,
      videoPath: videoPath,
      crosspostToBsky: crosspostToBsky,
    );
  }
}

/// Crosspost video to Bluesky using same blob but Bluesky models
@riverpod
Future<void> _crosspostVideoToBlueSky(Ref ref, String text, Blob blob, String altText, String rkey) async {
  final logger = GetIt.I<LogService>().getLogger('Crossposting Video to Bluesky');
  final authRepository = GetIt.I<AuthRepository>();
  logger.d('Crossposting video to Bluesky');

  final session = authRepository.session;
  if (session == null) {
    throw Exception('No session available for Bluesky crosspost');
  }

  // Create Bluesky video post record using direct JSON structure
  final bskyPostRecord = <String, dynamic>{
    r'$type': 'app.bsky.feed.post',
    'text': text,
    'embed': {r'$type': 'app.bsky.embed.video', 'video': blob.toJson(), 'alt': altText},
    'createdAt': DateTime.now().toUtc().toIso8601String(),
  };

  final bskyAtProto = authRepository.atproto!;
  final bskyResult = await bskyAtProto.repo.createRecord(
    collection: NSID.parse('app.bsky.feed.post'),
    record: bskyPostRecord,
    rkey: rkey,
  );

  logger.i('Successfully crossposted video to Bluesky: ${bskyResult.data.uri}');
}
