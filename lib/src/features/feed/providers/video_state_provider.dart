import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:get_it/get_it.dart';

import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/feed/data/models/video_player_state.dart';
part 'video_state_provider.g.dart';

/// Provider that manages video state for a specific video index
@riverpod
class VideoState extends _$VideoState {
  final _logger = GetIt.instance<LogService>().getLogger('VideoStateProvider');

  @override
  VideoPlayerState build(int videoIndex, {int initialCommentCount = 0}) {
    ref.onDispose(() {
        state.controller?.dispose();
      _logger.d('Disposing video state provider for index $videoIndex');
    });

    return VideoPlayerState.initial().copyWith(commentCount: initialCommentCount);
  }

  /// Initialize controller with a network URL
  Future<void> initializeWithUrl(String url) async {
    if (state.controller != null) {
      await state.controller!.dispose();
    }

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      state = state.copyWith(controller: controller);

      await controller.initialize();
      controller.setLooping(true);

      state = state.copyWith(isInitialized: true, error: null);
    } catch (e) {
      _logger.e('Failed to initialize video with URL', error: e);
      state = state.copyWith(error: 'Failed to load video: ${e.toString()}', isInitialized: false);
    }
  }

  /// Initialize controller with a local file
  Future<void> initializeWithFile(String path) async {
    if (state.controller != null) {
      await state.controller!.dispose();
    }

    try {
      final controller = VideoPlayerController.file(File(path));
      state = state.copyWith(controller: controller);

      await controller.initialize();
      controller.setLooping(true);

      state = state.copyWith(isInitialized: true, error: null);
    } catch (e) {
      _logger.e('Failed to initialize video with file', error: e);
      state = state.copyWith(error: 'Failed to load video: ${e.toString()}', isInitialized: false);
    }
  }

  /// Set an already initialized controller
  void setPreloadedController(VideoPlayerController controller) {
    state = state.copyWith(controller: controller, isInitialized: controller.value.isInitialized);
  }

  /// Set the visibility state of the video
  void setVisibility(bool isVisible) {
    state = state.copyWith(isVisible: isVisible);
    _updatePlayState();
  }

  /// Play the video if conditions are met
  void playMedia() {
    if (state.isInitialized && state.controller != null && state.isVisible && !state.showComments) {
      state.controller!.play();
      state = state.copyWith(isPlaying: true);
    }
  }

  /// Pause the video
  void pauseMedia() {
    if (state.isInitialized && state.controller != null) {
      state.controller!.pause();
      state = state.copyWith(isPlaying: false);
    }
  }

  /// Toggle description expanded state
  void toggleDescription(bool expanded) {
    state = state.copyWith(isDescriptionExpanded: expanded);
  }

  /// Update the comment count
  void updateCommentCount(int count) {
    state = state.copyWith(commentCount: count);
  }

  /// Set comments visibility
  void setShowComments(bool show) {
    state = state.copyWith(showComments: show);
    _updatePlayState();
  }

  /// Update play state based on current conditions
  void _updatePlayState() {
    if (state.isVisible && !state.showComments) {
      playMedia();
    } else {
      pauseMedia();
    }
  }
}

/// Provider for preloaded video controller management
@riverpod
class PreloadedVideoState extends _$PreloadedVideoState {
  final _logger = GetIt.instance<LogService>().getLogger('PreloadedVideoProvider');

  @override
  VideoPlayerState build(
    int videoIndex, {
    required VideoPlayerController controller,
    required bool isVisible,
    int initialCommentCount = 0,
  }) {
    // Listen for video completion to loop
    controller.addListener(_videoListener);

    ref.onDispose(() {
      controller.removeListener(_videoListener);
      _logger.d('Disposing preloaded video state provider for index $videoIndex');
    });

    return VideoPlayerState(
      isInitialized: controller.value.isInitialized,
      isPlaying: controller.value.isPlaying,
      isVisible: isVisible,
      isDescriptionExpanded: false,
      showComments: false,
      commentCount: initialCommentCount,
      controller: controller,
    );
  }

  void _videoListener() {
    final controller = state.controller;
    if (controller == null) return;

    if (controller.value.isCompleted && state.isVisible && !state.showComments) {
      controller.seekTo(Duration.zero);
      controller.play();
    }

    // Update playing state if it changed externally
    if (controller.value.isPlaying != state.isPlaying) {
      state = state.copyWith(isPlaying: controller.value.isPlaying);
    }
  }

  /// Set the visibility state of the video
  void setVisibility(bool isVisible) {
    state = state.copyWith(isVisible: isVisible);
    _updatePlayState();
  }

  /// Play the video if conditions are met
  void playMedia() {
    if (state.isInitialized && state.controller != null && state.isVisible && !state.showComments) {
      state.controller!.play();
      state = state.copyWith(isPlaying: true);
    }
  }

  /// Pause the video
  void pauseMedia() {
    if (state.isInitialized && state.controller != null) {
      state.controller!.pause();
      state = state.copyWith(isPlaying: false);
    }
  }

  /// Toggle description expanded state
  void toggleDescription(bool expanded) {
    state = state.copyWith(isDescriptionExpanded: expanded);
  }

  /// Update the comment count
  void updateCommentCount(int count) {
    state = state.copyWith(commentCount: count);
  }

  /// Set comments visibility
  void setShowComments(bool show) {
    state = state.copyWith(showComments: show);
    _updatePlayState();
  }

  /// Update play state based on current conditions
  void _updatePlayState() {
    if (state.isVisible && !state.showComments) {
      playMedia();
    } else {
      pauseMedia();
    }
  }

  /// Handle app lifecycle changes
  void handleAppLifecycleState(AppLifecycleState lifecycleState) {
    if (!state.isInitialized) return;

    if (lifecycleState == AppLifecycleState.paused || lifecycleState == AppLifecycleState.inactive) {
      // Save current playing state and pause
      final wasPlaying = state.isPlaying;
      pauseMedia();
      // Store this in the state
      state = state.copyWith(
        isPlaying: wasPlaying, // We're keeping the "intent" to play
      );
    } else if (lifecycleState == AppLifecycleState.resumed) {
      // Resume if it was playing before
      if (state.isPlaying && state.isVisible && !state.showComments) {
        playMedia();
      }
    }
  }
}
