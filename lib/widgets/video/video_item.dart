import 'dart:developer';
import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:io';

import '../../main.dart';
import '../../utils/app_colors.dart';
import 'video_player_base.dart';

class VideoItem extends VideoPlayerBase {
  @override
  final String? videoUrl;
  @override
  final String? videoAlt;
  final VideoPlayerController? preloadedController;
  final String? localVideoPath;
  final bool isVisible;

  const VideoItem({
    super.key,
    required super.index,
    required this.videoUrl,
    this.videoAlt,
    this.preloadedController,
    this.localVideoPath,
    this.isVisible = false,
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

class _VideoItemState extends VideoPlayerBaseState<VideoItem> with RouteAware, WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isVisible = false;
  bool _wasPlaying = false;
  final String _videoKey = UniqueKey().toString();

  @override
  VideoPlayerController? get videoController => _controller;

  @override
  bool get isInitialized => _isInitialized && _controller != null;

  @override
  bool get isVisible => widget.isVisible || _isVisible;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideoPlayer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ModalRoute<void>? route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    if (_controller != widget.preloadedController) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  void didPushNext() {
    pauseMedia();
  }

  @override
  void didPopNext() {
    if (_isVisible && isInitialized) {
      playMedia();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!isInitialized) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _wasPlaying = _controller?.value.isPlaying ?? false;
      pauseMedia();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the controller when app resumes
      _controller?.initialize().then((_) {
        if (mounted && _wasPlaying && isVisible && !showComments) {
          // Add a small delay to ensure the app is fully resumed
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted && isVisible && !showComments) {
              _controller?.seekTo(Duration.zero);
              _controller?.setVolume(1.0);
              playMedia();
            }
          });
        }
      });
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.5;
    if (!mounted || visible == _isVisible) return;

    setState(() {
      _isVisible = visible;
    });

    if (_isInitialized) {
      if (_isVisible) {
        // Only start playing if not already playing
        if (!(_controller?.value.isPlaying ?? false)) {
          _controller?.seekTo(Duration.zero);
          _controller?.setVolume(1.0);
          playMedia();
        }
      } else {
        _controller?.setVolume(0.0);
        pauseMedia();
      }
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (widget.videoUrl == null && widget.localVideoPath == null) return;

    if (widget.preloadedController != null) {
      _controller = widget.preloadedController;
      if (_controller!.value.isInitialized) {
        setState(() {
          _isInitialized = true;
        });
        if (isVisible) {
          _controller?.seekTo(Duration.zero);
          _controller?.setVolume(1.0);
          playMedia();
        }
        return;
      }
    }

    if (widget.localVideoPath != null) {
      try {
        _controller = VideoPlayerController.file(File(widget.localVideoPath!));
        await _controller?.initialize();

        if (!mounted) return;

        _controller?.setLooping(true);
        setState(() {
          _isInitialized = true;
        });

        if (isVisible) {
          _controller?.seekTo(Duration.zero);
          _controller?.setVolume(1.0);
          playMedia();
        }
        return;
      } catch (e) {
        log('Failed to load local video: $e');
      }
    }

    if (widget.videoUrl != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
      await _controller?.initialize();

      if (!mounted) return;

      _controller?.setLooping(true);
      setState(() {
        _isInitialized = true;
      });

      if (isVisible) {
        _controller?.seekTo(Duration.zero);
        _controller?.setVolume(1.0);
        playMedia();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(_videoKey),
      onVisibilityChanged: _onVisibilityChanged,
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

    final screenSize = MediaQuery.of(context).size;
    final videoAspectRatio = videoSize.width / videoSize.height;
    final screenAspectRatio = screenSize.width / screenSize.height;

    // Define aspect ratio thresholds
    // 9:16 ≈ 0.5625, so we'll use 0.6 as our threshold
    // This ensures vertical videos and similar aspect ratios fill the screen
    const verticalThreshold = 0.6;

    // Check if video is vertical or close to vertical
    final isVerticalVideo = videoAspectRatio <= verticalThreshold;

    if (isVerticalVideo) {
      // For vertical videos, fill the screen
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(width: videoSize.width, height: videoSize.height, child: VideoPlayer(_controller!)),
        ),
      );
    } else {
      // For other videos, maintain original proportions
      return Container(
        width: screenSize.width,
        height: screenSize.height,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(width: videoSize.width, height: videoSize.height, child: VideoPlayer(_controller!)),
        ),
      );
    }
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
