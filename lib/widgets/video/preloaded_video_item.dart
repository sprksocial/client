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
    // Add listener immediately
    widget.controller.addListener(_videoListener);
    // Initialize if needed, then update play state
    if (!isInitialized) {
      widget.controller.initialize().then((_) {
        if (mounted) {
          _updatePlayState();
          setState(() {}); // Trigger rebuild once initialized
        }
      });
    } else {
      // Already initialized, just update play state
      _updatePlayState();
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
      // Add listener to the new controller
      widget.controller.addListener(_videoListener);
      // If new controller isn't initialized, initialize it
      if (!isInitialized) {
        widget.controller.initialize().then((_) {
          if (mounted) {
            _updatePlayState();
            setState(() {}); // Trigger rebuild
          }
        });
      } else {
        // If already initialized, update play state immediately
        _updatePlayState();
      }
    } else if (visibilityChanged) {
      // Only visibility changed, update play state if initialized
      if (isInitialized) {
        _updatePlayState();
      }
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
    if (!mounted) return;

    // Check initialization state in the listener too
    final bool currentlyInitialized = widget.controller.value.isInitialized;

    // If the initialization state changed, trigger a rebuild
    if (currentlyInitialized != _lastKnownInitializedState) {
      setState(() {
        _lastKnownInitializedState = currentlyInitialized;
      });
    }

    if (!currentlyInitialized) return;

    // Handle looping
    if (widget.controller.value.isCompleted && isVisible && !showComments) {
      widget.controller.seekTo(Duration.zero);
      playMedia(); // Ensure it plays after seeking
    }
    // Handle errors
    if (widget.controller.value.hasError && !_errorShown) {
      setState(() {
        _errorShown = true; // Prevent continuous rebuilds on error
      });
      debugPrint("VideoPlayer Error: ${widget.controller.value.errorDescription}");
    }
  }

  bool _lastKnownInitializedState = false;
  bool _errorShown = false;

  void _updatePlayState() {
    // Run after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    // Remove listener safely
    // The controller itself is disposed by VideoPlayerScreen
    try {
      widget.controller.removeListener(_videoListener);
    } catch (e) {
      debugPrint("Error removing listener during dispose: $e");
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Base build method handles background, content, and overlays
    return super.build(context);
    // Removed redundant loading indicator check here
  }

  @override
  Widget buildBackground(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return _buildBlurredBackground(isDarkMode);
  }

  @override
  Widget buildContent(BuildContext context) {
    // Build video content and overlay loading indicator if needed
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildVideoContent(), // Always build the player if controller exists
        // Show loading indicator if controller is not yet initialized by the video_player package
        if (!isInitialized && !widget.controller.value.hasError) const CircularProgressIndicator(color: AppColors.white),
        // Show error icon if controller has error
        if (widget.controller.value.hasError) const Icon(Icons.error_outline, color: Colors.white70, size: 48.0),
      ],
    );
  }

  Widget _buildBlurredBackground(bool isDarkMode) {
    // Use a placeholder color if not initialized or background blur disabled
    if (widget.disableBackgroundBlur || !isInitialized) {
      return Container(color: isDarkMode ? Colors.black : AppColors.darkBackground);
    }
    return Container(
      color: isDarkMode ? Colors.black : AppColors.darkBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ensure VideoPlayer is built for blur effect only if initialized
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
    // Don't need isInitialized check here, handled by the overlay in buildContent
    // Check for valid size *after* initialization
    if (isInitialized) {
      final videoSize = widget.controller.value.size;
      if (videoSize.width <= 0 || videoSize.height <= 0) {
        // Return error/placeholder if size is invalid after init
        return const Center(child: Text("Invalid video size", style: TextStyle(color: Colors.white)));
      }
      // Use contain fit for video playback
      return FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(width: videoSize.width, height: videoSize.height, child: VideoPlayer(widget.controller)),
      );
    } else {
      // Return an empty container or placeholder while initializing
      // The loading indicator is handled by the Stack in buildContent
      return Container();
    }
  }
}
