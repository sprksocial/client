import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/core/utils/logging/logging.dart';
import 'package:spark/src/features/feed/providers/feed_provider.dart';
import 'package:spark/src/features/feed/providers/feed_state.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_progress_bar.dart';
import 'package:spark/src/features/home/providers/feed_settings_visibility_provider.dart';
import 'package:spark/src/features/home/providers/navigation_provider.dart';
import 'package:spark/src/features/profile/providers/profile_feed_index_provider.dart';

class PostVideoPlayer extends ConsumerStatefulWidget {
  const PostVideoPlayer({
    required this.videoUrl,
    required this.thumbnail,
    super.key,
    this.feed,
    this.index,
    this.profileFeedUri,
    this.isInitialPost = false,
  });

  final String videoUrl;
  final String thumbnail;
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

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  int? _lastNavigationIndex;
  int? _lastFeedIndex;
  bool? _lastFeedSettingsVisible;
  bool _wasPlayingWhenMenuOpened = false;

  bool get isPlaying => videoController?.isPlaying() ?? false;
  bool get isInitialized => videoController?.isVideoInitialized() ?? false;

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
    videoController?.dispose();
    super.dispose();
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
          ),
          looping: true,
          fit: BoxFit.contain,
          expandToFill: false,
          allowedScreenSleep: false,
        ),
      );
      await videoControllerTemp.setupDataSource(dataSource);
      videoControllerTemp.addEventsListener(_videoListener);
      if (!mounted) return;
      setState(() {
        videoController = videoControllerTemp;
      });
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

  void _handleNavigationPause(bool isOnFeedsTab) {
    if (!isInitialized) return;

    // Always pause when not on feeds tab, regardless of user interaction
    if (!isOnFeedsTab && isPlaying) {
      videoController?.pause();
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
      return widget.thumbnail.isNotEmpty
          ? Image.network(
              widget.thumbnail,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            )
          : const DecoratedBox(
              decoration: BoxDecoration(color: AppColors.black),
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
          _handleNavigationPause(isOnFeedsTab);
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

    final videoAspectRatio =
        videoController?.videoPlayerController?.value.aspectRatio;
    final videoSize = videoController?.videoPlayerController?.value.size;

    final shouldFillScreen =
        videoAspectRatio != null &&
        videoAspectRatio > 0.5 &&
        videoAspectRatio < 0.7;
    final fitMode = shouldFillScreen ? BoxFit.cover : BoxFit.contain;

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child:
              videoSize != null && videoSize.width > 0 && videoSize.height > 0
              ? FittedBox(
                  fit: fitMode,
                  child: SizedBox(
                    width: videoSize.width,
                    height: videoSize.height,
                    child: BetterPlayer(controller: videoController!),
                  ),
                )
              : BetterPlayer(controller: videoController!),
        ),
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
