import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

@RoutePage()
class StoryPage extends ConsumerStatefulWidget {
  const StoryPage({super.key, required this.story});

  final StoryView story;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StoryPageState();
}

class _StoryPageState extends ConsumerState<StoryPage> with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

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
          }
        } catch (_) {
          // Ignore errors for now – UI will show the fallback widget.
        }
      }
    }
  }

  bool _isVideoStory(StoryView story) {
    return switch (story.media) {
      EmbedViewVideo() => true,
      _ => false,
    };
  }

  String _getVideoUrl(StoryView story) {
    return switch (story.media) {
      EmbedViewVideo(:final playlist) => playlist.toString(),
      _ => '',
    };
  }

  String _getImageUrl(StoryView story) {
    return switch (story.media) {
      EmbedViewVideo(:final thumbnail) => thumbnail.toString(),
      EmbedViewImage(:final images) when images.isNotEmpty => images.first.fullsize.toString(),
      _ => widget.story.author.avatar.toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideoStory(widget.story)) {
      if (_videoController != null && _isVideoInitialized) {
        return AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!));
      }
      return const Center(child: CircularProgressIndicator());
    } else {
      final imageUrl = _getImageUrl(widget.story);

      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (context, url, progress) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.white)),
      );
    }
  }
}
