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

  const VideoItem({
    super.key,
    required super.index,
    required this.videoUrl,
    this.videoAlt,
    this.preloadedController,
    this.localVideoPath,
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

class _VideoItemState extends VideoPlayerBaseState<VideoItem> with RouteAware {
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

  Future<void> _initializeVideoPlayer() async {
    if (widget.videoUrl == null && widget.localVideoPath == null) return;

    if (widget.preloadedController != null) {
      _controller = widget.preloadedController;
      if (_controller!.value.isInitialized) {
        setState(() {
          _isInitialized = true;
        });
        if (_isVisible) {
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

        if (_isVisible) {
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

      if (_isVisible) {
        playMedia();
      }
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.8;
    if (!mounted || visible == _isVisible) return;

    setState(() {
      _isVisible = visible;
    });

    if (_isInitialized) {
      if (_isVisible) {
        playMedia();
      } else {
        pauseMedia();
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
