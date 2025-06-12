import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:smooth_video_progress/smooth_video_progress.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/providers/feed_provider.dart';
import 'package:sparksocial/src/features/home/providers/navigation_provider.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/time_display.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class PostVideoPlayer extends ConsumerStatefulWidget {
  const PostVideoPlayer({super.key, required this.videoUrl, this.feed, this.index});

  final String videoUrl;
  final Feed? feed;
  final int? index;

  @override
  ConsumerState<PostVideoPlayer> createState() => PostVideoPlayerState();
}

class PostVideoPlayerState extends ConsumerState<PostVideoPlayer> with TickerProviderStateMixin {
  bool isPlaying = false;
  late VideoPlayerController videoController;
  bool isInitialized = false;
  bool _userInteracted = false; // Track if user manually played/paused
  bool shouldCacheAgain = false;
  bool _cacheRequested = false; // Track if cache request has been made
  bool _isSeeking = false;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // State tracking to prevent unnecessary play/pause cycles
  int? _lastNavigationIndex;
  int? _lastFeedIndex;

  // Expose the video controller publicly
  VideoPlayerController? get controller => isInitialized ? videoController : null;

  // Add public method to pause video
  void pauseVideo() {
    if (isInitialized && videoController.value.isPlaying) {
      videoController.pause();
      setState(() {
        _userInteracted = true; // Mark as user interaction to prevent auto-resume
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut));
    initVideoPlayer();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    if (isInitialized) {
      videoController.removeListener(_videoListener);
      videoController.dispose();
    }
    super.dispose();
  }

  void _videoListener() {
    if (mounted && videoController.value.isInitialized) {
      final nowPlaying = videoController.value.isPlaying;
      if (nowPlaying != isPlaying) {
        setState(() {
          isPlaying = nowPlaying;
        });

        if (!nowPlaying) {
          _bounceController.reset();
          _bounceController.forward();
        }
      }
    }
  }

  Future<void> initVideoPlayer() async {
    final cacheManager = GetIt.I<CacheManagerInterface>();
    final file = await cacheManager.getCachedFile(widget.videoUrl);
    if (!mounted) return;
    if (file == null) {
      // start caching it again, but for the time being, use a network player
      videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      shouldCacheAgain = true;
    } else {
      videoController = VideoPlayerController.file(file, videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    }
    await videoController.initialize();
    videoController.setLooping(true);
    videoController.addListener(_videoListener);
    if (!mounted) return;
    setState(() {
      isInitialized = true;
      isPlaying = videoController.value.isPlaying;
    });
  }

  void _handleAutoPlayPause(bool shouldPlay) {
    if (!isInitialized || _userInteracted) return;

    if (shouldPlay && !videoController.value.isPlaying) {
      videoController.play();
    } else if (!shouldPlay && videoController.value.isPlaying) {
      videoController.pause();
    }
  }

  void _handleNavigationPause(bool isOnFeedsTab) {
    if (!isInitialized) return;

    // Always pause when not on feeds tab, regardless of user interaction
    if (!isOnFeedsTab && videoController.value.isPlaying) {
      videoController.pause();
    }
  }

  void _onSeekStart(double value) {
    if (!isInitialized) return;
    _isSeeking = true;
    videoController.pause();
    videoController.setVolume(0.0);
  }

  void _onSeekChanged(double value) {
    if (!isInitialized) return;
    videoController.seekTo(Duration(milliseconds: value.toInt()));
    if (videoController.value.isPlaying) {
      videoController.pause();
    }
  }

  void _onSeekEnd(double value) {
    if (!isInitialized) return;
    _isSeeking = false;
    videoController.setVolume(1.0);
    videoController.play();
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
          bool shouldPlay = feedState.index == widget.index && isOnFeedsTab;
          _handleAutoPlayPause(shouldPlay);
        }
      });
    } else if (widget.feed == null && widget.index == null) {
      _handleAutoPlayPause(true);
    }

    if (shouldCacheAgain && !_cacheRequested && widget.feed != null && widget.index != null) {
      _cacheRequested = true; // Set flag immediate to prevent multiple requests
      // Delay the provider modification until after the build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = ref.read(feedNotifierProvider(widget.feed!).notifier);
        final state = ref.read(feedNotifierProvider(widget.feed!));
        if (widget.index! < state.loadedPosts.length) {
          notifier.store([state.loadedPosts[widget.index!]]);
        }
      });
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            _userInteracted = true; // User manually interacted
            if (videoController.value.isPlaying) {
              videoController.pause();
            } else {
              videoController.play();
            }
          },
          child: Stack(
            children: [
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: videoController.value.size.width,
                    height: videoController.value.size.height,
                    child: VideoPlayer(videoController),
                  ),
                ),
              ),
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
            ],
          ),
        ),
        Positioned(
          bottom: 2,
          left: 0,
          right: 0,
          child: SmoothVideoProgress(
            controller: videoController,
            builder: (context, position, duration, child) {
              return Column(
                children: [
                  if (_isSeeking)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: TimeDisplay(
                        position: Duration(milliseconds: videoController.value.position.inMilliseconds),
                        duration: videoController.value.duration,
                      ),
                    ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.white.withAlpha(64),
                      thumbColor: AppColors.white,
                      overlayShape: SliderComponentShape.noThumb,
                      trackShape: const RoundedRectSliderTrackShape(),
                    ),
                    child: Slider(
                      value: position.inMilliseconds.toDouble(),
                      min: 0,
                      max: duration.inMilliseconds.toDouble(),
                      onChanged: _onSeekChanged,
                      onChangeStart: _onSeekStart,
                      onChangeEnd: _onSeekEnd,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
