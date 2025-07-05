import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:video_player/video_player.dart';

@RoutePage()
class StoryPage extends ConsumerStatefulWidget {
  const StoryPage({
    required this.story,
    super.key,
    this.onLoadingStateChanged,
  });

  final StoryView story;
  final ValueChanged<bool>? onLoadingStateChanged;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StoryPageState();
}

class _StoryPageState extends ConsumerState<StoryPage> with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isImageLoaded = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _updateLoadingState() {
    final isLoading = _isVideoStory(widget.story) ? !_isVideoInitialized : !_isImageLoaded;

    if (_isLoading != isLoading) {
      _isLoading = isLoading;
      widget.onLoadingStateChanged?.call(isLoading);
    }
  }

  Future<void> _initializeMedia() async {
    if (_isVideoStory(widget.story)) {
      final videoUrl = _getVideoUrl(widget.story);
      if (videoUrl.isNotEmpty) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        try {
          await _videoController!.initialize();
          await _videoController!.setLooping(true);
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
      EmbedViewVideo() || EmbedViewBskyVideo() => true,
      EmbedViewBskyRecordWithMedia(:final media) => switch (media) {
        EmbedViewVideo() || EmbedViewBskyVideo() => true,
        _ => false,
      },
      _ => false,
    };
  }

  String _getVideoUrl(StoryView story) {
    return switch (story.media) {
      EmbedViewVideo(:final playlist) => playlist.toString(),
      EmbedViewBskyVideo(:final playlist) => playlist.toString(),
      EmbedViewBskyRecordWithMedia(:final media) => switch (media) {
        EmbedViewVideo(:final playlist) => playlist.toString(),
        EmbedViewBskyVideo(:final playlist) => playlist.toString(),
        _ => '',
      },
      _ => '',
    };
  }

  String _getImageUrl(StoryView story) {
    return switch (story.media) {
      EmbedViewVideo(:final thumbnail) => thumbnail.toString(),
      EmbedViewBskyVideo(:final thumbnail) => thumbnail.toString(),
      EmbedViewImage(:final images) when images.isNotEmpty => images.first.fullsize.toString(),
      EmbedViewBskyImages(:final images) when images.isNotEmpty => images.first.fullsize.toString(),
      EmbedViewBskyRecordWithMedia(:final media) => switch (media) {
        EmbedViewVideo(:final thumbnail) => thumbnail.toString(),
        EmbedViewBskyVideo(:final thumbnail) => thumbnail.toString(),
        EmbedViewImage(:final images) when images.isNotEmpty => images.first.fullsize.toString(),
        EmbedViewBskyImages(:final images) when images.isNotEmpty => images.first.fullsize.toString(),
        _ => widget.story.author.avatar.toString(),
      },
      _ => widget.story.author.avatar.toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    // Determine the main media widget (video or image) first.
    late final Widget mediaContent;

    if (_isVideoStory(widget.story)) {
      if (_videoController != null && _isVideoInitialized) {
        mediaContent = AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        );
      } else {
        mediaContent = const Center(child: CircularProgressIndicator());
      }
    } else {
      final imageUrl = _getImageUrl(widget.story);

      mediaContent = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (context, url, progress) => const Center(child: CircularProgressIndicator()),
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
          return Image(image: imageProvider, fit: BoxFit.cover);
        },
      );
    }

    // Wrap the media in a Stack to overlay gradient shadows for readability.
    return Stack(
      fit: StackFit.expand,
      children: [
        mediaContent,
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
  }
}
