import 'dart:ui';
import 'package:atproto_core/atproto_core.dart';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_overlay_back_button.dart';
import 'package:spark/src/core/design_system/tokens/constants.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
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
import 'package:spark/src/features/settings/providers/preferences_provider.dart';

@RoutePage()
class StandalonePostPage extends ConsumerStatefulWidget {
  const StandalonePostPage({required this.postUri, super.key});

  final String postUri;

  @override
  ConsumerState<StandalonePostPage> createState() => _StandalonePostPageState();
}

class _StandalonePostPageState extends ConsumerState<StandalonePostPage> {
  Future<_ResolvedStandalonePost>? _postFuture;
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

  void _openHighlightedReplyIfNeeded(_ResolvedStandalonePost resolvedPost) {
    final targetReplyUri = resolvedPost.targetReplyUri;
    if (targetReplyUri == null || _hasOpenedHighlightedReply) return;

    _hasOpenedHighlightedReply = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pushHighlightedReplyRoute(resolvedPost, targetReplyUri);
    });
  }

  Future<void> _pushHighlightedReplyRoute(
    _ResolvedStandalonePost resolvedPost,
    String targetReplyUri, {
    int attempt = 0,
  }) async {
    if (!mounted) return;

    final route = ModalRoute.of(context);
    final isCurrentRoute = route?.isCurrent ?? false;
    if (!isCurrentRoute && attempt < 10) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return _pushHighlightedReplyRoute(
        resolvedPost,
        targetReplyUri,
        attempt: attempt + 1,
      );
    }

    if (!mounted) return;

    final initialChildren = _buildInitialCommentChildren(
      resolvedPost,
      targetReplyUri,
    );

    context.router.push(
      CommentsRoute(
        postUri: resolvedPost.post.uri.toString(),
        isSprk: resolvedPost.post.isSprk,
        post: resolvedPost.post,
        highlightedReplyUri: targetReplyUri,
        children: initialChildren,
      ),
    );
  }

  List<PageRouteInfo>? _buildInitialCommentChildren(
    _ResolvedStandalonePost resolvedPost,
    String targetReplyUri,
  ) {
    final parentUris = resolvedPost.replyChainUris;
    if (parentUris.isEmpty) {
      return null;
    }

    return [
      const CommentsListRoute(),
      for (var i = 0; i < parentUris.length; i++)
        RepliesRoute(
          postUri: parentUris[i],
          highlightedReplyUri: i == parentUris.length - 1
              ? targetReplyUri
              : null,
        ),
    ];
  }

  Future<_ResolvedStandalonePost> _loadResolvedPost() async {
    final feedRepository = GetIt.instance<SprkRepository>().feed;
    final uri = AtUri.parse(widget.postUri);

    try {
      final thread = await feedRepository.getThread(
        uri,
        depth: 1,
        parentHeight: 50,
        bluesky: _isBlueskyPost(uri),
      );

      if (thread case ThreadViewPost()) {
        return _resolveThreadNavigation(thread);
      }
    } catch (_) {
      // Fallback below preserves existing "open the anchor directly" behavior.
    }

    final post = await _loadPostWithFallback(uri);
    return _ResolvedStandalonePost(post: post);
  }

  Future<_ResolvedStandalonePost> _resolveThreadNavigation(
    ThreadViewPost thread,
  ) async {
    final anchorThread = _findThreadByUri(thread, widget.postUri) ?? thread;
    final rawReplyPath = _findReplyPath(thread, widget.postUri);
    final replyPath =
        rawReplyPath != null &&
            rawReplyPath.length == 1 &&
            rawReplyPath.first.post.uri.toString() == widget.postUri &&
            rawReplyPath.first.parent is ThreadViewPost
        ? null
        : rawReplyPath;
    final rootThread = replyPath?.first ?? _findRootThread(anchorThread);
    final displayPost = await _getDisplayPost(rootThread);
    final anchorIsReply =
        (replyPath != null && replyPath.length > 1) ||
        anchorThread.parent is ThreadViewPost ||
        anchorThread.post is ThreadReplyView;

    return _ResolvedStandalonePost(
      post: displayPost,
      targetReplyUri: anchorIsReply ? widget.postUri : null,
      replyChainUris: anchorIsReply
          ? (replyPath != null
                ? _collectReplyChainUrisFromPath(replyPath)
                : _collectIntermediateReplyUris(anchorThread))
          : const <String>[],
    );
  }

  ThreadViewPost? _findThreadByUri(
    ThreadViewPost thread,
    String targetUri, {
    Set<String>? visited,
  }) {
    final seen = visited ?? <String>{};
    final currentUri = thread.post.uri.toString();
    if (!seen.add(currentUri)) return null;
    if (currentUri == targetUri) return thread;

    if (thread.parent case ThreadViewPost parentThread) {
      final match = _findThreadByUri(parentThread, targetUri, visited: seen);
      if (match != null) {
        return match;
      }
    }

    final replies = thread.replies;
    if (replies != null) {
      for (final reply in replies) {
        if (reply is! ThreadViewPost) continue;
        final match = _findThreadByUri(reply, targetUri, visited: seen);
        if (match != null) {
          return match;
        }
      }
    }

    return null;
  }

  List<ThreadViewPost>? _findReplyPath(
    ThreadViewPost thread,
    String targetUri, {
    Set<String>? visited,
  }) {
    final seen = visited ?? <String>{};
    final currentUri = thread.post.uri.toString();
    if (!seen.add(currentUri)) return null;
    if (currentUri == targetUri) return [thread];

    final replies = thread.replies;
    if (replies == null) return null;

    for (final reply in replies) {
      if (reply is! ThreadViewPost) continue;
      final childPath = _findReplyPath(reply, targetUri, visited: {...seen});
      if (childPath != null) {
        return [thread, ...childPath];
      }
    }

    return null;
  }

  ThreadViewPost _findRootThread(ThreadViewPost thread) {
    var current = thread;
    while (true) {
      final parentThread = current.parent;
      if (parentThread is! ThreadViewPost) {
        return current;
      }
      current = parentThread;
    }
  }

  List<String> _collectIntermediateReplyUris(ThreadViewPost anchorThread) {
    final replyUris = <String>[];
    var current = anchorThread.parent;

    while (current is ThreadViewPost) {
      final currentPost = current.post;
      if (current.parent is ThreadViewPost && currentPost is ThreadReplyView) {
        final reply = currentPost.reply;
        replyUris.add(reply.uri.toString());
      }
      current = current.parent;
    }

    return replyUris.reversed.toList(growable: false);
  }

  List<String> _collectReplyChainUrisFromPath(List<ThreadViewPost> replyPath) {
    if (replyPath.length < 3) return const <String>[];
    return replyPath
        .sublist(1, replyPath.length - 1)
        .map((thread) => thread.post.uri.toString())
        .toList(growable: false);
  }

  Future<PostView> _getDisplayPost(ThreadViewPost rootThread) async {
    if (rootThread.post case ThreadPostView(:final post)) {
      return post;
    }

    return _loadPostWithFallback(rootThread.post.uri);
  }

  Future<PostView> _loadPostWithFallback(AtUri uri) async {
    final feedRepository = GetIt.instance<SprkRepository>().feed;
    const maxRetries = 3;
    const delay = Duration(seconds: 2);

    for (var i = 0; i < maxRetries; i++) {
      final networkPost = await feedRepository.getPosts([
        uri,
      ], bluesky: _isBlueskyPost(uri));
      if (networkPost.isNotEmpty) {
        return networkPost.first;
      }
      if (i < maxRetries - 1) {
        await Future.delayed(delay);
      }
    }

    throw Exception('Failed to load post after $maxRetries attempts');
  }

  bool _isBlueskyPost(AtUri uri) {
    return uri.collection.toString().startsWith('app.bsky.feed.post');
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

    return FutureBuilder<_ResolvedStandalonePost>(
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

class _ResolvedStandalonePost {
  const _ResolvedStandalonePost({
    required this.post,
    this.targetReplyUri,
    this.replyChainUris = const <String>[],
  });

  final PostView post;
  final String? targetReplyUri;
  final List<String> replyChainUris;
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
