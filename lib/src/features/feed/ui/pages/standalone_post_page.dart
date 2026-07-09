import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_overlay_back_button.dart';
import 'package:spark/src/core/design_system/tokens/constants.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/media/media_playback_gate.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_video_aspect_ratio.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/ui/widgets/content_warning_overlay.dart';
import 'package:spark/src/core/utils/label_utils.dart';
import 'package:spark/src/features/feed/providers/post_updates.dart';
import 'package:spark/src/features/feed/navigation/standalone_post_navigation_resolver.dart';
import 'package:spark/src/features/feed/ui/widgets/images/image_carousel.dart';
import 'package:spark/src/features/feed/ui/widgets/post/post_overlay.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_player.dart';
import 'package:spark/src/features/settings/providers/preferences_provider.dart';

@RoutePage()
class StandalonePostPage extends ConsumerStatefulWidget {
  const StandalonePostPage({
    required this.postUri,
    super.key,
    this.highlightedReplyUri,
  });

  final String postUri;
  final String? highlightedReplyUri;

  @override
  ConsumerState<StandalonePostPage> createState() => _StandalonePostPageState();
}

class _StandalonePostPageState extends ConsumerState<StandalonePostPage> {
  Future<ResolvedStandalonePost>? _postFuture;
  final GlobalKey<PostVideoPlayerState> _videoPlayerKey =
      GlobalKey<PostVideoPlayerState>();
  bool _showWarningOverlay = false;
  List<String> _warningLabels = [];
  bool _shouldBlurContent = false;
  bool _hasOpenedHighlightedReply = false;
  String? _activePostUri;
  ProviderSubscription<int>? _anchorUpdateSubscription;
  ProviderSubscription<int>? _resolvedUpdateSubscription;

  @override
  void initState() {
    super.initState();
    _anchorUpdateSubscription = ref.listenManual<int>(
      postUpdateProvider(widget.postUri),
      _handlePostUpdate,
    );
    _loadPost();
  }

  @override
  void dispose() {
    _anchorUpdateSubscription?.close();
    _resolvedUpdateSubscription?.close();
    super.dispose();
  }

  void _loadPost() {
    _postFuture = _loadResolvedPost();
    _postFuture?.then((resolvedPost) {
      if (mounted) {
        _activePostUri = resolvedPost.post.uri.toString();
        _bindResolvedPostUpdates(_activePostUri);
        _checkContentWarning(resolvedPost.post);
        _openHighlightedReplyIfNeeded(resolvedPost);
      }
    });
  }

  void _handlePostUpdate(int? previous, int next) {
    if (previous == null || previous == next || !mounted) return;
    setState(_loadPost);
  }

  void _bindResolvedPostUpdates(String? postUri) {
    if (postUri == null || postUri == widget.postUri) {
      _resolvedUpdateSubscription?.close();
      _resolvedUpdateSubscription = null;
      return;
    }

    _resolvedUpdateSubscription?.close();
    _resolvedUpdateSubscription = ref.listenManual<int>(
      postUpdateProvider(postUri),
      _handlePostUpdate,
    );
  }

  void _openHighlightedReplyIfNeeded(ResolvedStandalonePost resolvedPost) {
    if (resolvedPost.highlightedReplyUri == null ||
        _hasOpenedHighlightedReply) {
      return;
    }

    _hasOpenedHighlightedReply = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pushHighlightedReplyRoute(resolvedPost);
    });
  }

  Future<void> _pushHighlightedReplyRoute(
    ResolvedStandalonePost resolvedPost, {
    int attempt = 0,
  }) async {
    if (!mounted) return;

    final route = ModalRoute.of(context);
    final isCurrentRoute = route?.isCurrent ?? false;
    if (!isCurrentRoute && attempt < 10) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return _pushHighlightedReplyRoute(resolvedPost, attempt: attempt + 1);
    }

    if (!mounted) return;

    context.router.push(
      CommentsRoute(
        postUri: resolvedPost.post.uri.toString(),
        isSprk: resolvedPost.post.isSprk,
        post: resolvedPost.post,
        highlightedReplyUri: resolvedPost.highlightedReplyUri,
        children: _buildInitialCommentChildren(resolvedPost),
      ),
    );
  }

  List<PageRouteInfo>? _buildInitialCommentChildren(
    ResolvedStandalonePost resolvedPost,
  ) {
    final parentReplyUris = resolvedPost.parentReplyUris;
    if (parentReplyUris.isEmpty) {
      return null;
    }

    return [
      const CommentsListRoute(),
      for (var i = 0; i < parentReplyUris.length; i++)
        RepliesRoute(
          postUri: parentReplyUris[i],
          highlightedReplyUri: i == parentReplyUris.length - 1
              ? resolvedPost.highlightedReplyUri
              : null,
        ),
    ];
  }

  Future<ResolvedStandalonePost> _loadResolvedPost() {
    final feedRepository = GetIt.instance<SprkRepository>().feed;
    return StandalonePostNavigationResolver(feedRepository).resolve(
      postUri: widget.postUri,
      highlightedReplyUri: widget.highlightedReplyUri,
    );
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
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<ResolvedStandalonePost>(
      future: _postFuture,
      builder: (context, snapshot) {
        final resolvedPost = snapshot.data;
        final postData = resolvedPost?.post;
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        Widget content;

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final mainContent = Stack(
            children: [
              // Main content
              Positioned.fill(
                child: postData!.videoUrl.isNotEmpty
                    ? MediaPlaybackGate(
                        isActive: true,
                        builder: (context, shouldPlay) {
                          return PostVideoPlayer(
                            key: _videoPlayerKey,
                            videoUrl: postData.videoUrl,
                            thumbnail: postData.thumbnailUrl,
                            isActive: shouldPlay,
                            videoAspectRatio: postData.videoAspectRatio,
                          );
                        },
                      )
                    : postData.imageUrls.isNotEmpty
                    ? ImageCarousel(imageUrls: postData.imageUrls)
                    : const SizedBox.shrink(),
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
                    final isBskyPost = postData.uri.collection
                        .toString()
                        .startsWith('app.bsky');
                    context.router.push(
                      ProfileRoute(
                        did: postData.author.did,
                        initialProfile: postData.author,
                        bsky: isBskyPost,
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
                const Icon(Icons.error, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                Text(
                  l10n.errorWithDetail(snapshot.error.toString()),
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
              const Positioned(top: 0, left: 0, child: AppOverlayBackButton()),
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
  const _CommentBar({required this.bottomPadding, required this.onTap});

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
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
