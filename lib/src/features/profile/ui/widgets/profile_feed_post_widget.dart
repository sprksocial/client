import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/ui/foundation/colors.dart';
import 'package:sparksocial/src/core/ui/widgets/content_warning_overlay.dart';
import 'package:sparksocial/src/core/ui/widgets/heart_animation.dart';
import 'package:sparksocial/src/core/utils/label_utils.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/post/post_overlay.dart';
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
  bool _showWarningOverlay = false;
  bool _shouldBlurContent = false;
  List<String> _warningLabels = [];
  bool? _overrideIsLiked;

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

    // If cache is null or fails, fetch from network
    final feedRepository = GetIt.instance<SprkRepository>().feed;

    final uri = AtUri.parse(widget.postUri.toString());
    final isBlueskyPost = uri.collection.toString().startsWith('app.bsky.feed.post');
    final networkPost = await feedRepository.getPosts([uri], bluesky: isBlueskyPost);

    if (networkPost.isEmpty) {
      return null;
    }

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
      // Drive SideActionBar via props instead of GlobalKey/stateful method
      if (mounted) {
        setState(() {
          _overrideIsLiked = true;
        });
      }
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
          if (!snapshot.hasData) {
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
            child: Stack(
              children: [
                // Main content - only this part should detect double-tap for likes
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onDoubleTap: () => _handleDoubleTapLike(post),
                    child: switch (post.media) {
                      MediaViewVideo() => PostVideoPlayer(videoUrl: post.videoUrl, thumbnail: post.thumbnailUrl),
                      MediaViewBskyVideo() => PostVideoPlayer(videoUrl: post.videoUrl, thumbnail: post.thumbnailUrl),
                      MediaViewImages() || MediaViewBskyImages() => ImageCarousel(imageUrls: post.imageUrls),
                      MediaViewBskyRecordWithMedia(:final media) => switch (media) {
                        MediaViewVideo() => PostVideoPlayer(videoUrl: post.videoUrl, thumbnail: post.thumbnailUrl),
                        MediaViewBskyVideo() => PostVideoPlayer(videoUrl: post.videoUrl, thumbnail: post.thumbnailUrl),
                        MediaViewImages() || MediaViewBskyImages() => ImageCarousel(imageUrls: post.imageUrls),
                        _ => const DecoratedBox(decoration: BoxDecoration(color: AppColors.black)),
                      },
                      _ => const DecoratedBox(decoration: BoxDecoration(color: AppColors.black)),
                    },
                  ),
                ),

                // Overlay controls - no double-tap detection, so buttons respond immediately
                Positioned.fill(
                  child: PostOverlay(
                    post: post,
                    isLiked: _overrideIsLiked ?? (post.viewer?.like != null),
                    labels: post.labels ?? [],
                    onProfilePressed: () {
                      // No special handling needed for profile navigation in standalone feed
                    },
                    onUsernameTap: () {
                      context.router.push(
                        ProfileRoute(
                          did: post.author.did,
                          initialProfile: post.author,
                        ),
                      );
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
      ),
    );
  }
}
