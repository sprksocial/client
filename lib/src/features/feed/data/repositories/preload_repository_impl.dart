import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:video_player/video_player.dart';
import 'package:get_it/get_it.dart';

import 'package:sparksocial/src/core/storage/cache/cache_manager_interface.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import '../models/preloaded_video.dart';
import 'preload_repository.dart';

class PreloadRepositoryImpl implements PreloadRepository {
  final CacheManagerInterface _cacheManager;
  final SparkLogger _logger;

  // Pre-initialized VideoPlayerControllers mapped by index
  final Map<int, PreloadedVideo> _preloadedVideos = {};

  // Track which image URLs have been preloaded
  final Set<String> _preloadedImageUrls = {};

  // Track local video paths
  final Map<int, String> _localVideoPaths = {};

  final Set<int> _failedPreloads = {};
  final int _maxPreloadAhead = 5;
  final int _maxPreloadBehind = 2;
  final int _maxLoadedVideos = 10; // Max controllers to keep loaded

  PreloadRepositoryImpl({required CacheManagerInterface cacheManager, required LogService logService})
    : _cacheManager = cacheManager,
      _logger = logService.getLogger('MediaRepository');

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

          final file = await _cacheManager.getFile(directVideoUrl);
          return file.path;
        }
      }

      // For other videos, use the original URL
      final file = await _cacheManager.getFile(videoUrl);
      return file.path;
    } catch (e) {
      _logger.e('Error caching video: $e');
      return null;
    }
  }

  @override
  void dispose() {
    clearAllMedia();
  }

  @override
  void clearAllMedia() {
    // Dispose all video controllers
    for (final video in _preloadedVideos.values) {
      try {
        video.controller.dispose();
        if (video.localPath != null) {
          try {
            final file = File(video.localPath!);
            if (file.existsSync()) {
              file.deleteSync();
            }
          } catch (e) {
            _logger.e('Error cleaning up cached video: $e');
          }
        }
      } catch (e) {
        // Silently handle any disposal errors
        _logger.d('Error disposing video controller: $e');
      }
    }
    _preloadedVideos.clear();
    _preloadedImageUrls.clear();
    _localVideoPaths.clear();
    _failedPreloads.clear();

    // Clear the cache
    _cacheManager.clearCache();
  }

  @override
  Future<void> preloadMedia(int index, String? videoUrl, List<String> imageUrls) async {
    if (videoUrl != null) {
      await _preloadVideo(index, videoUrl);
    } else if (imageUrls.isNotEmpty) {
      _preloadImages(index, imageUrls);
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
      _logger.e('Error preloading video at index $index: $e');
      _failedPreloads.add(index);
      // Clean up placeholder on failure
      _preloadedVideos.remove(index);
    }
  }

  void _preloadImages(int index, List<String> imageUrls) {
    final cacheManager = GetIt.instance<CacheManagerInterface>();

    for (final url in imageUrls) {
      if (!_preloadedImageUrls.contains(url)) {
        _preloadedImageUrls.add(url);
        cacheManager.getFile(url); // This downloads and caches the file
      }
    }
  }

  @override
  void unloadVideo(int index) {
    if (_preloadedVideos.containsKey(index)) {
      final video = _preloadedVideos[index]!;
      video.controller.dispose();

      // Clean up cached file if it exists
      if (video.localPath != null) {
        try {
          final file = File(video.localPath!);
          if (file.existsSync()) {
            file.deleteSync();
          }
        } catch (e) {
          _logger.e('Error cleaning up cached video: $e');
        }
      }

      _preloadedVideos.remove(index);
      _localVideoPaths.remove(index);
    }
  }

  @override
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

  @override
  bool isVideoPreloaded(int index) {
    return _preloadedVideos.containsKey(index) && _preloadedVideos[index]!.isInitialized;
  }

  @override
  PreloadedVideo? getPreloadedVideo(int index) {
    return _preloadedVideos[index];
  }

  @override
  String? getLocalVideoPath(int index) {
    return _localVideoPaths[index];
  }

  @override
  Future<void> pauseVideo(int index) async {
    final controller = _getVideoController(index);
    if (controller != null && controller.value.isInitialized && controller.value.isPlaying) {
      try {
        await controller.pause();
      } catch (e) {
        _logger.e("Error pausing video at index $index: $e");
      }
    }
  }

  @override
  Future<void> resumeVideo(int index) async {
    final controller = _getVideoController(index);
    if (controller != null && controller.value.isInitialized && !controller.value.isPlaying) {
      try {
        await controller.play();
      } catch (e) {
        _logger.e("Error resuming video at index $index: $e");
      }
    }
  }

  VideoPlayerController? _getVideoController(int index) {
    return _preloadedVideos[index]?.controller;
  }
}
