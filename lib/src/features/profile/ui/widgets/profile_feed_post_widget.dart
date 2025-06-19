import 'package:auto_route/auto_route.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/action_buttons/side_action_bar.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/post/info_bar.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/video_player.dart';

class ProfileFeedPostWidget extends ConsumerWidget {
  final AtUri postUri;
  final AtUri profileUri;
  final bool videosOnly;

  const ProfileFeedPostWidget({super.key, required this.postUri, required this.profileUri, required this.videosOnly});

  Future<PostView?> _loadPostWithFallback() async {
    final sqlCache = GetIt.instance<SQLCacheInterface>();

    try {
      // Try to get from cache first
      final cachedPost = await sqlCache.getPost(postUri.toString());
      return cachedPost;
    } catch (e) {
      // Cache lookup failed, continue to network fetch
    }

    // If cache is null or fails, fetch from network
    final feedRepository = GetIt.instance<SprkRepository>().feed;

    List<PostView> networkPost;
    try {
      // Try Spark network first
      networkPost = await feedRepository.getPosts([postUri], bluesky: false);
    } catch (e) {
      // Fallback to Bluesky network
      networkPost = await feedRepository.getPosts([postUri], bluesky: true);
    }

    if (networkPost.isEmpty) {
      return null;
    }

    // Cache the post for future use
    await sqlCache.cachePost(networkPost.first);

    return networkPost.first;
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: FutureBuilder<PostView?>(
        future: _loadPostWithFallback(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: AppColors.black,
              child: const Center(child: CircularProgressIndicator(color: AppColors.white)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Container(
              color: AppColors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.white, size: 48),
                    SizedBox(height: 16),
                    Text('Failed to load post', style: TextStyle(color: AppColors.white)),
                  ],
                ),
              ),
            );
          }

          final post = snapshot.data!;

          // Create a simple post display similar to FeedPostWidget but without feed dependencies
          return GestureDetector(
            onDoubleTap: () {},
            child: Stack(
              children: [
                // Main content
                switch (post.embed) {
                  EmbedViewVideo() => PostVideoPlayer(videoUrl: post.videoUrl, isSparkPost: true),
                  EmbedViewBskyVideo() => PostVideoPlayer(videoUrl: post.videoUrl, isSparkPost: false),
                  EmbedViewImage() || EmbedViewBskyImages() => ImageCarousel(imageUrls: post.imageUrls),
                  EmbedViewBskyRecordWithMedia(:final media) => switch (media) {
                    EmbedViewVideo() => PostVideoPlayer(videoUrl: post.videoUrl, isSparkPost: true),
                    EmbedViewBskyVideo() => PostVideoPlayer(videoUrl: post.videoUrl, isSparkPost: false),
                    EmbedViewImage() || EmbedViewBskyImages() => ImageCarousel(imageUrls: post.imageUrls),
                    _ => const DecoratedBox(decoration: BoxDecoration(color: AppColors.black)),
                  },
                  _ => const DecoratedBox(decoration: BoxDecoration(color: AppColors.black)),
                },

                // Gradient overlay at the bottom to improve text readability
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
                          colors: [Colors.black87.withAlpha(100), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),

                // Side action bar
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: SideActionBar(
                    post: post,
                    likeCount: '${post.likeCount ?? 0}',
                    commentCount: '${post.replyCount ?? 0}',
                    shareCount: '${post.repostCount ?? 0}',
                    isLiked: post.viewer?.like != null,
                    profileImageUrl: post.author.avatar.toString(),
                    isImage: post.embed is EmbedViewImage || post.embed is EmbedViewBskyImages,
                    onProfilePressed: () {
                      // No special handling needed for profile navigation in standalone feed
                    },
                  ),
                ),

                Positioned(
                  bottom: 32,
                  left: 4,
                  right: 80,
                  child: InfoBar(
                    username: post.author.handle,
                    description: post.record.text ?? '',
                    hashtags: post.record.hashtags,
                    isSprk: post.uri.toString().contains('so.sprk'),
                    onUsernameTap: () {
                      context.router.push(ProfileRoute(did: post.author.did));
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
