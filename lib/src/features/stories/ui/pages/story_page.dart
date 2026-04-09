import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as flutter_widgets show Image;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/story_embed_models.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:video_player/video_player.dart';

@RoutePage()
class StoryPage extends ConsumerStatefulWidget {
  const StoryPage({
    required this.story,
    super.key,
    this.onLoadingStateChanged,
    this.onStoryDurationChanged,
    this.onPauseRequested,
    this.onResumeRequested,
    this.onPrevious,
    this.onNext,
  });

  final StoryView story;
  final ValueChanged<bool>? onLoadingStateChanged;
  final ValueChanged<Duration>? onStoryDurationChanged;
  final VoidCallback? onPauseRequested;
  final VoidCallback? onResumeRequested;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StoryPageState();
}

class _StoryPageState extends ConsumerState<StoryPage>
    with TickerProviderStateMixin {
  static const _defaultStoryDuration = Duration(seconds: 5);
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isImageLoaded = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!_isVideoStory(widget.story)) {
      widget.onStoryDurationChanged?.call(_defaultStoryDuration);
    }
    _initializeMedia();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If this page becomes active after being prebuilt, ensure the parent gets
    // the latest loading state immediately.
    if (oldWidget.onLoadingStateChanged != widget.onLoadingStateChanged &&
        widget.onLoadingStateChanged != null) {
      widget.onLoadingStateChanged!(_isLoading);
    }
    if (oldWidget.onStoryDurationChanged != widget.onStoryDurationChanged &&
        widget.onStoryDurationChanged != null) {
      widget.onStoryDurationChanged!(_resolvedStoryDuration());
    }
  }

  Duration _resolvedStoryDuration() {
    if (_isVideoStory(widget.story)) {
      final duration = _videoController?.value.duration;
      if (duration != null && duration > Duration.zero) {
        return duration;
      }
    }
    return _defaultStoryDuration;
  }

  void _updateLoadingState() {
    final isLoading = _isVideoStory(widget.story)
        ? !_isVideoInitialized
        : !_isImageLoaded;

    if (_isLoading != isLoading) {
      _isLoading = isLoading;
      widget.onLoadingStateChanged?.call(isLoading);
    }
  }

  Future<void> _initializeMedia() async {
    if (_isVideoStory(widget.story)) {
      final videoUrl = _getVideoUrl(widget.story);
      if (videoUrl.isNotEmpty) {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
        );
        try {
          await _videoController!.initialize();
          await _videoController!.setLooping(true);
          widget.onStoryDurationChanged?.call(_resolvedStoryDuration());
          await _videoController!.play();
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
            _updateLoadingState();
          }
        } catch (_) {
          // Ignore errors for now – UI will show the fallback widget.
          if (mounted) {
            setState(() {
              _isVideoInitialized = true; // Consider failed videos as "loaded"
            });
            _updateLoadingState();
          }
        }
      }
    } else {
      // For images, we'll track loading through CachedNetworkImage callbacks
    }
  }

  bool _isVideoStory(StoryView story) {
    return switch (story.media) {
      MediaViewVideo() => true,
      _ => false,
    };
  }

  String _getVideoUrl(StoryView story) {
    return switch (story.media) {
      MediaViewVideo(:final playlist) => playlist.toString(),
      _ => '',
    };
  }

  String _getImageUrl(StoryView story) {
    return switch (story.media) {
      MediaViewImage(:final image) => image.fullsize.toString(),
      _ => widget.story.author.avatar.toString(),
    };
  }

  Future<void> _handleEmbedTap(StoryMentionEmbedView embed) async {
    final router = context.router;
    widget.onPauseRequested?.call();
    final videoController = _videoController;
    final wasPlaying = videoController?.value.isPlaying ?? false;
    if (wasPlaying) {
      await videoController?.pause();
    }

    await router.push(
      ProfileRoute(did: embed.did, initialProfile: embed.actor),
    );

    if (!mounted) {
      return;
    }

    widget.onResumeRequested?.call();
    if (wasPlaying) {
      await videoController?.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(20));

    // Determine the main media widget (video or image) first.
    late final Widget mediaContent;
    late final Size sourceSize;

    if (_isVideoStory(widget.story)) {
      if (_videoController != null && _isVideoInitialized) {
        if (_videoController!.value.isInitialized) {
          final size = _videoController!.value.size;
          sourceSize = Size(
            size.width > 0 ? size.width : 1440,
            size.height > 0 ? size.height : 2560,
          );
          mediaContent = Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: (size.width > 0 ? size.width : 1280),
                height: (size.height > 0 ? size.height : 720),
                child: VideoPlayer(_videoController!),
              ),
            ),
          );
        } else {
          sourceSize = const Size(1440, 2560);
          mediaContent = const Center(
            child: Icon(Icons.videocam_off, size: 48, color: Colors.white),
          );
        }
      } else {
        sourceSize = const Size(1440, 2560);
        mediaContent = const Center(child: CircularProgressIndicator());
      }
    } else {
      final imageUrl = _getImageUrl(widget.story);
      sourceSize = const Size(1440, 2560);

      mediaContent = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (context, url, progress) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) {
          // Consider error state as "loaded" to avoid infinite loading
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isImageLoaded) {
              setState(() {
                _isImageLoaded = true;
              });
              _updateLoadingState();
            }
          });
          return const Center(
            child: Icon(Icons.broken_image, size: 48, color: Colors.white),
          );
        },
        imageBuilder: (context, imageProvider) {
          // Image successfully loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isImageLoaded) {
              setState(() {
                _isImageLoaded = true;
              });
              _updateLoadingState();
            }
          });
          return flutter_widgets.Image(image: imageProvider, fit: BoxFit.cover);
        },
      );
    }

    // Wrap the media in a Stack to overlay gradient shadows for readability.
    return ClipRRect(
      borderRadius: borderRadius,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final destinationRect = _resolveMediaRect(
            containerSize: constraints.biggest,
            sourceSize: sourceSize,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              mediaContent,
              Positioned(
                top: 80,
                bottom: 0,
                left: 0,
                width: constraints.maxWidth * 0.3,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: widget.onPrevious,
                  child: const SizedBox.expand(),
                ),
              ),
              Positioned(
                top: 80,
                bottom: 0,
                right: 0,
                width: constraints.maxWidth * 0.3,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: widget.onNext,
                  child: const SizedBox.expand(),
                ),
              ),
              ..._buildMentionEmbeds(destinationRect),
              // Top shadow overlay
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black87.withAlpha(100),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom shadow overlay
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
                        colors: [
                          Colors.black87.withAlpha(100),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Rect _resolveMediaRect({
    required Size containerSize,
    required Size sourceSize,
  }) {
    final fittedSizes = applyBoxFit(BoxFit.cover, sourceSize, containerSize);
    return Alignment.center.inscribe(
      fittedSizes.destination,
      Offset.zero & containerSize,
    );
  }

  Iterable<Widget> _buildMentionEmbeds(Rect mediaRect) {
    final mentionEmbeds = _storyMentionEmbeds.toList()
      ..sort((a, b) {
        final aIndex = a.placement.zIndex ?? 0;
        final bIndex = b.placement.zIndex ?? 0;
        return aIndex.compareTo(bIndex);
      });

    return mentionEmbeds.map((embed) {
      final frame = embed.placement.frame;
      final rect = Rect.fromLTWH(
        mediaRect.left + mediaRect.width * frame.x / 10000,
        mediaRect.top + mediaRect.height * frame.y / 10000,
        mediaRect.width * frame.w / 10000,
        mediaRect.height * frame.h / 10000,
      );
      final rotationDegrees = embed.placement.rotation ?? 0;

      return Positioned(
        left: rect.left,
        top: rect.top,
        width: rect.width,
        height: rect.height,
        child: Transform.rotate(
          angle: rotationDegrees * math.pi / 180,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _handleEmbedTap(embed),
            child: const SizedBox.expand(),
          ),
        ),
      );
    });
  }

  List<StoryMentionEmbedView> get _storyMentionEmbeds {
    if (widget.story.embeds != null && widget.story.embeds!.isNotEmpty) {
      final hydratedEmbeds = widget.story.embeds!
          .whereType<StoryMentionEmbedView>()
          .where((embed) => _isValidMentionEmbed(embed.placement))
          .toList(growable: false);

      if (hydratedEmbeds.isNotEmpty) {
        return hydratedEmbeds;
      }
    }

    final recordEmbeds = widget.story.record.embeds ?? const <StoryEmbed>[];
    return recordEmbeds
        .whereType<StoryMentionEmbed>()
        .where((embed) {
          return _isValidMentionEmbed(embed.placement);
        })
        .map((embed) {
          return StoryEmbedView.mention(
            placement: embed.placement,
            did: embed.did,
          );
        })
        .whereType<StoryMentionEmbedView>()
        .toList(growable: false);
  }

  bool _isValidMentionEmbed(StoryEmbedPlacement placement) {
    final frame = placement.frame;
    return frame.w > 0 && frame.h > 0;
  }
}
