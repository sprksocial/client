import 'dart:ui'; // For ImageFilter

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../utils/app_colors.dart';
import 'video_player_base.dart';

class VideoItem extends VideoPlayerBase {
  @override
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
    super.postUri,
    super.postCid,
    super.disableBackgroundBlur = false,
  });

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends VideoPlayerBaseState<VideoItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isVisible = false;
  final String _videoKey = UniqueKey().toString();

  @override
  VideoPlayerController? get videoController => _controller;

  @override
  bool get isInitialized => _isInitialized && _controller != null;

  @override
  bool get isVisible => _isVisible;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    if (widget.videoUrl == null) return;

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isInitialized = true;
          if (isVisible) {
            playMedia();
          }
        });
      });

    _controller?.addListener(() {
      if (_controller == null || !_controller!.value.isInitialized) return;
      if (_controller!.value.position >= _controller!.value.duration) {
        _controller?.seekTo(Duration.zero);
        playMedia();
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(_videoKey),
      onVisibilityChanged: (visibilityInfo) {
        final newVisibility = visibilityInfo.visibleFraction > 0.8;

        if (newVisibility == _isVisible || !mounted) return;

        setState(() {
          _isVisible = newVisibility;
        });

        if (_isInitialized) {
          if (_isVisible) {
            playMedia();
          } else {
            pauseMedia();
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          super.build(context),

          if (widget.videoUrl != null && !_isInitialized) const Center(child: CircularProgressIndicator(color: AppColors.white)),
        ],
      ),
    );
  }

  @override
  Widget buildBackground(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return _buildBlurredBackground(isDarkMode);
  }

  @override
  Widget buildContent(BuildContext context) {
    if (widget.videoUrl != null && _controller != null && _isInitialized) {
      return _buildVideoContent();
    }
    return _buildPlaceholderContent(context);
  }

  Widget _buildBlurredBackground(bool isDarkMode) {
    return Container(
      color: isDarkMode ? Colors.black : AppColors.darkBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!widget.disableBackgroundBlur && _controller != null && _isInitialized)
            ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                child: Transform.scale(scale: 1.2, child: Opacity(opacity: 0.5, child: VideoPlayer(_controller!))),
              ),
            ),
          Container(color: isDarkMode ? Colors.black.withAlpha(120) : AppColors.darkBackground.withAlpha(120)),
        ],
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_controller == null || !_isInitialized) {
      return _buildPlaceholderContent(context);
    }

    final videoSize = _controller!.value.size;
    if (videoSize.width <= 0 || videoSize.height <= 0) {
      return _buildPlaceholderContent(context);
    }
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
        child: SizedBox(width: videoSize.width, height: videoSize.height, child: VideoPlayer(_controller!)),
      ),
    );
  }

  Widget _buildPlaceholderContent(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      color:
          widget.index % 2 == 0
              ? (isDarkMode ? Colors.indigo.shade900 : Colors.indigo.shade200)
              : (isDarkMode ? Colors.purple.shade900 : Colors.purple.shade200),
      child: const SizedBox.shrink(),
    );
  }
}
