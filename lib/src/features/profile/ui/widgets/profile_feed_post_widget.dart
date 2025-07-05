import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/utils/label_utils.dart';
import 'package:sparksocial/src/core/widgets/content_warning_overlay.dart';
import 'package:sparksocial/src/core/widgets/heart_animation.dart';
import 'package:sparksocial/src/features/feed/providers/like_post.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/action_buttons/side_action_bar.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/post/info_bar.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/video_player.dart';

class ProfileFeedPostWidget extends ConsumerStatefulWidget {
  const ProfileFeedPostWidget({required this.postUri, required this.profileUri, required this.videosOnly, super.key, this.post});
  final AtUri postUri;
  final AtUri profileUri;
  final bool videosOnly;
  final PostView? post;

  @override
  ConsumerState<ProfileFeedPostWidget> createState() => _ProfileFeedPostWidgetState();
}

class _ProfileFeedPostWidgetState extends ConsumerState<ProfileFeedPostWidget> {
  bool _isAnimatingHeart = false;
  final GlobalKey<SideActionBarState> _sideActionBarKey = GlobalKey<SideActionBarState>();
  bool _showWarningOverlay = false;
  bool _shouldBlurContent = false;
  List<String> _warningLabels = [];

  @override
  void initState() {
    super.initState();
    _loadPostWithFallback().then((post) {
      if (post != null) {
        _checkContentWarning(post);
      }
    });
  }

  Future<PostView?> _loadPostWithFallback() async {
    if (widget.post != null) {
      return widget.post;
    }
    final sqlCache = GetIt.instance<SQLCacheInterface>();

    try {
      // Try to get from cache first
      return await sqlCache.getPost(widget.postUri.toString());
    } catch (e) {
      // Cache lookup failed, continue to network fetch
    }

    // If cache is null or fails, fetch from network
    final feedRepository = GetIt.instance<SprkRepository>().feed;

    final uri = AtUri.parse(widget.postUri.toString());
    final isBlueskyPost = uri.collection.toString().startsWith('app.bsky.feed.post');
    final networkPost = await feedRepository.getPosts([uri], bluesky: isBlueskyPost);

    if (networkPost.isEmpty) {
      return null;
    }

    // Cache the post for future use
    await sqlCache.cachePost(networkPost.first);

    return networkPost.first;
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

  Future<void> _checkContentWarning(PostView postData) async {
    final labels = postData.labels ?? [];

    if (labels.isNotEmpty) {
      final shouldShowWarning = await LabelUtils.shouldShowWarning(labels);

      final shouldBlurContent = await LabelUtils.shouldBlurContent(labels);

      if (shouldShowWarning) {
        final warningLabels = await LabelUtils.getWarningLabels(labels);
        if (mounted) {
          setState(() {
            _showWarningOverlay = true;
            _warningLabels = warningLabels;
            _shouldBlurContent = shouldBlurContent;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _showWarningOverlay = false;
            _warningLabels = [];
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _showWarningOverlay = false;
          _warningLabels = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<PostView?>(
        future: _loadPostWithFallback(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ColoredBox(
              color: AppColors.black,
              child: Center(child: CircularProgressIndicator(color: AppColors.white)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const ColoredBox(
              color: AppColors.black,
              child: Center(
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

          final mainContent = HeartAnimation(
            isAnimating: _isAnimatingHeart,
            onEnd: () {
              setState(() {
                _isAnimatingHeart = false;
              });
            },
            child: GestureDetector(
              onDoubleTap: () => _handleDoubleTapLike(post),
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

                  // Side action bar
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: SideActionBar(
                      key: _sideActionBarKey,
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
                    child: FutureBuilder<List<String>>(
                      future: LabelUtils.getInformLabels(post.labels ?? []),
                      builder: (context, snapshot) {
                        final informLabels = snapshot.data ?? [];
                        return InfoBar(
                          username: post.author.handle,
                          description: post.record.text ?? '',
                          hashtags: post.record.hashtags,
                          informLabels: informLabels,
                          isSprk: post.uri.toString().contains('so.sprk'),
                          onUsernameTap: () {
                            context.router.push(ProfileRoute(did: post.author.did));
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );

          if (_showWarningOverlay) {
            return ContentWarningOverlay(
              onViewContent: () {
                setState(() {
                  _showWarningOverlay = false;
                });
              },
              warningLabels: _warningLabels,
              shouldBlur: _shouldBlurContent,
              child: mainContent,
            );
          }

          return mainContent;
        },
      ),
    );
  }
}
