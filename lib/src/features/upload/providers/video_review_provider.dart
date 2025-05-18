import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/features/upload/data/models/video_review_state.dart';
import 'package:video_player/video_player.dart';
import 'package:get_it/get_it.dart';

import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/upload/providers/upload_provider.dart';

part 'video_review_provider.g.dart';

/// Provider for video review page
@riverpod
class VideoReviewNotifier extends _$VideoReviewNotifier {
  final _logger = GetIt.instance<LogService>().getLogger('VideoReviewNotifier');

  @override
  VideoReviewState build(String videoPath) {
    _logger.d('Initializing VideoReviewNotifier with video path: $videoPath');

    // Initialize video player on build
    _initVideoPlayer(videoPath);

    ref.onDispose(() {
      _logger.d('Disposing VideoReviewNotifier');
      state.controller?.dispose();
    });

    return VideoReviewState.initial(videoPath);
  }

  /// Initialize the video player with the given path
  Future<void> _initVideoPlayer(String videoPath) async {
    try {
      String normalizedPath = videoPath;

      // Handle file:// URL scheme
      if (normalizedPath.startsWith('file://')) {
        normalizedPath = normalizedPath.replaceFirst('file://', '');
      }

      final controller = VideoPlayerController.file(File(normalizedPath));
      await controller.initialize();
      controller.setLooping(true);

      state = state.copyWith(controller: controller);
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize video player', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: 'Failed to load video: ${e.toString()}');
    }
  }

  /// Set description text
  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  /// Set alt text
  void setAltText(String altText) {
    state = state.copyWith(altText: altText);
  }

  /// Upload video and post it
  Future<void> uploadVideo() async {
    if (state.isUploading) return;

    state = state.copyWith(isUploading: true, error: null);

    try {
      final uploadNotifier = ref.read(uploadNotifierProvider.notifier);
      final sprkRepository = GetIt.instance<SprkRepository>();
      final feedRepository = sprkRepository.feed;

      // Register a new upload task
      final taskId = uploadNotifier.registerTask('video');
      uploadNotifier.startTask(taskId);

      // Process the video and get blob reference
      _logger.d('Processing video: ${state.videoPath}');
      final videoBlobRef = await _processVideo(state.videoPath);

      // Post the video with the blob reference
      _logger.d('Posting video with description: ${state.description}');
      await feedRepository.postVideo(videoBlobRef, description: state.description, videoAltText: state.altText);

      // Mark task as completed
      uploadNotifier.completeTask(taskId);
      _logger.i('Video uploaded successfully');

      return;
    } catch (e, stackTrace) {
      _logger.e('Failed to upload video', error: e, stackTrace: stackTrace);

      // Update upload service with error state if possible
      try {
        final uploadNotifier = ref.read(uploadNotifierProvider.notifier);
        final taskId = uploadNotifier.registerTask('video');
        uploadNotifier.failTask(taskId, e.toString());
      } catch (err) {
        _logger.e('Failed to register upload failure', error: err);
      }

      // Update state with error
      state = state.copyWith(isUploading: false, error: 'Failed to upload video: ${e.toString()}');

      // Re-throw to let UI handle the error
      rethrow;
    }
  }

  /// Process the video file and return a blob reference
  Future<BlobReference> _processVideo(String videoPath) async {
    final sprkRepository = GetIt.instance<SprkRepository>();
    final repoRepository = sprkRepository.repo;

    // Handle file:// URL scheme
    String normalizedPath = videoPath;
    if (normalizedPath.startsWith('file://')) {
      normalizedPath = normalizedPath.replaceFirst('file://', '');
    }

    // Validate the video file
    final file = File(normalizedPath);
    if (!await file.exists()) {
      throw Exception('Video file not found: $normalizedPath');
    }

    // Read the video bytes
    final videoBytes = await file.readAsBytes();
    if (videoBytes.isEmpty) {
      throw Exception('Video file is empty');
    }

    _logger.d('Video file size: ${videoBytes.length} bytes');

    // Upload the video blob
    final uploadResult = await repoRepository.uploadBlob(videoBytes);
    _logger.d('Video blob uploaded successfully');

    // Create a BlobReference from the blobRef map
    return BlobReference.fromJson(uploadResult.blobRef);
  }
}
