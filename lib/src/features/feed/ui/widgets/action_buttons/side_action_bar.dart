import 'package:atproto/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/design_system/components/organisms/side_action_bar.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/ui/widgets/options_panel.dart';
import 'package:spark/src/core/ui/widgets/report_dialog.dart';
import 'package:spark/src/core/utils/blocking_utils.dart';
import 'package:spark/src/features/feed/providers/feed_action_controller.dart';
import 'package:spark/src/features/feed/providers/feed_provider.dart';
import 'package:spark/src/features/feed/providers/like_post.dart';
import 'package:spark/src/features/feed/providers/repost_post.dart';
import 'package:spark/src/features/feed/ui/widgets/action_buttons/share_panel.dart';
import 'package:spark/src/features/profile/providers/profile_feed_provider.dart';

class SideActionBar extends ConsumerStatefulWidget {
  const SideActionBar({
    required this.post,
    super.key,
    this.feed,
    this.likeCount = '0',
    this.commentCount = '0',
    this.shareCount = '0',
    this.isLiked = false,
    this.profileImageUrl,
    this.isImage = false,
    this.onProfilePressed,
    this.showBlockOption = true,
  });
  final Feed? feed;
  final String likeCount;
  final String commentCount;
  final String shareCount;
  final bool isLiked;
  final String? profileImageUrl;
  final PostView post;
  final bool isImage;
  final VoidCallback? onProfilePressed;

  /// Whether to show the block option in the options panel.
  /// Set to false for profile feeds where blocking doesn't make sense.
  final bool showBlockOption;

  @override
  ConsumerState<SideActionBar> createState() => SideActionBarState();
}

class SideActionBarState extends ConsumerState<SideActionBar> {
  bool _isLiked = false;
  bool _isReposted = false;
  int _likeCount = 0;
  int _repostCount = 0;
  PostView? _currentPost; // Track the current post state locally

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _isReposted = widget.post.viewer?.repost != null;
    _likeCount = int.tryParse(widget.likeCount) ?? widget.post.likeCount ?? 0;
    _repostCount = widget.post.repostCount ?? 0;
    _currentPost = widget.post; // Initialize with the original post
  }

  @override
  void didUpdateWidget(SideActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked) {
      setState(() {
        _isLiked = widget.isLiked;
      });
    }
    if (oldWidget.post != widget.post) {
      setState(() {
        _currentPost = widget.post;
        _isReposted = widget.post.viewer?.repost != null;
        _likeCount =
            int.tryParse(widget.likeCount) ?? widget.post.likeCount ?? 0;
        _repostCount = widget.post.repostCount ?? 0;
      });
    }
  }

  /// Public method to update like state from external double-tap
  void updateLikeState(PostView updatedPost) {
    if (mounted) {
      setState(() {
        _isLiked = updatedPost.viewer?.like != null;
        _likeCount = updatedPost.likeCount ?? _likeCount;
        _currentPost = updatedPost;
      });
    }
  }

  Future<void> _handleLike() async {
    HapticFeedback.mediumImpact();
    final wasLiked = _isLiked;
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      if (_isLiked) {
        // Like the post
        final currentPost = _currentPost ?? widget.post;
        final newLike = await ref.read(
          likePostProvider(currentPost.cid, currentPost.uri).future,
        );

        final updatedPost = currentPost.copyWith(
          likeCount: _likeCount,
          viewer:
              currentPost.viewer?.copyWith(like: newLike.uri) ??
              ViewerState(
                like: newLike.uri,
                repost: currentPost.viewer?.repost,
              ),
        );

        if (widget.feed != null) {
          ref
              .read(feedProvider(widget.feed!).notifier)
              .replacePost(updatedPost);
        }

        _currentPost = updatedPost;
      } else {
        // Unlike the post
        final currentPost = _currentPost ?? widget.post;
        if (currentPost.viewer?.like != null) {
          await ref.read(
            unlikePostProvider(
              AtUri.parse(currentPost.viewer!.like!.toString()),
            ).future,
          );

          final updatedPost = currentPost.copyWith(
            likeCount: _likeCount,
            viewer:
                currentPost.viewer?.copyWith(like: null) ??
                ViewerState(repost: currentPost.viewer?.repost),
          );

          if (widget.feed != null) {
            ref
                .read(feedProvider(widget.feed!).notifier)
                .replacePost(updatedPost);
          }

          _currentPost = updatedPost;
        }
      }
    } catch (e) {
      // Revert the UI state if the operation failed
      setState(() {
        _isLiked = wasLiked;
        _likeCount += wasLiked ? 1 : -1;
      });
    }
  }

  Future<void> _handleRepost() async {
    HapticFeedback.lightImpact();
    final wasReposted = _isReposted;
    setState(() {
      _isReposted = !_isReposted;
      _repostCount += _isReposted ? 1 : -1;
    });

    try {
      if (_isReposted) {
        // Repost the post
        final currentPost = _currentPost ?? widget.post;
        final newRepost = await ref.read(
          repostPostProvider(currentPost.cid, currentPost.uri).future,
        );

        final updatedPost = currentPost.copyWith(
          repostCount: _repostCount,
          viewer:
              currentPost.viewer?.copyWith(repost: newRepost.uri) ??
              ViewerState(
                repost: newRepost.uri,
                like: currentPost.viewer?.like,
              ),
        );

        if (widget.feed != null) {
          ref
              .read(feedProvider(widget.feed!).notifier)
              .replacePost(updatedPost);
        }

        _currentPost = updatedPost;
      } else {
        // Unrepost the post
        final currentPost = _currentPost ?? widget.post;
        if (currentPost.viewer?.repost != null) {
          await ref.read(
            unrepostPostProvider(currentPost.viewer!.repost!).future,
          );

          final updatedPost = currentPost.copyWith(
            repostCount: _repostCount,
            viewer:
                currentPost.viewer?.copyWith(repost: null) ??
                ViewerState(like: currentPost.viewer?.like),
          );

          if (widget.feed != null) {
            ref
                .read(feedProvider(widget.feed!).notifier)
                .replacePost(updatedPost);
          }

          _currentPost = updatedPost;
        }
      }
    } catch (e) {
      // Revert the UI state if the operation failed
      setState(() {
        _isReposted = wasReposted;
        _repostCount += wasReposted ? 1 : -1;
      });
    }
  }

  void _handleShare() {
    final currentPost = _currentPost ?? widget.post;
    final originalAtUri = currentPost.uri.toString();
    var postUri = originalAtUri;
    String shareUrl;

    // Special case for Bluesky posts
    if (postUri.contains('/app.bsky.feed.post/')) {
      // Extract the DID and post ID for Bluesky format
      // Format: at://did:plc:xxx/app.bsky.feed.post/yyy -> https://bsky.app/profile/did:plc:xxx/post/yyy

      // Remove 'at://' prefix if present
      if (postUri.startsWith('at://')) {
        postUri = postUri.substring(5);
      }

      // Split to get DID and post ID
      final parts = postUri.split('/app.bsky.feed.post/');
      if (parts.length == 2) {
        final did = parts[0];
        final postId = parts[1];

        // Format as Bluesky URL
        shareUrl = 'https://bsky.app/profile/$did/post/$postId';
      } else {
        // Fallback if parsing fails
        shareUrl = 'https://bsky.app';
      }
    } else {
      // Standard Spark format
      // Remove 'at://' prefix if present
      if (postUri.startsWith('at://')) {
        postUri = postUri.substring(5);
      }

      // Remove 'so.sprk.feed.post/' from the path if present
      postUri = postUri.replaceAll('so.sprk.feed.post/', '');

      shareUrl = 'https://watch.sprk.so/?uri=$postUri';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SharePanel(
          shareUrl: shareUrl,
          atUri: originalAtUri,
        );
      },
    );
  }

  void _handleCommentPressed() {
    final currentPost = _currentPost ?? widget.post;
    context.router.push(
      CommentsRoute(
        postUri: currentPost.uri.toString(),
        isSprk: currentPost.isSprk,
        post: currentPost,
      ),
    );
  }

  void _handleSoundTap() {
    final currentPost = _currentPost ?? widget.post;
    if (currentPost.sound != null) {
      context.router.push(
        SoundRoute(audioUri: currentPost.sound!.uri.toString()),
      );
    }
  }

  void _handleReport() {
    final currentPost = _currentPost ?? widget.post;
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        postUri: currentPost.uri.toString(),
        postCid: currentPost.cid,
      ),
    );
  }

  Future<void> _handleDeletePost() async {
    final currentPost = _currentPost ?? widget.post;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post?'
          '\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final feedRepository = GetIt.instance<SprkRepository>().feed;
      final success = await feedRepository.deletePost(currentPost.uri);
      if (!success) {
        throw Exception('Failed to delete post');
      }

      if (widget.feed != null) {
        final controller = ref.read(
          feedActionControllerProvider(widget.feed!),
        );
        controller?.onAdvanceAndRemove();
      } else {
        final profileUri = AtUri.parse('at://${currentPost.author.did}');
        ref
          ..invalidate(profileFeedProvider(profileUri, false, false))
          ..invalidate(profileFeedProvider(profileUri, true, false));
      }
    } catch (_) {}
  }

  Future<void> _handleBlock() async {
    final currentPost = _currentPost ?? widget.post;
    final author = currentPost.author;
    final wasBlocked = isBlocking(author.viewer);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(wasBlocked ? 'Unblock User' : 'Block User'),
        content: Text(
          wasBlocked
              ? 'Are you sure you want to unblock this user?'
              : 'Are you sure you want to block this user? '
                    'You will no longer see their posts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: wasBlocked ? null : Colors.red,
            ),
            child: Text(wasBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final graphRepository = GetIt.instance<SprkRepository>().graph;
      await graphRepository.toggleBlock(
        author.did,
        author.viewer?.blocking,
      );

      // If blocking and we have a feed, use the action controller to advance
      if (!wasBlocked && widget.feed != null) {
        final controller = ref.read(
          feedActionControllerProvider(widget.feed!),
        );
        controller?.onAdvanceAndRemove();
      }
    } catch (_) {}
  }

  // Future<void> _handleCurate() async {
  //   // For now, this is a placeholder for curate functionality
  //   // In the future, this could add the post to a custom feed or collection
  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Post curated to feed!')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // Curation disabled: do not build curate destinations from feeds

    final currentPost = _currentPost ?? widget.post;
    final authRepository = GetIt.instance<AuthRepository>();
    final userDid = authRepository.did;
    final isCurrentUserAuthor =
        userDid != null && userDid == currentPost.author.did;

    final commentCount =
        currentPost.replyCount ?? int.tryParse(widget.commentCount) ?? 0;
    // final isCurated = currentPost.viewer?.repost != null; // Curation disabled

    return SparkSideActionBar(
      onLike: _handleLike,
      onComment: _handleCommentPressed,
      onRepost: _handleRepost,
      // onCurate: _handleCurate, // Curation disabled
      onShare: _handleShare,
      onSoundTap: currentPost.sound != null ? _handleSoundTap : null,
      onOptions: () => OptionsPanel.show(
        context: context,
        onReport: isCurrentUserAuthor ? null : _handleReport,
        onDelete: isCurrentUserAuthor ? _handleDeletePost : null,
        onBlock: widget.showBlockOption && !isCurrentUserAuthor
            ? _handleBlock
            : null,
        isBlocked: isBlocking(currentPost.author.viewer),
      ),
      likeCount: _likeCount.toString(),
      commentCount: commentCount.toString(),
      repostCount: _repostCount.toString(),
      // curateCount: repostCount.toString(), // Curation disabled
      shareCount: widget.shareCount,
      isLiked: _isLiked,
      isReposted: _isReposted,
      soundCover: currentPost.sound?.coverArt.toString(),
      // isCurated: isCurated, // Curation disabled
      // curateDestinations: curateDestinations, // Curation disabled
    );
  }
}
