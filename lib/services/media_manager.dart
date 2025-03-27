import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PreloadedVideo {
  final VideoPlayerController controller;
  final bool isInitialized;
  final String? videoUrl;

  PreloadedVideo({required this.controller, required this.isInitialized, required this.videoUrl});

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

  void dispose() {
    clearAllMedia();
  }

  /// Completely reset all media - use when changing feeds
  void clearAllMedia() {
    // Dispose all video controllers
    for (final video in _preloadedVideos.values) {
      try {
        video.dispose();
      } catch (e) {
        // Silently handle any disposal errors
      }
    }
    _preloadedVideos.clear();
    _preloadedImageUrls.clear();
  }

  void preloadMedia(int index, String? videoUrl, List<String> imageUrls, BuildContext context) {
    if (videoUrl != null) {
      _preloadVideo(index, videoUrl);
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

    // Create a new controller
    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    bool isRegistered = false;

    try {
      // Register it as non-initialized first
      _preloadedVideos[index] = PreloadedVideo(controller: controller, isInitialized: false, videoUrl: videoUrl);
      isRegistered = true;

      // Set video to loop automatically
      controller.setLooping(true);

      // Set volume to zero initially
      await controller.setVolume(0.0);

      // Try to initialize
      await controller.initialize();

      // Only proceed if video is still needed and the URL hasn't changed
      if (_preloadedVideos.containsKey(index) && _preloadedVideos[index]!.videoUrl == videoUrl) {
        // Update the preloaded status
        _preloadedVideos[index] = PreloadedVideo(controller: controller, isInitialized: true, videoUrl: videoUrl);

        // Set playback speed to 1.0 (normal)
        await controller.setPlaybackSpeed(1.0);
      } else {
        // If this video is no longer needed or URL changed, dispose it
        try {
          controller.dispose();
        } catch (e) {
          // Silently handle any disposal errors
        }
      }
    } catch (e) {
      // Handle initialization error by cleaning up
      if (isRegistered && _preloadedVideos.containsKey(index) && _preloadedVideos[index]!.videoUrl == videoUrl) {
        try {
          _preloadedVideos[index]!.dispose();
        } catch (disposeError) {
          // Silently handle any disposal errors
        }
        _preloadedVideos.remove(index);
      } else {
        try {
          controller.dispose();
        } catch (disposeError) {
          // Silently handle any disposal errors
        }
      }

      // Try again after a short delay for network errors
      if (e.toString().contains('network')) {
        Future.delayed(const Duration(seconds: 2), () {
          // Only retry if the index is not already loaded with a different URL
          if (!_preloadedVideos.containsKey(index) || _preloadedVideos[index]!.videoUrl == videoUrl) {
            _preloadVideo(index, videoUrl);
          }
        });
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
}
