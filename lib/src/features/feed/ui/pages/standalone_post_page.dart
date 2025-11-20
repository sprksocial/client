import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/ui/widgets/content_warning_overlay.dart';
import 'package:sparksocial/src/core/utils/label_utils.dart';
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
    final feedRepository = GetIt.instance<SprkRepository>().feed;
    final uri = AtUri.parse(widget.postUri);
    final isBlueskyPost = uri.collection.toString().startsWith('app.bsky.feed.post');
    const maxRetries = 3;
    const delay = Duration(seconds: 2);
    for (var i = 0; i < maxRetries; i++) {
      final networkPost = await feedRepository.getPosts([uri], bluesky: isBlueskyPost);
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: const AppLeadingButton()),
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
                        switch (postData.media) {
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
                          MediaViewImages() || MediaViewBskyImages() => ImageCarousel(imageUrls: postData.imageUrls),
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
                            MediaViewImages() || MediaViewBskyImages() => ImageCarousel(imageUrls: postData.imageUrls),
                            _ => const SizedBox.shrink(),
                          },
                          _ => const SizedBox.shrink(),
                        },

                        // Gradient overlay at the bottom to improve text readability
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: IgnorePointer(
                            child: Container(
                              height: 80, // covers the area behind the InfoBar
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black87.withAlpha(170), Colors.transparent],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Side action bar
                        Positioned(
                          bottom: 20,
                          right: 4,
                          child: SideActionBar(
                            post: postData,
                            likeCount: '${postData.likeCount ?? 0}',
                            commentCount: '${postData.replyCount ?? 0}',
                            shareCount: '${postData.repostCount ?? 0}',
                            isLiked: postData.viewer?.like != null,
                            profileImageUrl: postData.author.avatar.toString(),
                            isImage: postData.media is MediaViewImages || postData.media is MediaViewBskyImages,
                            onProfilePressed: () {
                              // Pause video before navigating to profile
                              _videoPlayerKey.currentState?.pauseVideo();
                            },
                          ),
                        ),

                        Positioned(
                          bottom: 20,
                          left: 4,
                          right: 80,
                          child: FutureBuilder<List<String>>(
                            future: LabelUtils.getInformLabels(postData.labels ?? []),
                            builder: (context, snapshot) {
                              final informLabels = snapshot.data ?? [];
                              return InfoBar(
                                username: postData.author.handle,
                                displayName: postData.author.displayName ?? postData.author.handle,
                                avatarUrl: postData.author.avatar?.toString(),
                                description: postData.displayText,
                                hashtags: postData.record.hashtags,
                                informLabels: informLabels,
                                audio: postData.sound,
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
