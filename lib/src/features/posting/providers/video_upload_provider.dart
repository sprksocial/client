import 'package:atproto/core.dart';
import 'package:bluesky/com_atproto_repo_strongref.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/posting/providers/post_story.dart';

part 'video_upload_provider.g.dart';

/// Process a video file and upload it to the video service
@riverpod
Future<VideoUploadResult?> processVideo(Ref ref, String videoPath) async {
  final feedRepository = GetIt.I<SprkRepository>().feed;
  final logger = GetIt.I<LogService>().getLogger('Processing Video');
  try {
    logger.d('Processing video: $videoPath');
    final result = await feedRepository.uploadVideo(videoPath);
    logger.i(
      'Video processed (size=${result.videoBlob.size}, mime=${result.videoBlob.mimeType}, hasAudio=${result.audioBlob != null})',
    );
    return result;
  } catch (error, stackTrace) {
    logger.e('Error processing video ($videoPath)', error: error, stackTrace: stackTrace);
    return null;
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
}) async {
  final logger = GetIt.I<LogService>().getLogger('Posting Video');
  try {
    logger.d('Posting video (size=${blob.size}, crosspost=$crosspostToBsky, sound=${soundRef?.uri})');
    final authRepository = GetIt.I<AuthRepository>();
    final authAtProto = authRepository.atproto;
    if (authAtProto == null || authAtProto.session == null) {
      throw Exception('AtProto not initialized');
    }

    final postRecord = PostRecord(
      caption: CaptionRef(text: description.isNotEmpty ? description : '', facets: []),
      media: Media.video(video: blob, alt: altText),
      createdAt: DateTime.now().toUtc(),
      sound: soundRef,
    );

    final recordRes = await authAtProto.repo.createRecord(
      repo: authAtProto.session!.did,
      collection: 'so.sprk.feed.post',
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
    return recordRes.data as RepoStrongRef;
  } catch (error, stackTrace) {
    logger.e('Error posting video', error: error, stackTrace: stackTrace);
  }
  return null;
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
}) async {
  final logger = GetIt.I<LogService>().getLogger('Process/Post Video');
  logger.d('Processing then posting video: $videoPath (storyMode=$storyMode, sound=${soundRef?.uri})');
  final uploadResult = await processVideo(ref, videoPath);
  if (uploadResult == null) {
    logger.e('Aborting: processing failed');
    throw Exception('Failed to process video');
  }

  final videoBlob = uploadResult.videoBlob;

  // If no sound was pre-selected and the video has extracted audio, create a new sound record
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
      logger.w('Failed to create sound record, proceeding without sound', error: e, stackTrace: s);
    }
  }

  if (storyMode) {
    try {
      final res = await ref.read(
        postStoryProvider(
          Media.video(video: videoBlob),
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
      blob: videoBlob,
      description: description,
      altText: altText,
      videoPath: videoPath,
      crosspostToBsky: crosspostToBsky,
      soundRef: effectiveSoundRef,
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
      repo: session.did,
      collection: 'app.bsky.feed.post',
      record: bskyPostRecord,
      rkey: rkey,
    );
    logger.i('Crossposted video to Bluesky: ${bskyResult.data.uri}');
  } catch (e, s) {
    logger.w('Failed to crosspost video: $e', error: e, stackTrace: s);
  }
}
