import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/utils/label_utils.dart';
import 'package:sparksocial/src/core/widgets/content_warning_overlay.dart';
import 'package:sparksocial/src/features/feed/providers/post_updates.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/action_buttons/side_action_bar.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/post/info_bar.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/videos/video_player.dart';

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
  final GlobalKey<PostVideoPlayerState> _videoPlayerKey = GlobalKey<PostVideoPlayerState>();
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
    final sqlCache = GetIt.instance<SQLCacheInterface>();

    try {
      // Try to get from cache first
      return await sqlCache.getPost(widget.postUri);
    } catch (e) {
      // If cache fails, fetch from network
      final feedRepository = GetIt.instance<SprkRepository>().feed;
      final uri = AtUri.parse(widget.postUri);
      var isBlueskyPost = false;
      // try {
      isBlueskyPost = uri.collection.toString().startsWith('app.bsky.feed.post');
      // } catch (e) {
      // what
      // }
      final networkPost = await feedRepository.getPosts([uri], bluesky: isBlueskyPost);

      if (networkPost.isEmpty) {
        throw Exception('Post not found');
      }

      // Cache the post for future use
      await sqlCache.cachePost(networkPost.first);

      return networkPost.first;
    }
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: SafeArea(
        child: _postFuture == null
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<PostView>(
                future: _postFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    final postData = snapshot.data!;

                    final mainContent = Stack(
                      children: [
                        // Main content
                        switch (postData.embed) {
                          EmbedViewVideo() => PostVideoPlayer(
                            key: _videoPlayerKey,
                            videoUrl: postData.videoUrl,
                            // For standalone, we don't need feed and index
                            isSparkPost: true,
                          ),
                          EmbedViewBskyVideo() => PostVideoPlayer(
                            key: _videoPlayerKey,
                            videoUrl: postData.videoUrl,
                            isSparkPost: false,
                          ),
                          EmbedViewImage() || EmbedViewBskyImages() => ImageCarousel(imageUrls: postData.imageUrls),
                          EmbedViewBskyRecordWithMedia(:final media) => switch (media) {
                            EmbedViewVideo() => PostVideoPlayer(
                              key: _videoPlayerKey,
                              videoUrl: postData.videoUrl,
                              isSparkPost: true,
                            ),
                            EmbedViewBskyVideo() => PostVideoPlayer(
                              key: _videoPlayerKey,
                              videoUrl: postData.videoUrl,
                              isSparkPost: false,
                            ),
                            EmbedViewImage() || EmbedViewBskyImages() => ImageCarousel(imageUrls: postData.imageUrls),
                            _ => const SizedBox.shrink(),
                          },
                          _ => const SizedBox.shrink(),
                        },

                        // Side action bar
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: SideActionBar(
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
                          ),
                        ),

                        // Gradient overlay at the bottom to improve text readability
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 20,
                          child: IgnorePointer(
                            child: Container(
                              height: 120, // covers the area behind the InfoBar
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

                        Positioned(
                          bottom: 32,
                          left: 4,
                          right: 80,
                          child: FutureBuilder<List<String>>(
                            future: LabelUtils.getInformLabels(postData.labels ?? []),
                            builder: (context, snapshot) {
                              final informLabels = snapshot.data ?? [];
                              return InfoBar(
                                username: postData.author.handle,
                                description: postData.record.text ?? '',
                                hashtags: postData.record.hashtags,
                                informLabels: informLabels,
                                isSprk: postData.uri.toString().contains('so.sprk'),
                                onUsernameTap: () {
                                  // Pause video before navigating to profile
                                  _videoPlayerKey.currentState?.pauseVideo();
                                  context.router.push(ProfileRoute(did: postData.author.did));
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );

                    // Return main content with warning overlay if needed
                    if (_showWarningOverlay && _warningLabels.isNotEmpty) {
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
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.white, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading post: ${snapshot.error}',
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
      ),
    );
  }
}
