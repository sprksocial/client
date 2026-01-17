import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/core/ui/widgets/content_warning_overlay.dart';
import 'package:spark/src/core/ui/widgets/heart_animation.dart';
import 'package:spark/src/core/utils/label_utils.dart';
import 'package:spark/src/features/feed/providers/like_post.dart';
import 'package:spark/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:spark/src/features/feed/ui/widgets/post/post_overlay.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_player.dart';
import 'package:spark/src/features/settings/providers/preferences_provider.dart';

class ProfileFeedPostWidget extends ConsumerStatefulWidget {
  const ProfileFeedPostWidget({
    required this.postUri,
    required this.profileUri,
    required this.videosOnly,
    super.key,
    this.post,
    this.index,
  });
  final AtUri postUri;
  final AtUri profileUri;
  final bool videosOnly;
  final PostView? post;

  final int? index;

  @override
  ConsumerState<ProfileFeedPostWidget> createState() =>
      _ProfileFeedPostWidgetState();
}

class _ProfileFeedPostWidgetState extends ConsumerState<ProfileFeedPostWidget> {
  bool _isAnimatingHeart = false;
  bool _showWarningOverlay = false;
  bool _shouldBlurContent = false;
  List<String> _warningLabels = [];
  bool? _overrideIsLiked;
  PostView? _currentPost;
  Future<PostView?>? _postFuture;

  @override
  void initState() {
    super.initState();
    _postFuture = _loadPostWithFallback();
    _postFuture!.then((post) {
      if (post != null && mounted) {
        _checkContentWarning(post);
      }
    });
  }

  Future<PostView?> _loadPostWithFallback() async {
    if (widget.post != null) {
      return widget.post;
    }

    // If cache is null or fails, fetch from network
    final feedRepository = GetIt.instance<SprkRepository>().feed;

    final uri = AtUri.parse(widget.postUri.toString());
    final isBlueskyPost = uri.collection.toString().startsWith(
      'app.bsky.feed.post',
    );
    final networkPost = await feedRepository.getPosts([
      uri,
    ], bluesky: isBlueskyPost);

    if (networkPost.isEmpty) {
      return null;
    }

    return networkPost.first;
  }

  Future<void> _handleDoubleTapLike(PostView postData) async {
    final isCurrentlyLiked =
        _overrideIsLiked ?? (postData.viewer?.like != null);

    if (isCurrentlyLiked) {
      return;
    }

    // Start heart animation
    setState(() {
      _isAnimatingHeart = true;
    });

    try {
      // Like the post using the same logic as SideActionBar
      final newLike = await ref.read(
        likePostProvider(postData.cid, postData.uri).future,
      );

      // Update post viewer field with new like ref & increment like count
      final updatedPost = postData.copyWith(
        likeCount: (postData.likeCount ?? 0) + 1,
        viewer:
            postData.viewer?.copyWith(like: newLike.uri) ??
            ViewerState(like: newLike.uri, repost: postData.viewer?.repost),
      );

      if (mounted) {
        setState(() {
          _overrideIsLiked = true;
          _currentPost = updatedPost;
        });
      }
    } catch (e) {
      // Handle error silently for better UX
    }
  }

  void _checkContentWarning(PostView postData) {
    final labels = postData.labels ?? [];
    final preferences = ref.read(userPreferencesProvider).asData?.value;

    if (labels.isNotEmpty && preferences != null) {
      final shouldShowWarning = LabelUtils.shouldShowWarning(
        preferences,
        labels,
      );

      final shouldBlurContent = LabelUtils.shouldBlurContent(
        preferences,
        labels,
      );

      if (shouldShowWarning) {
        final warningLabels = LabelUtils.getWarningLabels(preferences, labels);
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
    return FutureBuilder<PostView?>(
      future: _postFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ColoredBox(
            color: AppColors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: AppColors.white, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load post',
                    style: TextStyle(color: AppColors.white),
                  ),
                ],
              ),
            ),
          );
        }

        final post = _currentPost ?? snapshot.data!;

        final mainContent = HeartAnimation(
          isAnimating: _isAnimatingHeart,
          onEnd: () {
            setState(() {
              _isAnimatingHeart = false;
            });
          },
          child: Stack(
            children: [
              // Main content - only this part detects double-tap for likes
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTap: () => _handleDoubleTapLike(post),
                  child: switch (post.media) {
                    MediaViewVideo() => PostVideoPlayer(
                      videoUrl: post.videoUrl,
                      thumbnail: post.thumbnailUrl,
                      profileFeedUri: widget.index != null
                          ? widget.profileUri.toString()
                          : null,
                      index: widget.index,
                    ),
                    MediaViewBskyVideo() => PostVideoPlayer(
                      videoUrl: post.videoUrl,
                      thumbnail: post.thumbnailUrl,
                      profileFeedUri: widget.index != null
                          ? widget.profileUri.toString()
                          : null,
                      index: widget.index,
                    ),
                    MediaViewImages() || MediaViewBskyImages() => ImageCarousel(
                      imageUrls: post.imageUrls,
                      hasKnownInteractions: post.viewer?.knownInteractions !=
                              null &&
                          post.viewer!.knownInteractions!.isNotEmpty,
                    ),
                    MediaViewBskyRecordWithMedia(:final media) =>
                      switch (media) {
                        MediaViewVideo() => PostVideoPlayer(
                          videoUrl: post.videoUrl,
                          thumbnail: post.thumbnailUrl,
                          profileFeedUri: widget.index != null
                              ? widget.profileUri.toString()
                              : null,
                          index: widget.index,
                        ),
                        MediaViewBskyVideo() => PostVideoPlayer(
                          videoUrl: post.videoUrl,
                          thumbnail: post.thumbnailUrl,
                          profileFeedUri: widget.index != null
                              ? widget.profileUri.toString()
                              : null,
                          index: widget.index,
                        ),
                        MediaViewImages() || MediaViewBskyImages() =>
                          ImageCarousel(
                            imageUrls: post.imageUrls,
                            hasKnownInteractions: post.viewer
                                    ?.knownInteractions !=
                                null &&
                                post.viewer!.knownInteractions!.isNotEmpty,
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
                  post: post,
                  isLiked: _overrideIsLiked ?? (post.viewer?.like != null),
                  labels: post.labels ?? [],
                  showBlockOption: false,
                  onUsernameTap: () {
                    // Extract DID from the profile URI
                    final currentProfileDid = widget.profileUri.hostname;

                    // If clicking on same profile we're viewing, navigate back
                    if (post.author.did == currentProfileDid) {
                      context.router.maybePop();
                    } else {
                      // Otherwise, navigate to the new profile
                      context.router.push(
                        ProfileRoute(
                          did: post.author.did,
                          initialProfile: post.author,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
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
    );
  }
}
