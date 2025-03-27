import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../post/post_item_base.dart';
import '../video_controls/video_controller_overlay.dart';

/// Base class for video player widgets, now extending PostItemBase.
abstract class VideoPlayerBase extends PostItemBase {
  // Most props are now inherited from PostItemBase
  final String? videoUrl; // Specific to video items that initialize their own controller

  const VideoPlayerBase({
    super.key,
    required super.index,
    this.videoUrl, // Keep videoUrl if needed by VideoItem
    super.username,
    super.description,
    super.hashtags,
    super.likeCount,
    super.commentCount,
    super.bookmarkCount,
    super.shareCount,
    super.profileImageUrl,
    super.onLikePressed,
    super.onCommentPressed, // Pass comment callback up
    super.onBookmarkPressed,
    super.onSharePressed,
    super.onProfilePressed, // Still allow override if needed
    super.onUsernameTap,
    super.onHashtagTap,
    super.authorDid,
    super.isLiked,
    super.isSprk,
    super.postUri, // Accept postUri
    super.postCid, // Accept postCid
    super.disableBackgroundBlur,
  });
}

/// Base state class for video players, extending PostItemBaseState.
abstract class VideoPlayerBaseState<T extends VideoPlayerBase> extends PostItemBaseState<T> {
  /// Get the current video player controller (still needed for video specifics).
  VideoPlayerController? get videoController;

  /// Check if the video player is initialized (still needed for video specifics).
  bool get isInitialized;

  /// Check if the video is currently visible (remains abstract, subclasses implement)
  @override
  bool get isVisible;

  /// Pause the video player - implements abstract method from base.
  @override
  void pauseMedia() {
    // Check if controller exists and is initialized before pausing
    if (videoController?.value.isInitialized == true) {
      videoController?.pause();
    }
  }

  /// Play the video player - implements abstract method from base.
  @override
  void playMedia() {
    // Only play if initialized and not showing comments (handled by base toggleComments logic)
    // Also check if controller exists and is initialized
    if (isInitialized && !showComments && videoController?.value.isInitialized == true) {
       videoController?.play();
    }
  }

  /// Override to add the VideoControllerOverlay on top of the video content.
  @override
  List<Widget> buildContentOverlays(BuildContext context) {
    // Only add the overlay if the controller exists and is initialized
    final currentController = videoController;
    if (currentController != null && isInitialized) {
      return [
        VideoControllerOverlay(controller: currentController, onTap: () {}),
      ];
    }
    return []; // Return empty list if not initialized
  }
}