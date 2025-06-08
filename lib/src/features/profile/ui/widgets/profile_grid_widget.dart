import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/profile/providers/profile_feed_provider.dart';

class ProfileGridWidget extends ConsumerStatefulWidget {
  final AtUri profileUri;
  final bool videosOnly;

  const ProfileGridWidget({super.key, required this.profileUri, required this.videosOnly});

  @override
  ConsumerState<ProfileGridWidget> createState() => _ProfileGridWidgetState();
}

class _ProfileGridWidgetState extends ConsumerState<ProfileGridWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initial data loading is now handled automatically by the provider
  }

  @override
  void didUpdateWidget(ProfileGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // When videosOnly parameter or profileUri changes, a new provider instance
    // will be created and will automatically load its data
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Load more when user is near the bottom
      ref.read(profileFeedProvider(widget.profileUri, widget.videosOnly).notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(profileFeedProvider(widget.profileUri, widget.videosOnly).notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(profileFeedProvider(widget.profileUri, widget.videosOnly));

    return feedState.when(
      data: (state) {
        if (state.loadedPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.videosOnly ? FluentIcons.video_24_regular : FluentIcons.image_24_regular,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.videosOnly ? 'No videos yet' : 'No images yet',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(1),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
              childAspectRatio: 1,
            ),
            itemCount: state.loadedPosts.length + (state.isEndOfNetwork ? 0 : 1),
            itemBuilder: (context, index) {
              if (index >= state.loadedPosts.length) {
                // Loading indicator
                return Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                );
              }

              final postUri = state.loadedPosts[index];
              return ProfileGridTile(postUri: postUri, videosOnly: widget.videosOnly, onTap: () => _onPostTap(postUri));
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(FluentIcons.error_circle_24_regular, size: 48),
                const SizedBox(height: 16),
                Text('Error loading posts: $error'),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _onRefresh, child: const Text('Retry')),
              ],
            ),
          ),
    );
  }

  void _onPostTap(AtUri postUri) {
    // Navigate to standalone post page
    context.router.push(StandalonePostRoute(postUri: postUri.toString()));
  }
}

class ProfileGridTile extends StatelessWidget {
  final AtUri postUri;
  final bool videosOnly;
  final VoidCallback onTap;

  const ProfileGridTile({super.key, required this.postUri, required this.videosOnly, required this.onTap});

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
  Widget build(BuildContext context) {
    return FutureBuilder<PostView?>(
      future: _loadPostWithFallback(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final post = snapshot.data!;
        final thumbnailUrl = post.thumbnailUrl;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            color: AppColors.black,
            child:
                thumbnailUrl.isNotEmpty
                    ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: const Center(
                                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: const Center(child: Icon(FluentIcons.error_circle_24_regular, size: 20)),
                              ),
                        ),
                        // Video indicator overlay for videos
                        if (post.embed is EmbedViewVideo)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(150),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(FluentIcons.play_24_filled, color: Colors.white, size: 12),
                            ),
                          ),
                        // Multiple image indicator for image carousels
                        if (post.embed is EmbedViewImage)
                          if ((post.embed as EmbedViewImage).images.length > 1)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(150),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(FluentIcons.copy_24_regular, color: Colors.white, size: 12),
                              ),
                            ),
                      ],
                    )
                    : Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          post.embed is EmbedViewVideo ? FluentIcons.video_24_regular : FluentIcons.image_24_regular,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                    ),
          ),
        );
      },
    );
  }
}
