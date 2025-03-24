import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../video_side_action_bar.dart';
import '../video_info/video_info_bar.dart';
import '../video_controls/video_controller_overlay.dart';
import '../comments_tray.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_colors.dart';
import '../../screens/profile_screen.dart';

class VideoItem extends StatefulWidget {
  final int index;
  final String? videoUrl;
  final String username;
  final String description;
  final List<String> hashtags;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final int shareCount;
  final String? profileImageUrl;
  final VoidCallback? onLikePressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onUsernameTap;
  final VoidCallback? onHashtagTap;
  final String? authorDid;

  const VideoItem({
    super.key,
    required this.index,
    this.videoUrl,
    this.username = '',
    this.description = '',
    this.hashtags = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.bookmarkCount = 0,
    this.shareCount = 0,
    this.profileImageUrl,
    this.onLikePressed,
    this.onBookmarkPressed,
    this.onSharePressed,
    this.onProfilePressed,
    this.onUsernameTap,
    this.onHashtagTap,
    this.authorDid,
  });

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isVisible = false;
  final String _videoKey = UniqueKey().toString();
  bool _showComments = false;

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

  void _toggleComments() {
    if (_controller != null && _isInitialized) {
      _controller?.pause();
    }

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
          if (_isVisible && _controller != null && _isInitialized) {
            _controller?.play();
          }
        });
      },
      isDarkMode: isDarkMode,
    );
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return SizedBox.expand(
      child: VisibilityDetector(
        key: Key(_videoKey),
        onVisibilityChanged: (visibilityInfo) {
          final isVisible = visibilityInfo.visibleFraction > 0.8;

          if (isVisible != _isVisible) {
            _isVisible = isVisible;

            if (_controller != null && _isInitialized) {
              if (isVisible && !_showComments) {
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
                profileImageUrl: widget.profileImageUrl,
                onLikePressed: widget.onLikePressed ?? () {},
                onCommentPressed: _toggleComments,
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
    if (_controller!.value.aspectRatio <= 1) {
      return const SizedBox();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
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
