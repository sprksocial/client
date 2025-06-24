import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/providers/feed_provider.dart';
import 'package:sparksocial/src/features/feed/providers/post_updates.dart';
import 'package:sparksocial/src/features/feed/providers/like_post.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/action_buttons/side_action_bar.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/post/info_bar.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/video_player.dart';
import 'package:sparksocial/src/features/home/providers/navigation_provider.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/widgets/heart_animation.dart';

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
  int? _lastUpdateCount;
  final GlobalKey<PostVideoPlayerState> _videoPlayerKey = GlobalKey<PostVideoPlayerState>();
  final GlobalKey<SideActionBarState> _sideActionBarKey = GlobalKey<SideActionBarState>();
  bool _isAnimatingHeart = false;

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

      // Create new future if URI changed or if we need to force refresh
      _lastPostUri = currentUri;
      _postFuture = GetIt.instance<SQLCacheInterface>().getPost(currentUri);
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

  Future<void> _handleDoubleTapLike(PostView postData) async {
    final isCurrentlyLiked = postData.viewer?.like != null;

    if (isCurrentlyLiked) {
      return;
    }

    // Start heart animation
    setState(() {
      _isAnimatingHeart = true;
    });

    try {
      // Like the post using the same logic as SideActionBar
      final newLike = await ref.read(likePostProvider(postData.cid, postData.uri).future);

      // Update the post's viewer field with the new like reference
      final updatedPost = postData.copyWith(
        viewer: postData.viewer?.copyWith(like: newLike.uri) ?? Viewer(like: newLike.uri, repost: postData.viewer?.repost),
      );

      // Update cache with the modified post
      await GetIt.instance<SQLCacheInterface>().updatePost(updatedPost);

      // Update SideActionBar state directly
      _sideActionBarKey.currentState?.updateLikeState(updatedPost);
    } catch (e) {
      // Handle error silently for better UX
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need to reload post due to state changes
    final feedState = ref.watch(feedNotifierProvider(widget.feed));
    final navigationState = ref.watch(navigationProvider);

    // Check if user is not on feeds tab (index 0)
    final isOnFeedsTab = navigationState.currentIndex == 0;

    if (widget.index < feedState.loadedPosts.length) {
      final postUri = feedState.loadedPosts[widget.index];
      final currentUri = postUri.toString();

      // Watch for post updates to trigger reload
      final updateCount = ref.watch(postUpdateProvider(currentUri));

      if (_lastPostUri != currentUri || _lastUpdateCount != updateCount) {
        _lastUpdateCount = updateCount;
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

    // If user is not on feeds tab, show empty container to dispose video
    if (!isOnFeedsTab) {
      return const DecoratedBox(decoration: BoxDecoration(color: AppColors.black));
    }

    return FutureBuilder(
      future: _postFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          final postData = snapshot.data! as PostView;
          final sideActionBar = SideActionBar(
            key: _sideActionBarKey,
            post: postData,
            likeCount: '${postData.likeCount ?? 0}',
            commentCount: '${postData.replyCount ?? 0}',
            shareCount: '${postData.repostCount ?? 0}',
            isLiked: postData.viewer?.like != null,
            profileImageUrl: postData.author.avatar.toString(),
            isImage: postData.embed is EmbedViewImage || postData.embed is EmbedViewBskyImages,
            onProfilePressed: () {
              // Pause video before navigating to profile
              _videoPlayerKey.currentState?.pauseVideo();
            },
          );

          return HeartAnimation(
            isAnimating: _isAnimatingHeart,
            onEnd: () {
              setState(() {
                _isAnimatingHeart = false;
              });
            },
            child: GestureDetector(
              onDoubleTap: () => _handleDoubleTapLike(postData),
              child: Stack(
                children: [
                  // Main content
                  switch (postData.embed) {
                    EmbedViewVideo() => PostVideoPlayer(
                      key: _videoPlayerKey,
                      videoUrl: postData.videoUrl,
                      feed: widget.feed,
                      index: widget.index,
                      isSparkPost: true,
                    ),
                    EmbedViewBskyVideo() => PostVideoPlayer(
                      key: _videoPlayerKey,
                      videoUrl: postData.videoUrl,
                      feed: widget.feed,
                      index: widget.index,
                      isSparkPost: false,
                    ),
                    EmbedViewImage() || EmbedViewBskyImages() => ImageCarousel(imageUrls: postData.imageUrls),
                    EmbedViewBskyRecordWithMedia(:final media) => switch (media) {
                      EmbedViewVideo() => PostVideoPlayer(
                        key: _videoPlayerKey,
                        videoUrl: postData.videoUrl,
                        feed: widget.feed,
                        index: widget.index,
                        isSparkPost: true,
                      ),
                      EmbedViewBskyVideo() => PostVideoPlayer(
                        key: _videoPlayerKey,
                        videoUrl: postData.videoUrl,
                        feed: widget.feed,
                        index: widget.index,
                        isSparkPost: false,
                      ),
                      EmbedViewImage() || EmbedViewBskyImages() => ImageCarousel(imageUrls: postData.imageUrls),
                      _ => const DecoratedBox(decoration: BoxDecoration(color: AppColors.black)),
                    },
                    _ => const DecoratedBox(decoration: BoxDecoration(color: AppColors.black)),
                  },

                  // Side action bar
                  Positioned(bottom: 4, right: 4, child: sideActionBar),

                  Positioned(
                    bottom: 32,
                    left: 4,
                    right: 80,
                    child: InfoBar(
                      username: postData.author.handle,
                      description: postData.record.text ?? '',
                      hashtags: postData.record.hashtags,
                      isSprk: postData.uri.toString().contains('so.sprk'),
                      onUsernameTap: () {
                        _videoPlayerKey.currentState?.pauseVideo();
                        context.router.push(ProfileRoute(did: postData.author.did));
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return DecoratedBox(
            decoration: BoxDecoration(color: AppColors.black),
            child: Center(
              child: Text('Error loading post: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
            ),
          );
        }
        return DecoratedBox(
          decoration: BoxDecoration(color: AppColors.black),
          child: const Center(child: CircularProgressIndicator(color: AppColors.white)),
        );
      },
    );
  }
}
