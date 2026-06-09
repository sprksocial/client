import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/utils/logging/logging.dart';
import 'package:spark/src/features/feed/providers/feed_provider.dart';
import 'package:spark/src/features/feed/providers/feed_state.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/feed_video_better_player_layout.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_frame.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_progress_bar.dart';
import 'package:spark/src/features/home/providers/feed_settings_visibility_provider.dart';
import 'package:spark/src/features/home/providers/navigation_provider.dart';
import 'package:spark/src/features/profile/providers/profile_feed_index_provider.dart';

class PostVideoPlayer extends ConsumerStatefulWidget {
  const PostVideoPlayer({
    required this.videoUrl,
    required this.thumbnail,
    super.key,
    this.videoAspectRatio,
    this.feed,
    this.index,
    this.profileFeedUri,
    this.isInitialPost = false,
  });

  final String videoUrl;
  final String thumbnail;
  final double? videoAspectRatio;
  final Feed? feed;
  final int? index;

  /// The profile URI for standalone profile feed visibility tracking.
  /// When [index] provided, uses profile feed index provider not feed provider
  final String? profileFeedUri;

  /// Whether this is the initial post that was clicked on.
  /// Used to trigger autoplay before the provider is fully initialized.
  final bool isInitialPost;

  @override
  ConsumerState<PostVideoPlayer> createState() => PostVideoPlayerState();
}

class PostVideoPlayerState extends ConsumerState<PostVideoPlayer>
    with TickerProviderStateMixin {
  BetterPlayerController? videoController;
  bool _userInteracted = false;
  bool _showThumbnailOverlay = true;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  int? _lastNavigationIndex;
  int? _lastFeedIndex;
  bool? _lastFeedSettingsVisible;
  bool _wasPlayingWhenMenuOpened = false;
  Size? _playerVideoSize;
  double? _lastAppliedPlayerAspectRatio;
  BoxFit? _lastAppliedPlayerFit;

  bool get isPlaying => videoController?.isPlaying() ?? false;
  bool get isInitialized => videoController?.isVideoInitialized() ?? false;
  double? get _knownVideoAspectRatio =>
      (widget.videoAspectRatio != null && widget.videoAspectRatio! > 0)
      ? widget.videoAspectRatio!
      : null;
  double? get _resolvedVideoAspectRatio =>
      feedVideoAspectRatioFromSize(_playerVideoSize) ?? _knownVideoAspectRatio;
  BoxFit get _resolvedVideoFit =>
      feedVideoFitForAspectRatio(_resolvedVideoAspectRatio);
  Size? get _resolvedVideoFrameSize => feedVideoFrameSize(
    videoSize: _playerVideoSize,
    aspectRatio: _resolvedVideoAspectRatio,
  );

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1, end: 1.3).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    initVideoPlayer();
    GetIt.I<LogService>()
        .getLogger('PostVideoPlayer')
        .i('Initialized PostVideoPlayer with video URL: ${widget.videoUrl}');
  }

  void pauseVideo() {
    if (videoController?.isPlaying() ?? false) {
      videoController?.pause();
      setState(() {
        _userInteracted = true;
      });
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    videoController?.videoPlayerController?.removeListener(_videoValueListener);
    videoController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PostVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _showThumbnailOverlay = true;
    }
    if (oldWidget.videoAspectRatio != widget.videoAspectRatio) {
      _syncPlayerLayout();
    }
  }

  void _hideThumbnailOverlay() {
    if (!_showThumbnailOverlay || !mounted) return;

    setState(() {
      _showThumbnailOverlay = false;
    });
  }

  void _videoListener(BetterPlayerEvent event) {
    if (mounted) {
      final paused = event.betterPlayerEventType == BetterPlayerEventType.pause;

      if (paused) {
        _bounceController
          ..reset()
          ..forward();
      }

      final playing = event.betterPlayerEventType == BetterPlayerEventType.play;
      if (playing) {
        _bounceController
          ..stop()
          ..value = 1.0;
      }

      final progress =
          event.betterPlayerEventType == BetterPlayerEventType.progress;
      final progressPosition = event.parameters?['progress'];
      if (progress &&
          progressPosition is Duration &&
          progressPosition > Duration.zero) {
        _hideThumbnailOverlay();
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
        feedVideoBetterPlayerConfiguration(
          aspectRatio: _knownVideoAspectRatio,
          fit: feedVideoFitForAspectRatio(_knownVideoAspectRatio),
        ),
      );
      await videoControllerTemp.setupDataSource(dataSource);
      videoControllerTemp.addEventsListener(_videoListener);
      if (!mounted) {
        videoControllerTemp.dispose();
        return;
      }
      final playerVideoSize =
          videoControllerTemp.videoPlayerController?.value.size;
      _syncPlayerLayout(
        controller: videoControllerTemp,
        videoSize: playerVideoSize,
      );
      setState(() {
        videoController = videoControllerTemp;
        _playerVideoSize = playerVideoSize;
      });
      videoControllerTemp.videoPlayerController?.addListener(
        _videoValueListener,
      );
    } catch (e) {
      if (!mounted) return;
    }
  }

  void _handleAutoPlayPause(
    bool shouldPlay, {
    bool isFeedSettingsVisible = false,
  }) {
    if (_userInteracted) return;

    // Don't play if feed settings menu is open
    if (isFeedSettingsVisible) {
      if (isPlaying) {
        videoController?.pause();
      }
      return;
    }

    if (shouldPlay && !isPlaying) {
      videoController?.play();
    } else if (!shouldPlay && isPlaying) {
      videoController?.pause();
    }
  }

  void _videoValueListener() {
    if (!mounted) return;
    final controller = videoController;
    if (controller == null) return;
    final videoSize = controller.videoPlayerController?.value.size;
    _syncPlayerLayout(controller: controller, videoSize: videoSize);

    if (_playerVideoSize == videoSize) return;
    setState(() {
      _playerVideoSize = videoSize;
    });
  }

  void _syncPlayerLayout({
    BetterPlayerController? controller,
    Size? videoSize,
  }) {
    final effectiveController = controller ?? videoController;
    if (effectiveController == null) return;

    final aspectRatio =
        feedVideoAspectRatioFromSize(videoSize ?? _playerVideoSize) ??
        _knownVideoAspectRatio;
    final fit = feedVideoFitForAspectRatio(aspectRatio);

    if (_lastAppliedPlayerAspectRatio != aspectRatio ||
        _lastAppliedPlayerFit != fit) {
      applyFeedVideoBetterPlayerLayout(
        effectiveController,
        aspectRatio: aspectRatio,
        fit: fit,
      );
      _lastAppliedPlayerAspectRatio = aspectRatio;
      _lastAppliedPlayerFit = fit;
    }
  }

  void _handleNavigationVisibility(
    bool isOnFeedsTab, {
    required bool shouldPlay,
    required bool isFeedSettingsVisible,
  }) {
    if (!isInitialized) return;

    // Always pause when not on feeds tab, regardless of user interaction
    if (!isOnFeedsTab && isPlaying) {
      videoController?.pause();
      return;
    }

    if (isOnFeedsTab) {
      _handleAutoPlayPause(
        shouldPlay,
        isFeedSettingsVisible: isFeedSettingsVisible,
      );
    }
  }

  void _handleFeedSettingsVisibility(
    bool isFeedSettingsVisible,
    bool isOnFeedsTab,
    FeedState? feedState,
  ) {
    if (!isInitialized) return;

    // Pause videos when feed settings menu is open
    if (isFeedSettingsVisible && isPlaying) {
      _wasPlayingWhenMenuOpened = true;
      videoController?.pause();
    }
    // Resume videos when feed settings menu closes
    // Resume if it was playing when menu opened or if auto-play conditions met
    else if (!isFeedSettingsVisible) {
      final wasPlaying = _wasPlayingWhenMenuOpened;
      _wasPlayingWhenMenuOpened = false;

      if (wasPlaying && !isPlaying) {
        // Resume if it was playing when menu opened
        videoController?.play();
      } else if (!_userInteracted) {
        // Otherwise, check auto-play conditions
        final shouldPlay =
            isOnFeedsTab &&
            (feedState == null || feedState.index == widget.index);
        if (shouldPlay && !isPlaying) {
          videoController?.play();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      // Show thumbnail while video is initializing
      return FeedVideoThumbnailFrame(
        thumbnail: widget.thumbnail,
        videoAspectRatio: _knownVideoAspectRatio,
      );
    }

    final navigationState = ref.watch(navigationProvider);
    final isOnFeedsTab = navigationState.currentIndex == 0;
    final feedSettingsVisible = ref.watch(feedSettingsVisibilityProvider);

    final feedState = widget.feed != null
        ? ref.watch(feedProvider(widget.feed!))
        : null;
    final profileFeedIndex = widget.profileFeedUri != null
        ? ref.watch(profileFeedIndexProvider(widget.profileFeedUri!))
        : null;

    if (_lastNavigationIndex != navigationState.currentIndex) {
      _lastNavigationIndex = navigationState.currentIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final shouldPlay = feedState != null
              ? feedState.index == widget.index
              : profileFeedIndex != null && widget.index != null
              ? profileFeedIndex == widget.index ||
                    (profileFeedIndex == -1 && widget.isInitialPost)
              : widget.feed == null &&
                    widget.index == null &&
                    widget.profileFeedUri == null;
          _handleNavigationVisibility(
            isOnFeedsTab,
            shouldPlay: shouldPlay,
            isFeedSettingsVisible: feedSettingsVisible,
          );
        }
      });
    }

    // Handle feed settings visibility changes
    if (_lastFeedSettingsVisible != feedSettingsVisible) {
      _lastFeedSettingsVisible = feedSettingsVisible;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleFeedSettingsVisibility(
            feedSettingsVisible,
            isOnFeedsTab,
            feedState,
          );
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (feedState != null && _lastFeedIndex != feedState.index) {
        _lastFeedIndex = feedState.index;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_userInteracted) {
            final shouldPlay = feedState.index == widget.index && isOnFeedsTab;
            _handleAutoPlayPause(
              shouldPlay,
              isFeedSettingsVisible: feedSettingsVisible,
            );
          }
        });
      } else if (profileFeedIndex != null && widget.index != null) {
        // Profile feed visibility check
        if (profileFeedIndex == -1) {
          // Provider not initialized, use isInitialPost for initial autoplay
          if (widget.isInitialPost && _lastFeedIndex == null) {
            _lastFeedIndex = -1; // Mark as handled
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_userInteracted) {
                _handleAutoPlayPause(
                  true,
                  isFeedSettingsVisible: feedSettingsVisible,
                );
              }
            });
          }
        } else if (_lastFeedIndex != profileFeedIndex) {
          _lastFeedIndex = profileFeedIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_userInteracted) {
              final shouldPlay = profileFeedIndex == widget.index;
              _handleAutoPlayPause(
                shouldPlay,
                isFeedSettingsVisible: feedSettingsVisible,
              );
            }
          });
        }
      } else if (widget.feed == null &&
          widget.index == null &&
          widget.profileFeedUri == null) {
        // True standalone mode (no feed tracking at all)
        _handleAutoPlayPause(true, isFeedSettingsVisible: feedSettingsVisible);
      }
    });

    final resolvedAspectRatio = _resolvedVideoAspectRatio;
    final fitMode = _resolvedVideoFit;
    final frameSize = _resolvedVideoFrameSize;

    final thumbnailOverlay = Positioned.fill(
      child: IgnorePointer(
        child: FeedVideoThumbnailFrame(
          thumbnail: widget.thumbnail,
          videoAspectRatio: resolvedAspectRatio,
        ),
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: FeedVideoFrame(
            fit: fitMode,
            frameSize: frameSize,
            child: BetterPlayer(controller: videoController!),
          ),
        ),
        if (_showThumbnailOverlay) thumbnailOverlay,
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _userInteracted = true;
              if (isPlaying) {
                videoController?.pause();
              } else {
                videoController?.play();
              }
            },
            child: Container(color: Colors.transparent),
          ),
        ),
        Center(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isPlaying ? 0.0 : _bounceAnimation.value,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: AppIcons.play(),
                  ),
                );
              },
            ),
          ),
        ),
        if (videoController != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FeedVideoProgressBar(
              controller: videoController!,
              onSeekStart: (_) => _userInteracted = true,
              onSeekEnd: (d) =>
                  videoController?.videoPlayerController?.seekTo(d),
            ),
          ),
      ],
    );
  }
}
