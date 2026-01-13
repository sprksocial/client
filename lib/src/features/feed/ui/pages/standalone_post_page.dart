import 'dart:ui';
import 'package:atproto_core/atproto_core.dart';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/tokens/constants.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';
import 'package:spark/src/core/ui/widgets/content_warning_overlay.dart';
import 'package:spark/src/core/utils/label_utils.dart';
import 'package:spark/src/features/feed/providers/post_updates.dart';
import 'package:spark/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:spark/src/features/feed/ui/widgets/post/post_overlay.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_player.dart';

@RoutePage()
class StandalonePostPage extends ConsumerStatefulWidget {
  const StandalonePostPage({required this.postUri, super.key});

  final String postUri;

  @override
  ConsumerState<StandalonePostPage> createState() => _StandalonePostPageState();
}

class _StandalonePostPageState extends ConsumerState<StandalonePostPage> {
  Future<PostView>? _postFuture;
  int? _lastUpdateCount;
  final GlobalKey<PostVideoPlayerState> _videoPlayerKey =
      GlobalKey<PostVideoPlayerState>();
  bool _showWarningOverlay = false;
  List<String> _warningLabels = [];
  bool _shouldBlurContent = false;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  void _loadPost() {
    _postFuture = _loadPostWithFallback();
    _postFuture?.then((post) {
      if (mounted) {
        _checkContentWarning(post);
      }
    });
  }

  Future<PostView> _loadPostWithFallback() async {
    final feedRepository = GetIt.instance<SprkRepository>().feed;
    final uri = AtUri.parse(widget.postUri);
    final isBlueskyPost = uri.collection.toString().startsWith(
      'app.bsky.feed.post',
    );
    const maxRetries = 3;
    const delay = Duration(seconds: 2);
    for (var i = 0; i < maxRetries; i++) {
      final networkPost = await feedRepository.getPosts([
        uri,
      ], bluesky: isBlueskyPost);
      if (networkPost.isNotEmpty) {
        return networkPost.first;
      }
      if (i < maxRetries - 1) {
        await Future.delayed(delay);
      }
    }
    throw Exception('Failed to load post after $maxRetries attempts');
  }

  Future<void> _checkContentWarning(PostView postData) async {
    final labels = postData.labels ?? [];

    if (labels.isNotEmpty) {
      final shouldShowWarning = await LabelUtils.shouldShowWarning(labels);
      final shouldBlurContent = await LabelUtils.shouldBlurContent(labels);
      if (shouldShowWarning) {
        final warningLabels = await LabelUtils.getWarningLabels(labels);
        setState(() {
          _showWarningOverlay = true;
          _warningLabels = warningLabels;
          _shouldBlurContent = shouldBlurContent;
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

  @override
  Widget build(BuildContext context) {
    // Watch for post updates to trigger reload
    final updateCount = ref.watch(postUpdateProvider(widget.postUri));

    if (_lastUpdateCount != updateCount) {
      _lastUpdateCount = updateCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(_loadPost);
        }
      });
    }

    return FutureBuilder<PostView>(
      future: _postFuture,
      builder: (context, snapshot) {
        final postData = snapshot.data;
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        Widget content;

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final mainContent = Stack(
            children: [
              // Main content
              Positioned.fill(
                child: switch (postData!.media) {
                  MediaViewVideo() => PostVideoPlayer(
                    key: _videoPlayerKey,
                    videoUrl: postData.videoUrl,
                    // For standalone, we don't need feed and index
                    thumbnail: postData.thumbnailUrl,
                  ),
                  MediaViewBskyVideo() => PostVideoPlayer(
                    key: _videoPlayerKey,
                    videoUrl: postData.videoUrl,
                    thumbnail: postData.thumbnailUrl,
                  ),
                  MediaViewImages() || MediaViewBskyImages() => ImageCarousel(
                    imageUrls: postData.imageUrls,
                  ),
                  MediaViewBskyRecordWithMedia(:final media) => switch (media) {
                    MediaViewVideo() => PostVideoPlayer(
                      key: _videoPlayerKey,
                      videoUrl: postData.videoUrl,
                      thumbnail: postData.thumbnailUrl,
                    ),
                    MediaViewBskyVideo() => PostVideoPlayer(
                      key: _videoPlayerKey,
                      videoUrl: postData.videoUrl,
                      thumbnail: postData.thumbnailUrl,
                    ),
                    MediaViewImages() || MediaViewBskyImages() => ImageCarousel(
                      imageUrls: postData.imageUrls,
                    ),
                    _ => const SizedBox.shrink(),
                  },
                  _ => const SizedBox.shrink(),
                },
              ),

              // Overlay controls
              Positioned.fill(
                child: PostOverlay(
                  post: postData,
                  isLiked: postData.viewer?.like != null,
                  labels: postData.labels ?? [],
                  onProfilePressed: () {
                    // Pause video before navigating to profile
                    _videoPlayerKey.currentState?.pauseVideo();
                  },
                  onUsernameTap: () {
                    // Pause video before navigating to profile
                    _videoPlayerKey.currentState?.pauseVideo();
                    context.router.push(
                      ProfileRoute(
                        did: postData.author.did,
                        initialProfile: postData.author,
                      ),
                    );
                  },
                ),
              ),
            ],
          );

          if (_showWarningOverlay && _warningLabels.isNotEmpty) {
            content = ContentWarningOverlay(
              onViewContent: () {
                setState(() {
                  _showWarningOverlay = false;
                });
              },
              warningLabels: _warningLabels,
              shouldBlur: _shouldBlurContent,
              child: mainContent,
            );
          } else {
            content = mainContent;
          }
        } else if (snapshot.hasError) {
          content = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading post: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else {
          content = const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: AppColors.black,
          body: Stack(
            children: [
              content,
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.router.maybePop(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: postData == null
              ? null
              : _CommentBar(
                  bottomPadding: bottomPadding,
                  onTap: () {
                    context.router.push(
                      CommentsRoute(
                        postUri: postData.uri.toString(),
                        isSprk: postData.isSprk,
                        post: postData,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _CommentBar extends StatelessWidget {
  const _CommentBar({
    required this.bottomPadding,
    required this.onTap,
  });

  final double bottomPadding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppConstants.blurBottomBar.toDouble(),
          sigmaY: AppConstants.blurBottomBar.toDouble(),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color.fromARGB(51, 0, 0, 0),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 2,
              ),
            ),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 12 + bottomPadding,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Add comment...',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
