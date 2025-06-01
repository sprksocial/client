import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/features/feed/providers/feed_provider.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/video_player.dart';

class FeedPostWidget extends ConsumerWidget {
  const FeedPostWidget({super.key, required this.index, required this.feed});

  final int index;
  final Feed feed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoControllersManager = GetIt.I<VideoControllersManager>();
    // extract information from the feed provider
    final feedState = ref.watch(feedNotifierProvider(feed));
    final postUri = feedState.loadedPosts[index];
    final post = GetIt.instance<SQLCacheInterface>().getPost(postUri.toString());

    return FutureBuilder(
      future: post,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [
              switch (snapshot.data!.embed) {
                EmbedViewVideo() => PostVideoPlayer(videoController: videoControllersManager.newController(snapshot.data!.videoUrl), uri: snapshot.data!.videoUrl),
                EmbedViewImage() => ImageCarousel(imageUrls: (snapshot.data!.imageUrls)),
                _ => const SizedBox.shrink(), // something REALLY wrong happened if this is reached
              },
              
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
