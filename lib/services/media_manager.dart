import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

class PreloadedVideo {
  final VideoPlayerController controller;
  final bool isInitialized;
  final String? videoUrl;
  final String? localPath;

  PreloadedVideo({required this.controller, required this.isInitialized, required this.videoUrl, this.localPath});

  void dispose() {
    controller.dispose();
  }
}

class MediaManager {
  // Pre-initialized VideoPlayerControllers mapped by index
  final Map<int, PreloadedVideo> _preloadedVideos = {};

  // Track which image URLs have been preloaded
  final Set<String> _preloadedImageUrls = {};

  // Track local video paths
  final Map<int, String> _localVideoPaths = {};

  // Cache manager for videos
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  final Set<int> _failedPreloads = {};
  final int _maxPreloadAhead = 5;
  final int _maxPreloadBehind = 2;
  final int _maxLoadedVideos = 10; // Max controllers to keep loaded

  Future<String?> _downloadAndCacheVideo(String videoUrl) async {
    try {
      // For Bluesky videos, we need to get the actual video file URL
      if (videoUrl.contains('bsky.app') || videoUrl.contains('bluesky')) {
        // Extract the video ID from the URL
        final uri = Uri.parse(videoUrl);
        final segments = uri.pathSegments;
        if (segments.length >= 3) {
          final did = segments[1];
          final cid = segments[2];
          final directVideoUrl = 'https://media.sprk.so/video/$did/$cid';

          final file = await _cacheManager.getSingleFile(directVideoUrl);
          return file.path;
        }
      }

      // For other videos, use the original URL
      final file = await _cacheManager.getSingleFile(videoUrl);
      return file.path;
    } catch (e) {
      debugPrint('Error caching video: $e');
      return null;
    }
  }

  void dispose() {
    clearAllMedia();
  }

  /// Completely reset all media - use when changing feeds
  void clearAllMedia() {
    // Dispose all video controllers
    for (final video in _preloadedVideos.values) {
      try {
        video.dispose();
        if (video.localPath != null) {
          try {
            final file = File(video.localPath!);
            if (file.existsSync()) {
              file.deleteSync();
            }
          } catch (e) {
            debugPrint('Error cleaning up cached video: $e');
          }
        }
      } catch (e) {
        // Silently handle any disposal errors
      }
    }
    _preloadedVideos.clear();
    _preloadedImageUrls.clear();
    _localVideoPaths.clear();
    _failedPreloads.clear();

    // Clear the cache manager's cache
    _cacheManager.emptyCache();
  }

  Future<void> preloadMedia(int index, String? videoUrl, List<String> imageUrls, BuildContext context) async {
    if (videoUrl != null) {
      await _preloadVideo(index, videoUrl);
    } else if (imageUrls.isNotEmpty) {
      _preloadImages(index, imageUrls, context);
    }
  }

  Future<void> _preloadVideo(int index, String videoUrl) async {
    if (_preloadedVideos.containsKey(index) || _failedPreloads.contains(index)) {
      return; // Already loaded/preloading or failed before
    }

    // Mark as preloading with a placeholder controller
    final placeholderController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _preloadedVideos[index] = PreloadedVideo(controller: placeholderController, isInitialized: false, videoUrl: videoUrl);

    try {
      // Download and cache the video, returning a local file path if successful
      final localPath = await _downloadAndCacheVideo(videoUrl);

      VideoPlayerController controller;
      if (localPath != null) {
        // Use the cached local file
        controller = VideoPlayerController.file(File(localPath));
        _localVideoPaths[index] = localPath;
      } else {
        // Fallback to network URL
        controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      }

      await controller.initialize();
      await controller.setLooping(true);
      // Mute until visible
      await controller.setVolume(0.0);

      // Only update if this index is still relevant
      if (_preloadedVideos.containsKey(index)) {
        _preloadedVideos[index] = PreloadedVideo(
          controller: controller,
          isInitialized: true,
          videoUrl: videoUrl,
          localPath: localPath,
        );
      } else {
        // If no longer needed, dispose
        await controller.dispose();
      }
    } catch (e) {
      debugPrint('Error preloading video at index $index: $e');
      _failedPreloads.add(index);
      // Clean up placeholder on failure
      _preloadedVideos.remove(index);
    }
  }

  void _preloadImages(int index, List<String> imageUrls, BuildContext context) {
    for (final url in imageUrls) {
      precacheImage(NetworkImage(url), context);
    }
  }

  void unloadVideo(int index) {
    if (_preloadedVideos.containsKey(index)) {
      _preloadedVideos[index]!.dispose();
      _preloadedVideos.remove(index);
      _localVideoPaths.remove(index);

      // Clean up cached file if it exists
      if (_preloadedVideos[index]?.localPath != null) {
        try {
          final file = File(_preloadedVideos[index]!.localPath!);
          if (file.existsSync()) {
            file.deleteSync();
          }
        } catch (e) {
          debugPrint('Error cleaning up cached video: $e');
        }
      }
    }
  }

  void updateLoadedMedia(int newIndex, int oldIndex, int totalPosts) {
    final Set<int> indicesToKeep = {};
    for (int i = max(0, newIndex - _maxPreloadBehind); i <= min(totalPosts - 1, newIndex + _maxPreloadAhead); i++) {
      indicesToKeep.add(i);
    }

    // Add currently playing video if it's outside the range (less likely but possible)
    indicesToKeep.add(newIndex);

    // Unload videos outside the keep range
    final indicesToUnload = _preloadedVideos.keys.where((idx) => !indicesToKeep.contains(idx)).toList();
    for (final index in indicesToUnload) {
      unloadVideo(index);
    }

    // Limit total loaded videos if necessary (unload furthest first)
    if (_preloadedVideos.length > _maxLoadedVideos) {
      _unloadFurthestVideos(newIndex);
    }
  }

  void _unloadFurthestVideos(int currentIndex) {
    final loadedIndices = _preloadedVideos.keys.toList();
    loadedIndices.sort((a, b) => (a - currentIndex).abs().compareTo((b - currentIndex).abs())); // Sort by distance

    // Keep the closest _maxLoadedVideos
    final indicesToUnload = loadedIndices.sublist(min(_maxLoadedVideos, loadedIndices.length));
    for (final index in indicesToUnload) {
      unloadVideo(index);
    }
  }

  bool isVideoPreloaded(int index) {
    return _preloadedVideos.containsKey(index) && _preloadedVideos[index]!.isInitialized;
  }

  PreloadedVideo? getPreloadedVideo(int index) {
    return _preloadedVideos[index];
  }

  String? getLocalVideoPath(int index) {
    return _localVideoPaths[index];
  }

  Future<void> pauseVideo(int index) async {
    final controller = _getVideoController(index);
    if (controller != null && controller.value.isInitialized && controller.value.isPlaying) {
      try {
        await controller.pause();
      } catch (e) {
        debugPrint("Error pausing video at index $index: $e");
      }
    }
  }

  Future<void> resumeVideo(int index) async {
    final controller = _getVideoController(index);
    if (controller != null && controller.value.isInitialized && !controller.value.isPlaying) {
      try {
        await controller.play();
      } catch (e) {
        debugPrint("Error resuming video at index $index: $e");
      }
    }
  }

  VideoPlayerController? _getVideoController(int index) {
    return _preloadedVideos[index]?.controller;
  }
}
