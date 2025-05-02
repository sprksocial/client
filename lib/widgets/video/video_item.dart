import 'dart:developer';
import 'dart:io';
import 'dart:ui'; // For ImageFilter

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../utils/app_colors.dart';
import 'video_player_base.dart';

class VideoItem extends VideoPlayerBase {
  final VideoPlayerController? preloadedController;
  final String? localVideoPath;
  final bool isVisible;

  const VideoItem({
    super.key,
    required super.index,
    required super.videoUrl,
    super.videoAlt,
    this.preloadedController,
    this.localVideoPath,
    required this.isVisible,
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
    super.onPostDeleted,
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

  @override
  VideoPlayerController? get videoController => _controller;

  @override
  bool get isInitialized => _isInitialized && _controller != null;

  @override
  bool get isVisible => widget.isVisible;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void didUpdateWidget(VideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isVisible != widget.isVisible) {
      _updatePlayState();
    }
    if (oldWidget.preloadedController != widget.preloadedController ||
        oldWidget.videoUrl != widget.videoUrl ||
        oldWidget.localVideoPath != widget.localVideoPath) {
      _initializeVideoPlayer();
    }
  }

  @override
  void dispose() {
    if (_controller != null && _controller != widget.preloadedController) {
      _controller!.dispose();
    }
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    if (_controller != null && _controller != widget.preloadedController) {
      await _controller!.dispose();
      _controller = null;
      _isInitialized = false;
    }

    if (widget.videoUrl == null && widget.localVideoPath == null) {
      setStateIfMounted(() {});
      return;
    }

    bool controllerNeedsInit = false;

    if (widget.preloadedController != null) {
      _controller = widget.preloadedController;
      _isInitialized = _controller!.value.isInitialized;
      if (!_isInitialized) {
        debugPrint("VideoItem received uninitialized preloaded controller for index ${widget.index}");
      }
    } else if (widget.localVideoPath != null) {
      try {
        _controller = VideoPlayerController.file(File(widget.localVideoPath!));
        controllerNeedsInit = true;
      } catch (e) {
        log('Failed to create local video controller: $e');
        _controller = null;
      }
    } else if (widget.videoUrl != null) {
      try {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
        controllerNeedsInit = true;
      } catch (e) {
        log('Failed to create network video controller: $e');
        _controller = null;
      }
    }

    if (_controller != null && controllerNeedsInit) {
      try {
        await _controller!.initialize();
        _isInitialized = true;
        _controller!.setLooping(true);
      } catch (e) {
        log('Failed to initialize video controller for index ${widget.index}: $e');
        _isInitialized = false;
        await _controller?.dispose();
        _controller = null;
      }
    }

    setStateIfMounted(() {});
    _updatePlayState();
  }

  void _updatePlayState() {
    if (!mounted || !_isInitialized || _controller == null) return;

    if (widget.isVisible) {
      playMedia();
    } else {
      pauseMedia();
    }
  }

  void setStateIfMounted(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        super.build(context),
        if (widget.videoUrl != null && widget.localVideoPath == null && widget.preloadedController == null && !_isInitialized)
          const Center(child: CircularProgressIndicator(color: AppColors.white)),
      ],
    );
  }

  @override
  Widget buildBackground(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return _buildBlurredBackground(isDarkMode);
  }

  @override
  Widget buildContent(BuildContext context) {
    if (_controller != null && _isInitialized) {
      return _buildVideoContent();
    }
    return _buildPlaceholderContent(context);
  }

  Widget _buildBlurredBackground(bool isDarkMode) {
    if (!_isInitialized || widget.disableBackgroundBlur) {
      return Container(color: isDarkMode ? Colors.black : AppColors.darkBackground);
    }

    return Container(
      color: isDarkMode ? Colors.black : AppColors.darkBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Transform.scale(scale: 1.1, child: Opacity(opacity: 0.4, child: VideoPlayer(_controller!))),
            ),
          ),
          Container(color: isDarkMode ? Colors.black.withAlpha(100) : AppColors.darkBackground.withAlpha(100)),
        ],
      ),
    );
  }

  Widget _buildVideoContent() {
    final videoSize = _controller!.value.size;
    if (videoSize.width <= 0 || videoSize.height <= 0) {
      return _buildPlaceholderContent(context);
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(width: videoSize.width, height: videoSize.height, child: VideoPlayer(_controller!)),
      ),
    );
  }

  Widget _buildPlaceholderContent(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      color:
          widget.index.isEven
              ? (isDarkMode ? Colors.indigo.shade900 : Colors.indigo.shade200)
              : (isDarkMode ? Colors.purple.shade900 : Colors.purple.shade200),
      child: const SizedBox.shrink(),
    );
  }
}
