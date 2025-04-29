import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  static final MediaManager _instance = MediaManager._internal();
  factory MediaManager() => _instance;
  MediaManager._internal();

  // Pre-initialized VideoPlayerControllers mapped by index
  final Map<int, PreloadedVideo> _preloadedVideos = {};

  // Track which image URLs have been preloaded
  final Set<String> _preloadedImageUrls = {};

  // Track local video paths
  final Map<int, String> _localVideoPaths = {};

  // Cache manager for videos
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

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
      print('Error caching video: $e');
      return null;
    }
  }

  String _normalizeVideoUrl(String url) {
    try {
      // Handle relative URLs (starting with '/')
      if (url.startsWith('/')) {
        // Construct full URL for Bluesky videos
        return 'https://bsky.app$url';
      }

      final uri = Uri.parse(url);

      // For Bluesky videos, use the path as the cache key
      if (uri.host.contains('bsky.app') || uri.host.contains('bluesky')) {
        return uri.path;
      }

      // For Spark videos, ensure consistent URL format
      if (uri.host.contains('sprk.so')) {
        return Uri(scheme: uri.scheme, host: uri.host, path: uri.path).toString();
      }

      // For other URLs, use as is
      return url;
    } catch (e) {
      print('Error normalizing URL: $e');
      return url;
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
            print('Error cleaning up cached video: $e');
          }
        }
      } catch (e) {
        // Silently handle any disposal errors
      }
    }
    _preloadedVideos.clear();
    _preloadedImageUrls.clear();
    _localVideoPaths.clear();

    // Clear the cache manager's cache
    _cacheManager.emptyCache();
  }

  Future<void> preloadMedia(int index, String? videoUrl, List<String> imageUrls, BuildContext context) async {
    if (videoUrl != null) {
      await _preloadVideo(index, videoUrl);
    } else if (imageUrls.isNotEmpty) {
      _preloadImages(imageUrls, context);
    }
  }

  Future<void> _preloadVideo(int index, String videoUrl) async {
    // Skip if already preloaded with the same URL
    if (_preloadedVideos.containsKey(index)) {
      if (_preloadedVideos[index]!.videoUrl == videoUrl) {
        return;
      }

      // If URL changed, dispose old controller first
      try {
        _preloadedVideos[index]!.dispose();
      } catch (e) {
        // Silently handle any disposal errors
      }
      _preloadedVideos.remove(index);
    }

    // Try to download and cache the video
    final localPath = await _downloadAndCacheVideo(videoUrl);
    VideoPlayerController controller;

    try {
      if (localPath != null) {
        // Always use local file if available
        controller = VideoPlayerController.file(File(localPath));
      } else {
        // Fall back to network only if caching fails
        controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      }

      // Register it as non-initialized first
      _preloadedVideos[index] = PreloadedVideo(
        controller: controller,
        isInitialized: false,
        videoUrl: videoUrl,
        localPath: localPath,
      );

      // Set video to loop automatically
      controller.setLooping(true);

      // Set volume to zero initially
      await controller.setVolume(0.0);

      // Try to initialize
      await controller.initialize();

      // Only proceed if video is still needed and the URL hasn't changed
      if (_preloadedVideos.containsKey(index) && _preloadedVideos[index]!.videoUrl == videoUrl) {
        // Update the preloaded status
        _preloadedVideos[index] = PreloadedVideo(
          controller: controller,
          isInitialized: true,
          videoUrl: videoUrl,
          localPath: localPath,
        );

        // Set playback speed to 1.0 (normal)
        await controller.setPlaybackSpeed(1.0);

        // Store the local path
        if (localPath != null) {
          _localVideoPaths[index] = localPath;
        }
      } else {
        // If this video is no longer needed or URL changed, dispose it
        try {
          controller.dispose();
        } catch (e) {
          // Silently handle any disposal errors
        }
      }
    } catch (e) {
      print('Error preloading video: $e');
      // Clean up if there was an error
      if (_preloadedVideos.containsKey(index)) {
        try {
          _preloadedVideos[index]!.dispose();
        } catch (disposeError) {
          // Silently handle any disposal errors
        }
        _preloadedVideos.remove(index);
      }
    }
  }

  void _preloadImages(List<String> urls, BuildContext context) {
    for (final url in urls) {
      if (!_preloadedImageUrls.contains(url)) {
        _preloadedImageUrls.add(url);
        precacheImage(CachedNetworkImageProvider(url), context);
      }
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
          print('Error cleaning up cached video: $e');
        }
      }
    }
  }

  void updateLoadedMedia(int newIndex, int currentIndex, int totalItems) {
    if (newIndex != currentIndex) {
      // Handle video playback for the current and previous video
      if (_preloadedVideos.containsKey(currentIndex)) {
        try {
          // Mute and pause the previously playing video
          _preloadedVideos[currentIndex]!.controller.setVolume(0.0);
          _preloadedVideos[currentIndex]!.controller.pause();
        } catch (e) {
          // If there's an issue with the controller, clean it up
          unloadVideo(currentIndex);
        }
      }

      if (_preloadedVideos.containsKey(newIndex)) {
        try {
          // Set volume and play the current video
          _preloadedVideos[newIndex]!.controller.setVolume(1.0);
          _preloadedVideos[newIndex]!.controller.play();
        } catch (e) {
          // If there's an issue with the controller, clean it up
          unloadVideo(newIndex);
        }
      }

      // Use a wider preloading range - 5 before and 5 after
      final toLoad = <int>{};

      // Add 5 previous and 5 next items
      for (int i = newIndex - 5; i <= newIndex + 5; i++) {
        toLoad.add(i);
      }

      // Remove indices that are out of bounds
      final validToLoad = toLoad.where((idx) => idx >= 0 && idx < totalItems).toSet();

      // Find videos to unload (current loaded videos that aren't in the new set)
      final toUnload = _preloadedVideos.keys.toSet().difference(validToLoad);

      // Unload videos no longer needed
      for (final idx in toUnload) {
        unloadVideo(idx);
      }
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
}
