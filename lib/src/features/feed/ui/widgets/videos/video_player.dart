import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/feed_video_better_player_layout.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_frame.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_progress_bar.dart';

bool hasRenderableFeedVideoPlaybackFrame(VideoPlayerValue value) {
  final size = value.size;
  return value.initialized &&
      value.isPlaying &&
      value.position > Duration.zero &&
      size != null &&
      size.width > 0 &&
      size.height > 0;
}

class PostVideoPlayer extends StatefulWidget {
  const PostVideoPlayer({
    required this.videoUrl,
    required this.thumbnail,
    required this.isActive,
    super.key,
    this.videoAspectRatio,
  });

  final String videoUrl;
  final String thumbnail;
  final bool isActive;
  final double? videoAspectRatio;

  @override
  State<PostVideoPlayer> createState() => PostVideoPlayerState();
}

class PostVideoPlayerState extends State<PostVideoPlayer>
    with TickerProviderStateMixin {
  BetterPlayerController? videoController;
  bool _userInteracted = false;
  bool _showThumbnailOverlay = true;
  bool _showPlayButton = false;
  bool _shouldResumeWhenEligible = false;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

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
  bool get _isPlaybackEligible => widget.isActive;

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
  }

  void pauseVideo() {
    if (videoController?.isPlaying() ?? false) {
      videoController?.pause();
      setState(() {
        _userInteracted = true;
        _showPlayButton = true;
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
      _showPlayButton = false;
    }
    if (oldWidget.videoAspectRatio != widget.videoAspectRatio) {
      _syncPlayerLayout();
    }
    if (oldWidget.isActive != widget.isActive) {
      _syncPlaybackWithEligibility();
    }
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
        if (_showPlayButton) {
          setState(() {
            _showPlayButton = false;
          });
        }
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
      _syncPlaybackWithEligibility();
    } catch (e) {
      if (!mounted) return;
    }
  }

  void _syncPlaybackWithEligibility() {
    if (!isInitialized) return;

    if (!_isPlaybackEligible) {
      _shouldResumeWhenEligible = _shouldResumeWhenEligible || isPlaying;
      if (isPlaying) {
        videoController?.pause();
      }
      return;
    }

    if (_shouldResumeWhenEligible) {
      _shouldResumeWhenEligible = false;
      if (!isPlaying) {
        videoController?.play();
      }
      return;
    }

    if (!_userInteracted && !isPlaying) {
      videoController?.play();
    }
  }

  void _videoValueListener() {
    if (!mounted) return;
    final controller = videoController;
    if (controller == null) return;
    final videoValue = controller.videoPlayerController?.value;
    if (videoValue == null) return;
    final videoSize = videoValue.size;
    _syncPlayerLayout(controller: controller, videoSize: videoSize);

    final shouldHideThumbnail =
        _showThumbnailOverlay &&
        hasRenderableFeedVideoPlaybackFrame(videoValue);
    final shouldUpdateVideoSize = _playerVideoSize != videoSize;
    if (!shouldHideThumbnail && !shouldUpdateVideoSize) return;

    setState(() {
      if (shouldHideThumbnail) {
        _showThumbnailOverlay = false;
      }
      if (shouldUpdateVideoSize) {
        _playerVideoSize = videoSize;
      }
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

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      // Show thumbnail while video is initializing
      return FeedVideoThumbnailFrame(
        thumbnail: widget.thumbnail,
        videoAspectRatio: _knownVideoAspectRatio,
      );
    }

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
                setState(() {
                  _showPlayButton = true;
                });
                videoController?.pause();
              } else {
                setState(() {
                  _showPlayButton = false;
                });
                videoController?.play();
              }
            },
            child: Container(color: Colors.transparent),
          ),
        ),
        if (_showPlayButton)
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
