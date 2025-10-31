import 'package:atproto/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/design_system/components/organisms/side_action_bar.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/features/feed/providers/like_post.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/action_buttons/share_panel.dart';

class SideActionBar extends ConsumerStatefulWidget {
  const SideActionBar({
    required this.post,
    super.key,
    this.likeCount = '0',
    this.commentCount = '0',
    this.shareCount = '0',
    this.isLiked = false,
    this.profileImageUrl,
    this.isImage = false,
    this.onProfilePressed,
  });
  final String likeCount;
  final String commentCount;
  final String shareCount;
  final bool isLiked;
  final String? profileImageUrl;
  final PostView post;
  final bool isImage;
  final VoidCallback? onProfilePressed;

  @override
  ConsumerState<SideActionBar> createState() => SideActionBarState();
}

class SideActionBarState extends ConsumerState<SideActionBar> {
  bool _isLiked = false;
  PostView? _currentPost; // Track the current post state locally

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
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
      });
    }
  }

  /// Public method to update like state from external double-tap
  void updateLikeState(PostView updatedPost) {
    if (mounted) {
      setState(() {
        _isLiked = updatedPost.viewer?.like != null;
        _currentPost = updatedPost;
      });
    }
  }

  Future<void> _handleLike() async {
    setState(() {
      _isLiked = !_isLiked;
    });

    try {
      if (_isLiked) {
        // Like the post
        final currentPost = _currentPost ?? widget.post;
        final newLike = await ref.read(likePostProvider(currentPost.cid, currentPost.uri).future);

        // Update the post's viewer field with the new like reference
        final updatedPost = currentPost.copyWith(
          viewer:
              currentPost.viewer?.copyWith(like: newLike.uri) ?? Viewer(like: newLike.uri, repost: currentPost.viewer?.repost),
        );

        // Update cache with the modified post
        await GetIt.instance<SQLCacheInterface>().updatePost(updatedPost);

        // Update the local post reference
        _currentPost = updatedPost;
      } else {
        // Unlike the post
        final currentPost = _currentPost ?? widget.post;
        if (currentPost.viewer?.like != null) {
          await ref.read(unlikePostProvider(AtUri.parse(currentPost.viewer!.like!.toString())).future);

          // Update the post's viewer field to remove the like reference
          final updatedPost = currentPost.copyWith(
            viewer: currentPost.viewer?.copyWith(like: null) ?? Viewer(repost: currentPost.viewer?.repost),
          );

          // Update cache with the modified post
          await GetIt.instance<SQLCacheInterface>().updatePost(updatedPost);

          // Update the local post reference
          _currentPost = updatedPost;
        }
      }
    } catch (e) {
      // Revert the UI state if the operation failed
      setState(() {
        _isLiked = !_isLiked;
      });

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to ${_isLiked ? 'like' : 'unlike'} post: $e')));
      }
    }
  }

  void _handleShare() {
    final currentPost = _currentPost ?? widget.post;
    final originalAtUri = currentPost.uri.toString();
    var postUri = originalAtUri;
    String shareUrl;
    var embedCode = '';
    var showEmbed = true;

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

        // Hide embed for Bluesky
        showEmbed = false;
      } else {
        // Fallback if parsing fails
        shareUrl = 'https://bsky.app';
        showEmbed = false;
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
      embedCode = '<iframe src="embed.html?uri=$postUri" width="100%" height="400" frameborder="0" allowfullscreen></iframe>';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SharePanel(
          shareUrl: shareUrl,
          embedCode: embedCode,
          atUri: originalAtUri,
          showEmbed: showEmbed,
        );
      },
    );
  }

  // TODO: These handlers were part of the old design with profile and menu buttons.
  // They may need to be reintegrated if those UI elements are added back.
  // For now, they're kept for reference but not actively used.

  // void _handleReport(BuildContext context) {
  //   final currentPost = _currentPost ?? widget.post;
  //   showDialog(
  //     context: context,
  //     builder: (context) => ReportDialog(postUri: currentPost.uri.toString(), postCid: currentPost.cid),
  //   );
  // }

  // Future<void> _handleDelete(BuildContext context) async {
  //   final messenger = ScaffoldMessenger.of(context);
  //   final shouldDelete =
  //       await showDialog<bool>(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: const Text('Delete Post'),
  //           content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
  //           actions: [
  //             TextButton(onPressed: () => context.router.maybePop(false), child: const Text('Cancel')),
  //             TextButton(
  //               style: TextButton.styleFrom(foregroundColor: Colors.red),
  //               onPressed: () => context.router.maybePop(true),
  //               child: const Text('Delete'),
  //             ),
  //           ],
  //         ),
  //       ) ??
  //       false;
  //   if (!shouldDelete || !mounted) return;
  //   try {
  //     final currentPost = _currentPost ?? widget.post;
  //     await GetIt.I<SQLCacheInterface>().deletePost(currentPost.uri);
  //     await GetIt.I<SprkRepository>().repo.deleteRecord(uri: currentPost.uri);
  //     final feeds = await GetIt.I<SettingsRepository>().getFeeds();
  //     for (final feed in feeds) {
  //       ref.invalidate(feedNotifierProvider(feed));
  //     }
  //     final did = currentPost.author.did;
  //     ref.invalidate(profileFeedProvider(AtUri.parse('at://$did'), true));
  //     ref.invalidate(profileFeedProvider(AtUri.parse('at://$did'), false));
  //     messenger.showSnackBar(const SnackBar(content: Text('Post deleted successfully!')));
  //     if (context.mounted) {
  //       context.router.popUntilRoot();
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       messenger.showSnackBar(SnackBar(content: Text('Error deleting post: $e')));
  //     }
  //   }
  // }

  // void _handleProfilePressed() {
  //   if (widget.onProfilePressed != null) {
  //     widget.onProfilePressed!();
  //   }
  //   final currentPost = _currentPost ?? widget.post;
  //   context.router.push(ProfileRoute(did: currentPost.author.did));
  // }

  void _handleCommentPressed() {
    final currentPost = _currentPost ?? widget.post;
    context.router.push(CommentsRoute(postUri: currentPost.uri.toString(), isSprk: currentPost.isSprk, post: currentPost));
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
    final likeCount = (int.tryParse(widget.likeCount) ?? 0) + (_isLiked ? 1 : 0);
    final commentCount = currentPost.replyCount ?? int.tryParse(widget.commentCount) ?? 0;
    // final repostCount = currentPost.repostCount ?? int.tryParse(widget.shareCount) ?? 0; // Curation disabled
    // final isCurated = currentPost.viewer?.repost != null; // Curation disabled

    return SparkSideActionBar(
      onLike: _handleLike,
      onComment: _handleCommentPressed,
      // onCurate: _handleCurate, // Curation disabled
      onShare: _handleShare,
      likeCount: likeCount.toString(),
      commentCount: commentCount.toString(),
      // curateCount: repostCount.toString(), // Curation disabled
      shareCount: widget.shareCount,
      isLiked: _isLiked,
      // isCurated: isCurated, // Curation disabled
      // curateDestinations: curateDestinations, // Curation disabled
    );
  }
}

class CopyField extends StatelessWidget {
  const CopyField({
    required this.text,
    required this.context,
    required this.bgColor,
    required this.textColor,
    required this.isLink,
    required this.isCopied,
    required this.onCopy,
    super.key,
  });
  final String text;
  final BuildContext context;
  final Color bgColor;
  final Color textColor;
  final bool isLink;
  final bool isCopied;
  final Function(String, BuildContext, bool) onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                text,
                style: TextStyle(fontFamily: 'monospace', color: textColor.withAlpha(204), fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onCopy(text, context, isLink),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: isCopied
                      ? const Icon(Icons.check_circle, key: ValueKey('copied'), color: Colors.green, size: 20)
                      : Icon(Icons.content_copy_rounded, key: const ValueKey('copy'), color: accentColor, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
