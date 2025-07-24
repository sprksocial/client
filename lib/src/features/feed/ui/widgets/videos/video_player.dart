import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/providers/feed_provider.dart';
import 'package:sparksocial/src/features/home/providers/navigation_provider.dart';

class PostVideoPlayer extends ConsumerStatefulWidget {
  const PostVideoPlayer({required this.videoUrl, required this.thumbnail, super.key, this.feed, this.index});

  final String videoUrl;
  final String thumbnail;
  final Feed? feed;
  final int? index;

  @override
  ConsumerState<PostVideoPlayer> createState() => PostVideoPlayerState();
}

class PostVideoPlayerState extends ConsumerState<PostVideoPlayer> with TickerProviderStateMixin {
  BetterPlayerController? videoController;
  bool _userInteracted = false; // Track if user manually played/paused

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // State tracking to prevent unnecessary play/pause cycles
  int? _lastNavigationIndex;
  int? _lastFeedIndex;

  bool get isPlaying => videoController?.isPlaying() ?? false;
  bool get isInitialized => videoController?.isVideoInitialized() ?? false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _bounceAnimation = Tween<double>(
      begin: 1,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut));
    initVideoPlayer();
  }

  void pauseVideo() {
    if (videoController?.isPlaying() ?? false) {
      videoController?.pause();
      setState(() {
        _userInteracted = true; // Mark as user interaction to prevent auto-resume
      });
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    videoController?.dispose();
    super.dispose();
  }

  void _videoListener(BetterPlayerEvent event) {
    if (mounted) {
      final paused = event.betterPlayerEventType == BetterPlayerEventType.pause;

      if (paused) {
        _bounceController.reset();
        _bounceController.forward();
      }
    }
  }

  Future<void> initVideoPlayer() async {
    try {
      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.videoUrl,
        // don't use placeholder because then the video straight up never loads
        videoFormat: BetterPlayerVideoFormat.hls,
        videoExtension: 'm3u8',
        bufferingConfiguration: BetterPlayerBufferingConfiguration(
          minBufferMs: const Duration(seconds: 10).inMilliseconds,
          maxBufferMs: const Duration(seconds: 60).inMilliseconds,
        ),
        cacheConfiguration: BetterPlayerCacheConfiguration(
          useCache: true,
          preCacheSize: 20 * 1024 * 1024, // 20 MB
          maxCacheSize: 1024 * 1024 * 1024, // 1 GB
          key: widget.videoUrl,
        ),
      );
      final videoControllerTemp = BetterPlayerController(
        const BetterPlayerConfiguration(
          controlsConfiguration: BetterPlayerControlsConfiguration(
            showControls: false,
            playerTheme: BetterPlayerTheme.custom,
          ),
          looping: true,
          fit: BoxFit.contain,
          expandToFill: false,
        ),
      );
      videoControllerTemp.setupDataSource(dataSource);
      videoControllerTemp.addEventsListener(_videoListener);
      if (!mounted) return;
      setState(() {
        videoController = videoControllerTemp;
      });
    } catch (e) {
      if (!mounted) return;
    }
  }

  void _handleAutoPlayPause(bool shouldPlay) {
    if (_userInteracted) return;

    if (shouldPlay && !isPlaying) {
      videoController?.play();
    } else if (!shouldPlay && isPlaying) {
      videoController?.pause();
    }
  }

  void _handleNavigationPause(bool isOnFeedsTab) {
    if (!isInitialized) return;

    // Always pause when not on feeds tab, regardless of user interaction
    if (!isOnFeedsTab && isPlaying) {
      videoController?.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // Watch navigation state - handle changes only when they actually occur
    final navigationState = ref.watch(navigationProvider);
    final isOnFeedsTab = navigationState.currentIndex == 0;

    // Watch feed state for auto-play logic - handle changes only when they actually occur
    final feedState = widget.feed != null ? ref.watch(feedNotifierProvider(widget.feed!)) : null;

    // Handle navigation changes only when they actually change
    if (_lastNavigationIndex != navigationState.currentIndex) {
      _lastNavigationIndex = navigationState.currentIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleNavigationPause(isOnFeedsTab);
        }
      });
    }

    // Handle feed index changes only when they actually change
    if (feedState != null && _lastFeedIndex != feedState.index) {
      _lastFeedIndex = feedState.index;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_userInteracted) {
          final shouldPlay = feedState.index == widget.index && isOnFeedsTab;
          _handleAutoPlayPause(shouldPlay);
        }
      });
    } else if (widget.feed == null && widget.index == null) {
      _handleAutoPlayPause(true);
    }

    return GestureDetector(
      onTap: () {
        _userInteracted = true; // User manually interacted
        if (isPlaying) {
          videoController?.pause();
        } else {
          videoController?.play();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: BetterPlayer(controller: videoController!)),
          Center(
            child: AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isPlaying ? 1.0 : _bounceAnimation.value,
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 50,
                    color: isPlaying ? Colors.transparent : AppColors.white,
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87.withAlpha(100), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
