import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/features/feed/data/video_availability_client.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/feed_video_better_player_layout.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_frame.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_loading_frame.dart';
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
  AsyncValue<void> _initialization = const AsyncLoading();
  VideoAvailabilityClient? _availabilityClient;
  Completer<void>? _loadCancelled;
  bool _userPaused = false;
  bool _showThumbnailOverlay = true;

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
    if (widget.isActive) unawaited(initVideoPlayer());
  }

  void pauseVideo() {
    if (videoController?.isPlaying() ?? false) {
      videoController?.pause();
    }
    setState(() => _userPaused = true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _releasePlayer();
    super.dispose();
  }

  @override
  void didUpdateWidget(PostVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _userPaused = false;
      _releasePlayer();
      _resetPlayback();
      if (widget.isActive) unawaited(initVideoPlayer());
      return;
    }
    if (oldWidget.videoAspectRatio != widget.videoAspectRatio) {
      _syncPlayerLayout();
    }
    if (oldWidget.isActive != widget.isActive) {
      if (_initialization.isLoading) {
        if (widget.isActive) {
          unawaited(initVideoPlayer());
        } else {
          _releasePlayer();
        }
      } else {
        _syncPlaybackWithEligibility();
      }
    }
  }

  void _releasePlayer() {
    final cancellation = _loadCancelled;
    if (cancellation != null && !cancellation.isCompleted) {
      cancellation.complete();
    }
    _loadCancelled = null;
    _availabilityClient?.close();
    _availabilityClient = null;
    videoController?.removeEventsListener(_videoListener);
    videoController?.videoPlayerController?.removeListener(_videoValueListener);
    videoController?.dispose();
    videoController = null;
  }

  void _resetPlayback() {
    _initialization = const AsyncLoading();
    _showThumbnailOverlay = true;
    _playerVideoSize = null;
    _lastAppliedPlayerAspectRatio = null;
    _lastAppliedPlayerFit = null;
  }

  void _videoListener(BetterPlayerEvent event) {
    if (mounted) {
      if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
        _showPlaybackError(
          StateError(
            event.parameters?['exception']?.toString() ??
                'Video playback failed',
          ),
          StackTrace.current,
        );
        return;
      }
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
    _releasePlayer();
    setState(_resetPlayback);
    final cancellation = Completer<void>();
    _loadCancelled = cancellation;
    final availability = VideoAvailabilityClient();
    _availabilityClient = availability;
    try {
      await availability.waitUntilReady(widget.videoUrl);
      if (!mounted || cancellation.isCompleted) return;
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
      videoController = videoControllerTemp;
      await Future.any<void>([
        videoControllerTemp.setupDataSource(dataSource),
        cancellation.future,
      ]).timeout(const Duration(seconds: 30));
      if (!mounted || cancellation.isCompleted) return;
      videoControllerTemp.addEventsListener(_videoListener);
      final playerVideoSize =
          videoControllerTemp.videoPlayerController?.value.size;
      _syncPlayerLayout(
        controller: videoControllerTemp,
        videoSize: playerVideoSize,
      );
      setState(() {
        _initialization = const AsyncData(null);
        _playerVideoSize = playerVideoSize;
      });
      videoControllerTemp.videoPlayerController?.addListener(
        _videoValueListener,
      );
      _syncPlaybackWithEligibility();
    } catch (error, stackTrace) {
      if (!mounted || cancellation.isCompleted) return;
      _releasePlayer();
      _showPlaybackError(error, stackTrace);
    }
  }

  void _showPlaybackError(Object error, StackTrace stackTrace) {
    if (_initialization.hasError) return;
    GetIt.I<LogService>()
        .getLogger('PostVideoPlayer')
        .w(
          'Unable to load feed video: ${widget.videoUrl}',
          error: error,
          stackTrace: stackTrace,
        );
    setState(() => _initialization = AsyncError(error, stackTrace));
  }

  void _syncPlaybackWithEligibility() {
    if (!isInitialized || _initialization.hasError) return;

    if (!_isPlaybackEligible || _userPaused) {
      if (isPlaying) videoController?.pause();
    } else if (!isPlaying) {
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
    if (_initialization.isLoading || _initialization.hasError) {
      return FeedVideoLoadingFrame(
        thumbnail: widget.thumbnail,
        videoAspectRatio: _knownVideoAspectRatio,
        isActive: widget.isActive,
        hasError: _initialization.hasError,
        onRetry: initVideoPlayer,
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
              if (isPlaying) {
                pauseVideo();
              } else {
                setState(() => _userPaused = false);
                _syncPlaybackWithEligibility();
              }
            },
            child: Container(color: Colors.transparent),
          ),
        ),
        if (_userPaused)
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
              onSeekEnd: (d) =>
                  videoController?.videoPlayerController?.seekTo(d),
            ),
          ),
      ],
    );
  }
}
