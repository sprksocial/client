import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/features/feed/providers/feed_provider.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/video_player.dart';
import 'package:atproto/atproto.dart';

class FeedPostWidget extends ConsumerStatefulWidget {
  const FeedPostWidget({super.key, required this.index, required this.feed});

  final int index;
  final Feed feed;

  @override
  ConsumerState<FeedPostWidget> createState() => _FeedPostWidgetState();
}

class _FeedPostWidgetState extends ConsumerState<FeedPostWidget> {
  Future<dynamic>? _postFuture;
  String? _lastPostUri;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  void _loadPost() {
    final feedState = ref.read(feedNotifierProvider(widget.feed));
    if (widget.index < feedState.loadedPosts.length) {
      final postUri = feedState.loadedPosts[widget.index];
      final currentUri = postUri.toString();
      
      // Only create new future if URI changed
      if (_lastPostUri != currentUri) {
        _lastPostUri = currentUri;
        _postFuture = GetIt.instance<SQLCacheInterface>().getPost(currentUri);
      }
    }
  }

  @override
  void didUpdateWidget(FeedPostWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if index or feed changed
    if (oldWidget.index != widget.index || oldWidget.feed != widget.feed) {
      _loadPost();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need to reload post due to state changes
    final feedState = ref.watch(feedNotifierProvider(widget.feed));
    if (widget.index < feedState.loadedPosts.length) {
      final postUri = feedState.loadedPosts[widget.index];
      final currentUri = postUri.toString();
      
      if (_lastPostUri != currentUri) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _loadPost();
            });
          }
        });
      }
    }

    if (_postFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder(
      future: _postFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          final postData = snapshot.data!;
          return Stack(
            children: [
              switch (postData.embed) {
                EmbedViewVideo() => PostVideoPlayer(videoUrl: postData.videoUrl, feed: widget.feed, index: widget.index),
                EmbedViewImage() => ImageCarousel(imageUrls: postData.imageUrls),
                _ => const SizedBox.shrink(), // something REALLY wrong happened if this is reached
              },
            ],
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading post: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
