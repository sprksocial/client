import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../video_side_action_bar.dart';
import '../video_info/video_info_bar.dart';
import '../video_controls/video_controller_overlay.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_colors.dart';
import '../../screens/profile_screen.dart';
import '../../utils/formatters/text_formatter.dart';
import 'video_player_base.dart';

class VideoItem extends VideoPlayerBase {
  final String? videoUrl;

  const VideoItem({
    super.key,
    required super.index,
    required this.videoUrl,
    super.username = '',
    super.description = '',
    super.hashtags = const [],
    super.likeCount = 0,
    super.commentCount = 0,
    super.bookmarkCount = 0,
    super.shareCount = 0,
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
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends VideoPlayerBaseState<VideoItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isVisible = false;
  bool _isDescriptionExpanded = false;
  final String _videoKey = UniqueKey().toString();

  @override
  VideoPlayerController? get videoController => _controller;

  @override
  bool get isInitialized => _isInitialized && _controller != null;

  @override
  bool get isVisible => _isVisible;

  @override
  void pauseVideo() {
    _controller?.pause();
  }

  @override
  void playVideo() {
    _controller?.play();
  }

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    if (widget.videoUrl != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
              if (_isVisible) {
                _controller?.play();
              }
            });
          }
        });

      _controller?.addListener(() {
        if (_controller!.value.position >= _controller!.value.duration) {
          _controller?.seekTo(Duration.zero);
          _controller?.play();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void toggleComments() {
    if (_controller != null && _isInitialized) {
      _controller?.pause();
    }

    super.toggleComments();
  }

  void _navigateToProfile() {
    if (widget.authorDid != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
            ProfileScreen(did: widget.authorDid),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }

    // Still call the original callback if provided
    if (widget.onProfilePressed != null) {
      widget.onProfilePressed!();
    }
  }

  void _handleDescriptionExpandToggle(bool isExpanded) {
    setState(() {
      _isDescriptionExpanded = isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return SizedBox.expand(
      child: VisibilityDetector(
        key: Key(_videoKey),
        onVisibilityChanged: (visibilityInfo) {
          final isVisible = visibilityInfo.visibleFraction > 0.8;

          if (isVisible != _isVisible && mounted) {
            setState(() {
              _isVisible = isVisible;
            });

            if (_controller != null && _isInitialized) {
              if (isVisible && !showComments) {
                _controller?.play();
              } else {
                if (mounted) {
                  _controller?.pause();
                }
              }
            }
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.videoUrl != null && _controller != null && _isInitialized) _buildBlurredBackground(isDarkMode),

            Center(child: _buildVideoContent()),

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

            if (widget.videoUrl != null && _controller != null && _isInitialized)
              VideoControllerOverlay(controller: _controller!, onTap: () {}),

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
                onProfilePressed: _navigateToProfile,
              ),
            ),

            if (widget.videoUrl != null && !_isInitialized)
              const Center(child: CircularProgressIndicator(color: AppColors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurredBackground(bool isDarkMode) {
    return Container(
      color: isDarkMode ? Colors.black : AppColors.darkBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
              child: Transform.scale(
                scale: 1.2,
                child: Opacity(
                  opacity: 0.5,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
          ),
          Container(color: isDarkMode
              ? Colors.black.withAlpha(120)
              : AppColors.darkBackground.withAlpha(120)),
        ],
      ),
    );
  }

  Widget _buildVideoContent() {
    if (widget.videoUrl != null && _controller != null && _isInitialized) {
      final videoSize = _controller!.value.size;
      double aspectRatio = videoSize.width / videoSize.height;

      if (aspectRatio > 1) {
        return FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(width: videoSize.width, height: videoSize.height, child: VideoPlayer(_controller!)),
        );
      }

      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: videoSize.width,
            height: videoSize.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      );
    }

    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Container(
      color:
          widget.index % 2 == 0
              ? (isDarkMode ? Colors.indigo.shade900 : Colors.indigo.shade200)
              : (isDarkMode ? Colors.purple.shade900 : Colors.purple.shade200),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FluentIcons.play_circle_24_regular, size: 80, color: AppTheme.getTextColor(context).withAlpha(179)),
            const SizedBox(height: 16),
            Text(
              'Video ${widget.index + 1}',
              style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
