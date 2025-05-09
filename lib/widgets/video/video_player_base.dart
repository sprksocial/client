import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../mixins/refresh_mixin.dart';
import '../post/post_item_base.dart';
import '../video_controls/video_controller_overlay.dart';

/// Base class for video player widgets, now extending PostItemBase.
abstract class VideoPlayerBase extends PostItemBase {
  // Most props are now inherited from PostItemBase
  final String? videoUrl; // Specific to video items that initialize their own controller
  final VoidCallback? onRefresh; // Callback for refresh functionality

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
    super.videoAlt, // Add super.videoAlt here
    super.onPostDeleted,
    this.onRefresh, // Add refresh callback
  });
}

/// Base state class for video players, extending PostItemBaseState.
abstract class VideoPlayerBaseState<T extends VideoPlayerBase> extends PostItemBaseState<T> 
  with SingleTickerProviderStateMixin, RefreshMixin<T> implements RefreshableState {
  /// Get the current video player controller (still needed for video specifics).
  VideoPlayerController? get videoController;

  /// Check if the video player is initialized (still needed for video specifics).
  bool get isInitialized;

  /// Check if the video is currently visible (remains abstract, subclasses implement)
  @override
  bool get isVisible;

  // Implementation for RefreshableState
  @override
  VoidCallback? get onRefreshCallback => widget.onRefresh;

  @override
  int get itemIndex => widget.index;

  @override
  void pauseMedia() {
    // Check if controller exists and is initialized before pausing
    if (videoController?.value.isInitialized == true) {
      videoController?.pause();
    }
  }

  @override
  void playMedia() {
    // Only play if initialized and not showing comments (handled by base toggleComments logic)
    // Also check if controller exists and is initialized
    if (isInitialized && !showComments && videoController?.value.isInitialized == true) {
      videoController?.play();
    }
  }

  @override
  bool get isMediaVisible => isVisible; // Already implemented by subclasses via `isVisible` getter

  @override
  void refreshSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  bool get mountedState => mounted;

  @override
  TickerProvider get vsyncProvider => this;

  @override
  void initState() {
    super.initState();
    initRefreshState(); // Initialize RefreshMixin state
  }
  
  @override
  void dispose() {
    disposeRefreshState(); // Dispose RefreshMixin state
    super.dispose();
  }

  /// Public method to trigger refresh programmatically - now uses the mixin's method.
  Future<void> refresh() async {
    // This now calls the mixin's triggerRefresh, which handles the logic.
    // Ensure widget.onRefresh is used by the mixin via onRefreshCallback.
    await triggerRefresh(); 
  }

  /// Handle tap on the video overlay
  void _handleVideoTap() {
    // This is intentionally empty as the VideoControllerOverlay now handles toggles internally
    // This is just used to receive tap notification if needed in the future
  }

  /// Override to add the VideoControllerOverlay on top of the video content.
  @override
  List<Widget> buildContentOverlays(BuildContext context) {
    final overlays = <Widget>[];
    
    // Add refresh indicator using the mixin
    final refreshIndicator = buildRefreshIndicator();
    if (refreshIndicator != null) {
      overlays.add(refreshIndicator);
    }
    
    // Only add the video controller overlay if the controller exists and is initialized
    final currentController = videoController;
    if (currentController != null && isInitialized) {
      overlays.add(
        VideoControllerOverlay(
          controller: currentController,
          onLikePressed: widget.onLikePressed,
          isLiked: widget.isLiked,
          onTap: _handleVideoTap,
        ),
      );
    }
    
    return overlays;
  }
  
  @override
  Widget build(BuildContext context) {
    // Wrap the content with the refresh listener from the mixin
    return buildRefreshListener(
      child: super.build(context),
    );
  }
}
