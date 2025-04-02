import 'dart:ui'; // For ImageFilter

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../utils/app_colors.dart';
import 'video_player_base.dart';

class PreloadedVideoItem extends VideoPlayerBase {
  final VideoPlayerController controller;
  final bool isVisible;

  const PreloadedVideoItem({
    super.key,
    required super.index,
    required this.controller,
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
    super.onCommentPressed,
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
  }) : super(videoUrl: null);

  @override
  State<PreloadedVideoItem> createState() => _PreloadedVideoItemState();
}

class _PreloadedVideoItemState extends VideoPlayerBaseState<PreloadedVideoItem> with WidgetsBindingObserver {
  bool _wasPlaying = false;

  @override
  VideoPlayerController get videoController => widget.controller;

  @override
  bool get isInitialized => widget.controller.value.isInitialized;

  @override
  bool get isVisible => widget.isVisible;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (isInitialized) {
      widget.controller.addListener(_videoListener);
      _updatePlayState();
    } else {
      widget.controller.initialize().then((_) {
        if (mounted) {
          widget.controller.addListener(_videoListener);
          _updatePlayState();
        }
      });
    }
  }

  @override
  void didUpdateWidget(PreloadedVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool controllerChanged = oldWidget.controller != widget.controller;
    bool visibilityChanged = oldWidget.isVisible != widget.isVisible;

    if (controllerChanged) {
      try {
        oldWidget.controller.removeListener(_videoListener);
      } catch (e) {
        debugPrint("Error removing listener from old controller: $e");
      }
      if (isInitialized) {
        widget.controller.addListener(_videoListener);
      } else {
        widget.controller.initialize().then((_) {
          if (mounted) {
            widget.controller.addListener(_videoListener);
            _updatePlayState();
          }
        });
      }
    }

    if ((visibilityChanged || controllerChanged) && isInitialized) {
      _updatePlayState();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!isInitialized) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _wasPlaying = widget.controller.value.isPlaying;
      pauseMedia();
    } else if (state == AppLifecycleState.resumed) {
      if (_wasPlaying && isVisible && !showComments) {
        playMedia();
      }
    }
  }

  void _videoListener() {
    if (!mounted || !isInitialized) return;

    if (widget.controller.value.isCompleted && isVisible && !showComments) {
      widget.controller.seekTo(Duration.zero);
      playMedia();
    }
    if (widget.controller.value.hasError) {
      setState(() {});
    }
  }

  void _updatePlayState() {
    Future.microtask(() {
      if (!mounted || !isInitialized) return;
      if (isVisible && !showComments) {
        widget.controller.setVolume(1.0);
        playMedia();
      } else {
        widget.controller.setVolume(0.0);
        pauseMedia();
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller.value.isInitialized) {
      try {
        widget.controller.removeListener(_videoListener);
      } catch (e) {
        debugPrint("Error removing listener from disposed controller: $e");
      }
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        super.build(context),

        if (!isInitialized) const Center(child: CircularProgressIndicator(color: AppColors.white)),
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
    return _buildVideoContent();
  }

  Widget _buildBlurredBackground(bool isDarkMode) {
    if (!isInitialized) {
      return Container(color: isDarkMode ? Colors.black : AppColors.darkBackground);
    }
    return Container(
      color: isDarkMode ? Colors.black : AppColors.darkBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!widget.disableBackgroundBlur)
            ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                child: Transform.scale(scale: 1.2, child: Opacity(opacity: 0.5, child: VideoPlayer(widget.controller))),
              ),
            ),
          Container(color: isDarkMode ? Colors.black.withAlpha(120) : AppColors.darkBackground.withAlpha(120)),
        ],
      ),
    );
  }

  Widget _buildVideoContent() {
    if (!isInitialized) {
      return const Center(child: CircularProgressIndicator(color: AppColors.white));
    }
    final videoSize = widget.controller.value.size;
    if (videoSize.width <= 0 || videoSize.height <= 0) {
      return const Center(child: Text("Invalid video size", style: TextStyle(color: Colors.white)));
    }
    double aspectRatio = videoSize.width / videoSize.height;

    if (aspectRatio > 1) {
      return FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(width: videoSize.width, height: videoSize.height, child: VideoPlayer(widget.controller)),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(width: videoSize.width, height: videoSize.height, child: VideoPlayer(widget.controller)),
      ),
    );
  }
}
