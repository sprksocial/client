import 'package:atproto/com_atproto_label_defs.dart';
import 'package:atproto/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/ui/foundation/colors.dart';
import 'package:sparksocial/src/core/ui/widgets/content_warning_overlay.dart';
import 'package:sparksocial/src/core/ui/widgets/heart_animation.dart';
import 'package:sparksocial/src/core/utils/label_utils.dart';
import 'package:sparksocial/src/features/feed/providers/feed_provider.dart';
import 'package:sparksocial/src/features/feed/providers/like_post.dart';
import 'package:sparksocial/src/features/feed/providers/post_updates.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/post/post_overlay.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/video_player.dart';
import 'package:sparksocial/src/features/home/providers/navigation_provider.dart';

class FeedPostWidget extends ConsumerStatefulWidget {
  const FeedPostWidget({required this.index, required this.feed, super.key});

  final int index;
  final Feed feed;

  @override
  ConsumerState<FeedPostWidget> createState() => _FeedPostWidgetState();
}

class _FeedPostWidgetState extends ConsumerState<FeedPostWidget> {
  Future<PostView>? _postFuture;
  String? _lastPostUri;
  int? _lastUpdateCount;
  final GlobalKey<PostVideoPlayerState> _videoPlayerKey = GlobalKey<PostVideoPlayerState>();
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
    final isCurrentlyLiked = _overrideIsLiked ?? (postData.viewer?.like != null);

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

      // Update the post's viewer field with the new like reference and increment like count
      final updatedPost = postData.copyWith(
        likeCount: (postData.likeCount ?? 0) + 1,
        viewer: postData.viewer?.copyWith(like: newLike.uri) ?? ViewerState(like: newLike.uri, repost: postData.viewer?.repost),
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

  Future<void> _checkContentWarning(String postUri) async {
    final feedState = ref.read(feedProvider(widget.feed));
    if (widget.index < feedState.loadedPosts.length) {
      final post = feedState.loadedPosts[widget.index];
      if (post.uri.toString() != postUri) {
        return;
      }
      final extraInfo = feedState.extraInfo[post.uri];

      if (extraInfo != null && extraInfo.postLabels.isNotEmpty && !_userDismissedWarning) {
        final shouldShowWarning = await LabelUtils.shouldShowWarning(extraInfo.postLabels);
        if (shouldShowWarning) {
          final warningLabels = await LabelUtils.getWarningLabels(extraInfo.postLabels);
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

      // Watch for post updates to trigger reload
      final updateCount = ref.watch(postUpdateProvider(currentUri));

      if (_lastPostUri != currentUri || _lastUpdateCount != updateCount) {
        _lastUpdateCount = updateCount;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(feedProvider(widget.feed).notifier).refreshPost(AtUri.parse(currentUri));
            setState(_loadPost);
            _checkContentWarning(currentUri);
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

    return FutureBuilder<PostView>(
      future: _postFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
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
          final currentPost = (widget.index < feedState.loadedPosts.length) ? feedState.loadedPosts[widget.index] : postData;
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
                // Main content - only this part should detect double-tap for likes
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
                      MediaViewImages() || MediaViewBskyImages() => ImageCarousel(imageUrls: postData.imageUrls),
                      MediaViewBskyRecordWithMedia(:final media) => switch (media) {
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
                        MediaViewImages() || MediaViewBskyImages() => ImageCarousel(imageUrls: postData.imageUrls),
                        _ => const DecoratedBox(decoration: BoxDecoration(color: AppColors.black)),
                      },
                      _ => const DecoratedBox(decoration: BoxDecoration(color: AppColors.black)),
                    },
                  ),
                ),

                // Overlay controls - no double-tap detection, so buttons respond immediately
                Positioned.fill(
                  child: PostOverlay(
                    post: currentPost,
                    feed: widget.feed,
                    isLiked: _overrideIsLiked ?? (currentPost.viewer?.like != null),
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
                  _userDismissedWarning = true; // User has dismissed the warning
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
              child: Text('Error loading post: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
            ),
          );
        }
        return const DecoratedBox(
          decoration: BoxDecoration(color: AppColors.black),
          child: Center(child: CircularProgressIndicator(color: AppColors.white)),
        );
      },
    );
  }
}
