import 'package:atproto/com_atproto_label_defs.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/core/ui/widgets/content_warning_overlay.dart';
import 'package:spark/src/core/ui/widgets/heart_animation.dart';
import 'package:spark/src/core/utils/label_utils.dart';
import 'package:spark/src/features/feed/providers/feed_provider.dart';
import 'package:spark/src/features/feed/providers/like_post.dart';
import 'package:spark/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:spark/src/features/feed/ui/widgets/post/post_overlay.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_player.dart';
import 'package:spark/src/features/home/providers/navigation_provider.dart';
import 'package:spark/src/features/settings/providers/preferences_provider.dart';

class FeedPostWidget extends ConsumerStatefulWidget {
  const FeedPostWidget({
    required this.index,
    required this.feed,
    super.key,
  });

  final int index;
  final Feed feed;

  @override
  ConsumerState<FeedPostWidget> createState() => _FeedPostWidgetState();
}

class _FeedPostWidgetState extends ConsumerState<FeedPostWidget> {
  Future<PostView>? _postFuture;
  String? _lastPostUri;
  final GlobalKey<PostVideoPlayerState> _videoPlayerKey =
      GlobalKey<PostVideoPlayerState>();
  bool _isAnimatingHeart = false;
  bool _showWarningOverlay = false;
  bool _userDismissedWarning = false;
  List<String> _warningLabels = [];
  // Local UI override for like state to avoid needing a GlobalKey
  bool? _overrideIsLiked;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  void _loadPost() {
    final feedState = ref.read(feedProvider(widget.feed));
    if (widget.index < feedState.loadedPosts.length) {
      final post = feedState.loadedPosts[widget.index];
      final currentUri = post.uri.toString();

      _lastPostUri = currentUri;
      _postFuture = Future.value(post);
      _overrideIsLiked = null;
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
    final isCurrentlyLiked =
        _overrideIsLiked ?? (postData.viewer?.like != null);

    if (isCurrentlyLiked) {
      return;
    }

    // Haptic feedback for the like action
    HapticFeedback.mediumImpact();

    // Start heart animation
    setState(() {
      _isAnimatingHeart = true;
    });

    try {
      // Like the post using the same logic as SideActionBar
      final newLike = await ref.read(
        likePostProvider(postData.cid, postData.uri).future,
      );

      // Update post viewer field with new like ref and increment like count
      final updatedPost = postData.copyWith(
        likeCount: (postData.likeCount ?? 0) + 1,
        viewer:
            postData.viewer?.copyWith(like: newLike.uri) ??
            ViewerState(like: newLike.uri, repost: postData.viewer?.repost),
      );

      ref.read(feedProvider(widget.feed).notifier).replacePost(updatedPost);
      if (mounted) {
        setState(() {
          _overrideIsLiked = true;
        });
      }
    } catch (e) {
      // Handle error silently for better UX
    }
  }

  void _checkContentWarning(String postUri) {
    final feedState = ref.read(feedProvider(widget.feed));
    final preferences = ref.read(userPreferencesProvider).asData?.value;

    if (widget.index < feedState.loadedPosts.length) {
      final post = feedState.loadedPosts[widget.index];
      if (post.uri.toString() != postUri) {
        return;
      }
      final extraInfo = feedState.extraInfo[post.uri];

      if (extraInfo != null &&
          extraInfo.postLabels.isNotEmpty &&
          !_userDismissedWarning &&
          preferences != null) {
        final shouldShowWarning = LabelUtils.shouldShowWarning(
          preferences,
          extraInfo.postLabels,
        );
        if (shouldShowWarning) {
          final warningLabels = LabelUtils.getWarningLabels(
            preferences,
            extraInfo.postLabels,
          );
          setState(() {
            _showWarningOverlay = true;
            _warningLabels = warningLabels;
          });
        } else {
          setState(() {
            _showWarningOverlay = false;
            _warningLabels = [];
          });
        }
      } else {
        setState(() {
          _showWarningOverlay = false;
          _warningLabels = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need to reload post due to state changes
    final feedState = ref.watch(feedProvider(widget.feed));
    final navigationState = ref.watch(navigationProvider);

    // Check if user is not on feeds tab (index 0)
    final isOnFeedsTab = navigationState.currentIndex == 0;

    if (widget.index < feedState.loadedPosts.length) {
      final post = feedState.loadedPosts[widget.index];
      final currentUri = post.uri.toString();

      // Update local state when URI changes (scrolling to different post)
      // Posts are already hydrated from getFeed - no need to call getPosts
      if (_lastPostUri != currentUri) {
        _lastPostUri = currentUri;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(_loadPost);
            _checkContentWarning(currentUri);
          }
        });
      }
    }

    if (_postFuture == null) {
      // Show black background - skeleton is shown at feed_page level
      return const DecoratedBox(
        decoration: BoxDecoration(color: AppColors.black),
      );
    }

    // If user is not on feeds tab, show empty container to dispose video
    if (!isOnFeedsTab) {
      return const DecoratedBox(
        decoration: BoxDecoration(color: AppColors.black),
      );
    }

    return FutureBuilder<PostView>(
      future: _postFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final postData = snapshot.data!;

          // Check for content warning on post load
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _checkContentWarning(postData.uri.toString());
            }
          });

          // Get labels for the overlay and use the latest post from feed state
          var labels = <Label>[];
          // Use the post from feed state as it has the latest updates (e.g., after like/repost)
          final currentPost = (widget.index < feedState.loadedPosts.length)
              ? feedState.loadedPosts[widget.index]
              : postData;
          if (widget.index < feedState.loadedPosts.length) {
            final extraInfo = feedState.extraInfo[currentPost.uri];
            if (extraInfo != null) {
              labels = extraInfo.postLabels;
            }
          }

          final mainContent = HeartAnimation(
            isAnimating: _isAnimatingHeart,
            bottomOffset: MediaQuery.of(context).padding.bottom,
            onEnd: () {
              setState(() {
                _isAnimatingHeart = false;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main content - only this part detects double-tap for likes
                Positioned.fill(
                  bottom: 0 + MediaQuery.of(context).padding.bottom,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onDoubleTap: () => _handleDoubleTapLike(postData),
                    child: switch (postData.media) {
                      MediaViewVideo() => PostVideoPlayer(
                        key: _videoPlayerKey,
                        videoUrl: postData.videoUrl,
                        feed: widget.feed,
                        index: widget.index,
                        thumbnail: postData.thumbnailUrl,
                      ),
                      MediaViewBskyVideo() => PostVideoPlayer(
                        key: _videoPlayerKey,
                        videoUrl: postData.videoUrl,
                        feed: widget.feed,
                        index: widget.index,
                        thumbnail: postData.thumbnailUrl,
                      ),
                      MediaViewImages() ||
                      MediaViewBskyImages() => ImageCarousel(
                        imageUrls: postData.imageUrls,
                        hasKnownInteractions:
                            currentPost.viewer?.knownInteractions != null &&
                            currentPost.viewer!.knownInteractions!.isNotEmpty,
                      ),
                      MediaViewBskyRecordWithMedia(:final media) =>
                        switch (media) {
                          MediaViewVideo() => PostVideoPlayer(
                            key: _videoPlayerKey,
                            videoUrl: postData.videoUrl,
                            feed: widget.feed,
                            index: widget.index,
                            thumbnail: postData.thumbnailUrl,
                          ),
                          MediaViewBskyVideo() => PostVideoPlayer(
                            key: _videoPlayerKey,
                            videoUrl: postData.videoUrl,
                            feed: widget.feed,
                            index: widget.index,
                            thumbnail: postData.thumbnailUrl,
                          ),
                          MediaViewImages() ||
                          MediaViewBskyImages() => ImageCarousel(
                            imageUrls: postData.imageUrls,
                            hasKnownInteractions:
                                currentPost.viewer?.knownInteractions != null &&
                                currentPost
                                    .viewer!
                                    .knownInteractions!
                                    .isNotEmpty,
                          ),
                          _ => const DecoratedBox(
                            decoration: BoxDecoration(color: AppColors.black),
                          ),
                        },
                      _ => const DecoratedBox(
                        decoration: BoxDecoration(color: AppColors.black),
                      ),
                    },
                  ),
                ),

                Positioned.fill(
                  child: PostOverlay(
                    post: currentPost,
                    feed: widget.feed,
                    isLiked:
                        _overrideIsLiked ?? (currentPost.viewer?.like != null),
                    labels: labels,
                    onProfilePressed: () {
                      _videoPlayerKey.currentState?.pauseVideo();
                    },
                    onUsernameTap: () {
                      _videoPlayerKey.currentState?.pauseVideo();
                      context.router.push(
                        ProfileRoute(
                          did: currentPost.author.did,
                          initialProfile: currentPost.author,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );

          // Return main content with warning overlay if needed
          if (_showWarningOverlay && _warningLabels.isNotEmpty) {
            return ContentWarningOverlay(
              onViewContent: () {
                setState(() {
                  _showWarningOverlay = false;
                  _userDismissedWarning =
                      true; // User has dismissed the warning
                });
              },
              warningLabels: _warningLabels,
              shouldBlur: true,
              child: mainContent,
            );
          }

          return mainContent;
        }
        if (snapshot.hasError) {
          return DecoratedBox(
            decoration: const BoxDecoration(color: AppColors.black),
            child: Center(
              child: Text(
                'Error loading post: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }
        // Show black background - skeleton is shown at feed_page level
        return const DecoratedBox(
          decoration: BoxDecoration(color: AppColors.black),
        );
      },
    );
  }
}
