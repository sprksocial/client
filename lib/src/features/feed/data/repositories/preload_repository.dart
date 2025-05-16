import 'package:sparksocial/src/features/feed/data/models/preloaded_video.dart';

/// Repository for handling media preloading and caching for feeds
abstract class PreloadRepository {
  /// Preload media (video or images) for a specific post index
  Future<void> preloadMedia(int index, String? videoUrl, List<String> imageUrls);
  
  /// Unload a video at a specific index
  void unloadVideo(int index);
  
  /// Update which media should be kept loaded based on the current view position
  void updateLoadedMedia(int newIndex, int oldIndex, int totalPosts);
  
  /// Check if a video is preloaded for a specific index
  bool isVideoPreloaded(int index);
  
  /// Get a preloaded video for a specific index
  PreloadedVideo? getPreloadedVideo(int index);
  
  /// Get the local path for a cached video at a specific index
  String? getLocalVideoPath(int index);
  
  /// Pause a video at a specific index
  Future<void> pauseVideo(int index);
  
  /// Resume a video at a specific index
  Future<void> resumeVideo(int index);
  
  /// Clear all preloaded media
  void clearAllMedia();
  
  /// Dispose the repository resources
  void dispose();
} 