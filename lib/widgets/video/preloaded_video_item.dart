import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../video_controls/video_controller_overlay.dart';
import '../video_info/video_info_bar.dart';
import '../video_side_action_bar.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters/text_formatter.dart';
import 'video_player_base.dart';

class PreloadedVideoItem extends VideoPlayerBase {
  final VideoPlayerController controller;
  final bool isVisible;

  const PreloadedVideoItem({
    super.key,
    required super.index,
    required this.controller,
    super.username = '',
    super.description = '',
    super.hashtags = const [],
    super.likeCount = 0,
    super.commentCount = 0,
    super.bookmarkCount = 0,
    super.shareCount = 0,
    required this.isVisible,
    super.profileImageUrl,
    super.onLikePressed,
    super.onBookmarkPressed,
    super.onSharePressed,
    super.onProfilePressed,
    super.onUsernameTap,
    super.onHashtagTap,
    super.authorDid,
    super.isLiked = false,
    super.isSprk = false,
    super.videoUri,
  });

  @override
  State<PreloadedVideoItem> createState() => _PreloadedVideoItemState();
}

class _PreloadedVideoItemState extends VideoPlayerBaseState<PreloadedVideoItem> with WidgetsBindingObserver {
  bool _wasPlaying = false;
  bool _isFirstBuild = true;
  bool _isDescriptionExpanded = false;

  @override
  VideoPlayerController get videoController => widget.controller;

  @override
  bool get isInitialized => true; // Always initialized since controller is passed in

  @override
  bool get isVisible => widget.isVisible;

  @override
  void pauseVideo() {
    widget.controller.pause();
  }

  @override
  void playVideo() {
    widget.controller.play();
  }

  void _handleDescriptionExpandToggle(bool isExpanded) {
    setState(() {
      _isDescriptionExpanded = isExpanded;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updatePlayState();

    // Add a listener to restart the video when it ends
    widget.controller.addListener(_videoListener);
  }

  @override
  void didUpdateWidget(PreloadedVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isVisible != widget.isVisible || _isFirstBuild) {
      _isFirstBuild = false;
      _updatePlayState();

      // Immediately apply volume changes
      if (widget.isVisible) {
        widget.controller.setVolume(1.0);
      } else {
        widget.controller.setVolume(0.0);
      }
    }

    // If the controller changed, update the listener
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_videoListener);
      widget.controller.addListener(_videoListener);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app going to background/foreground
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App going to background - remember state and pause
      _wasPlaying = widget.controller.value.isPlaying;
      widget.controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      // App coming back to foreground - restore state if needed
      if (_wasPlaying && widget.isVisible && !showComments) {
        widget.controller.play();
      }
    }
  }

  void _videoListener() {
    // Loop video when it completes
    if (widget.controller.value.isCompleted && widget.isVisible && !showComments) {
      widget.controller.seekTo(Duration.zero);
      widget.controller.play();
    }
  }

  void _updatePlayState() {
    // Make sure to call after a small delay to allow state to settle
    Future.microtask(() {
      if (mounted) {
        if (widget.isVisible && !showComments) {
          widget.controller.setVolume(1.0);
          widget.controller.play();
        } else {
          widget.controller.setVolume(0.0);
          widget.controller.pause();
        }
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_videoListener);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void toggleComments() {
    widget.controller.pause();
    super.toggleComments();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred background layer
          _buildBlurredBackground(isDarkMode),

          // Main video content layer (not affected by blur)
          Center(child: _buildVideoContent()),

          // Overlay gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withAlpha(_isDescriptionExpanded ? 30 : 10),
                  Colors.black.withAlpha(_isDescriptionExpanded ? 80 : 40),
                  Colors.black.withAlpha(_isDescriptionExpanded ? 150 : 80),
                  Colors.black.withAlpha(_isDescriptionExpanded ? 200 : 160),
                ],
                stops: _isDescriptionExpanded
                    ? const [0.0, 0.4, 0.5, 0.6, 0.75, 0.9]
                    : const [0.0, 0.5, 0.65, 0.75, 0.85, 0.95],
              ),
            ),
          ),

          VideoControllerOverlay(controller: widget.controller, onTap: () {}),

          Positioned(
            bottom: 20,
            left: 10,
            right: 70, // Give space for the side action bar
            child: VideoInfoBar(
              username: widget.username,
              description: widget.description,
              hashtags: widget.hashtags,
              isSprk: widget.isSprk,
              onUsernameTap: widget.onUsernameTap,
              onHashtagTap: widget.onHashtagTap,
              onDescriptionExpandToggle: _handleDescriptionExpandToggle,
            ),
          ),

          Positioned(
            right: 10,
            bottom: 100,
            child: VideoSideActionBar(
              likeCount: TextFormatter.formatCount(widget.likeCount),
              commentCount: TextFormatter.formatCount(widget.commentCount),
              bookmarkCount: TextFormatter.formatCount(widget.bookmarkCount),
              shareCount: TextFormatter.formatCount(widget.shareCount),
              profileImageUrl: widget.profileImageUrl,
              isLiked: widget.isLiked,
              onLikePressed: widget.onLikePressed ?? () {},
              onCommentPressed: toggleComments,
              onBookmarkPressed: widget.onBookmarkPressed ?? () {},
              onSharePressed: widget.onSharePressed ?? () {},
              onProfilePressed: super.navigateToProfile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredBackground(bool isDarkMode) {
    // Create a separate widget for the blurred background only
    return Container(
      color: isDarkMode ? Colors.black : AppColors.darkBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Show a smaller, blurred version of the video in the background
          ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
              child: Transform.scale(
                scale: 1.2, // Scale up slightly to cover any edges
                child: Opacity(
                  opacity: 0.5,
                  child: VideoPlayer(widget.controller),
                ),
              ),
            ),
          ),
          // Darkened overlay
          Container(color: isDarkMode
              ? Colors.black.withAlpha(120)
              : AppColors.darkBackground.withAlpha(120)),
        ],
      ),
    );
  }

  Widget _buildVideoContent() {
    final videoSize = widget.controller.value.size;
    double aspectRatio = videoSize.width / videoSize.height;

    // For horizontal videos (landscape)
    if (aspectRatio > 1) {
      return FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: videoSize.width,
          height: videoSize.height,
          child: VideoPlayer(widget.controller)
        ),
      );
    }

    // For vertical videos (portrait)
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: videoSize.width,
          height: videoSize.height,
          child: VideoPlayer(widget.controller),
        ),
      ),
    );
  }
}