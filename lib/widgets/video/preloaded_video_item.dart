import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../video_controls/video_controller_overlay.dart';
import '../video_info/video_info_bar.dart';
import '../video_side_action_bar.dart';
import '../comments_tray.dart';
import '../../utils/app_colors.dart';

class PreloadedVideoItem extends StatefulWidget {
  final int index;
  final VideoPlayerController controller;
  final String username;
  final String description;
  final List<String> hashtags;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final int shareCount;
  final bool isVisible;
  final VoidCallback? onLikePressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onUsernameTap;
  final VoidCallback? onHashtagTap;

  const PreloadedVideoItem({
    super.key,
    required this.index,
    required this.controller,
    this.username = '',
    this.description = '',
    this.hashtags = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.bookmarkCount = 0,
    this.shareCount = 0,
    required this.isVisible,
    this.onLikePressed,
    this.onBookmarkPressed,
    this.onSharePressed,
    this.onProfilePressed,
    this.onUsernameTap,
    this.onHashtagTap,
  });

  @override
  State<PreloadedVideoItem> createState() => _PreloadedVideoItemState();
}

class _PreloadedVideoItemState extends State<PreloadedVideoItem> with WidgetsBindingObserver {
  bool _showComments = false;
  bool _wasPlaying = false;
  bool _isFirstBuild = true;
  
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
      if (_wasPlaying && widget.isVisible && !_showComments) {
        widget.controller.play();
      }
    }
  }
  
  void _videoListener() {
    // Loop video when it completes
    if (widget.controller.value.isCompleted && widget.isVisible && !_showComments) {
      widget.controller.seekTo(Duration.zero);
      widget.controller.play();
    }
  }
  
  void _updatePlayState() {
    // Make sure to call after a small delay to allow state to settle
    Future.microtask(() {
      if (mounted) {
        if (widget.isVisible && !_showComments) {
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
  
  void _toggleComments() {
    widget.controller.pause();

    setState(() {
      _showComments = true;
    });

    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    showCommentsTray(
      context: context,
      videoId: 'video_${widget.index + 1}',
      commentCount: widget.commentCount,
      onClose: () {
        setState(() {
          _showComments = false;
          if (widget.isVisible) {
            widget.controller.play();
          }
        });
      },
      isDarkMode: isDarkMode,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBlurredBackground(isDarkMode),

          Center(child: _buildVideoContent()),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withAlpha(10),
                    Colors.black.withAlpha(40),
                    Colors.black.withAlpha(80),
                    Colors.black.withAlpha(160),
                  ],
                  stops: const [0.0, 0.5, 0.65, 0.75, 0.85, 0.95],
                ),
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
              onUsernameTap: widget.onUsernameTap,
              onHashtagTap: widget.onHashtagTap,
            ),
          ),

          Positioned(
            right: 10,
            bottom: 100,
            child: VideoSideActionBar(
              likeCount: '${widget.likeCount}K',
              commentCount: '${widget.commentCount}K',
              bookmarkCount: '${widget.bookmarkCount}K',
              shareCount: '${widget.shareCount}K',
              onLikePressed: widget.onLikePressed ?? () {},
              onCommentPressed: _toggleComments,
              onBookmarkPressed: widget.onBookmarkPressed ?? () {},
              onSharePressed: widget.onSharePressed ?? () {},
              onProfilePressed: widget.onProfilePressed ?? () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredBackground(bool isDarkMode) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: widget.controller.value.size.width,
            height: widget.controller.value.size.height,
            child: VideoPlayer(widget.controller),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
          child: Container(color: isDarkMode ? Colors.black.withAlpha(128) : AppColors.darkBackground.withAlpha(128)),
        ),
      ],
    );
  }

  Widget _buildVideoContent() {
    final videoSize = widget.controller.value.size;
    double aspectRatio = videoSize.width / videoSize.height;

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

    return AspectRatio(
      aspectRatio: aspectRatio, 
      child: VideoPlayer(widget.controller)
    );
  }
} 