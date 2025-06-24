import 'package:atproto/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';

import 'package:sparksocial/src/core/widgets/menu_action_button.dart';
import 'package:sparksocial/src/core/widgets/report_dialog.dart';
import 'package:sparksocial/src/features/feed/providers/delete_post.dart';
import 'package:sparksocial/src/features/feed/providers/like_post.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/action_buttons/profile_action_button.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/action_buttons/like_action_button.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/action_buttons/comment_action_button.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/action_buttons/share_action_button.dart';

class SideActionBar extends ConsumerStatefulWidget {
  final String likeCount;
  final String commentCount;
  final String shareCount;
  final bool isLiked;
  final String? profileImageUrl;
  final PostView post;
  // Add flag to identify image content
  final bool isImage;
  // Add callback for profile navigation to allow pausing video
  final VoidCallback? onProfilePressed;

  const SideActionBar({
    super.key,
    this.likeCount = '0',
    this.commentCount = '0',
    this.shareCount = '0',
    this.isLiked = false,
    this.profileImageUrl,
    required this.post,
    this.isImage = false,
    this.onProfilePressed,
  });

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
            viewer: currentPost.viewer?.copyWith(like: null) ?? Viewer(like: null, repost: currentPost.viewer?.repost),
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
    String postUri = currentPost.uri.toString();
    String shareUrl;
    String embedCode = '';
    bool showEmbed = true;

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
        return SharePanel(shareUrl: shareUrl, embedCode: embedCode, showEmbed: showEmbed);
      },
    );
  }

  void _handleReport(BuildContext context) {
    final currentPost = _currentPost ?? widget.post;
    showDialog(
      context: context,
      builder: (context) => ReportDialog(postUri: currentPost.uri.toString(), postCid: currentPost.cid),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    // Cache context-dependent objects *before* the first await
    final messenger = ScaffoldMessenger.of(context);

    // Confirm deletion
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Post'),
            content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
            actions: [
              TextButton(onPressed: () => context.router.maybePop(false), child: const Text('Cancel')),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => context.router.maybePop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete || !mounted) return;

    try {
      final currentPost = _currentPost ?? widget.post;
      ref.read(deletePostProvider(AtUri.parse(currentPost.uri.toString())));
      messenger.showSnackBar(const SnackBar(content: Text('Post deleted successfully!')));
      if (context.mounted) {
        context.router.popUntilRoot();
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Error deleting post: $e')));
      }
    }
  }

  void _handleProfilePressed() {
    // Call custom callback if provided (for video pausing)
    if (widget.onProfilePressed != null) {
      widget.onProfilePressed!();
    }

    final currentPost = _currentPost ?? widget.post;
    context.router.push(ProfileRoute(did: currentPost.author.did));
  }

  void _handleCommentPressed() {
    final currentPost = _currentPost ?? widget.post;
    context.router.push(CommentsRoute(postUri: currentPost.uri.toString(), isSprk: currentPost.isSprk));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileActionButton(profileImageUrl: widget.profileImageUrl, onPressed: _handleProfilePressed),
        const SizedBox(height: 20),

        LikeActionButton(
          count: (int.parse(widget.likeCount) + (_isLiked ? 1 : 0)).toString(),
          isLiked: _isLiked,
          onPressed: _handleLike,
        ),
        const SizedBox(height: 20),

        CommentActionButton(
          count: (_currentPost?.replyCount ?? int.tryParse(widget.commentCount) ?? 0).toString(),
          onPressed: _handleCommentPressed,
        ),
        const SizedBox(height: 20),

        // Only show share button for videos, not for images
        if (!widget.isImage) ...[
          ShareActionButton(count: widget.shareCount, onPressed: _handleShare),
          const SizedBox(height: 20),
        ],

        MenuActionButton(
          onPressed: () => _handleReport(context),
          onDeletePressed: () async {
            await _handleDelete(context);
            if (context.mounted) {
              context.router.popUntilRoot();
            }
          },
          isOnVideo: true,
          authorDid: (_currentPost ?? widget.post).author.did,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class SharePanel extends StatefulWidget {
  final String shareUrl;
  final String embedCode;
  final bool showEmbed;

  const SharePanel({super.key, required this.shareUrl, required this.embedCode, this.showEmbed = true});

  @override
  State<SharePanel> createState() => _SharePanelState();
}

class _SharePanelState extends State<SharePanel> {
  bool _copiedLink = false;
  bool _copiedEmbed = false;

  void _copyToClipboard(String text, BuildContext context, bool isLink) {
    Clipboard.setData(ClipboardData(text: text));

    setState(() {
      if (isLink) {
        _copiedLink = true;
      } else {
        _copiedEmbed = true;
      }
    });

    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: theme.colorScheme.onPrimary),
            const SizedBox(width: 12),
            Text(isLink ? 'Video link copied!' : 'Embed code copied!'),
          ],
        ),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * 0.9,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          if (isLink) {
            _copiedLink = false;
          } else {
            _copiedEmbed = false;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final fieldBgColor = theme.colorScheme.surfaceContainerHighest;
    final dividerColor = theme.colorScheme.outline.withValues(alpha: 0.2);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 0)],
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(10)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Share Video',
                  style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(color: dividerColor, height: 30),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    Text(
                      'Video link',
                      style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    CopyField(
                      text: widget.shareUrl,
                      context: context,
                      bgColor: fieldBgColor,
                      textColor: textColor,
                      isLink: true,
                      isCopied: _copiedLink,
                      onCopy: _copyToClipboard,
                    ),
                    if (widget.showEmbed) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Video embed',
                        style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      CopyField(
                        text: widget.embedCode,
                        context: context,
                        bgColor: fieldBgColor,
                        textColor: textColor,
                        isLink: false,
                        isCopied: _copiedEmbed,
                        onCopy: _copyToClipboard,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CopyField extends StatelessWidget {
  final String text;
  final BuildContext context;
  final Color bgColor;
  final Color textColor;
  final bool isLink;
  final bool isCopied;
  final Function(String, BuildContext, bool) onCopy;

  const CopyField({
    super.key,
    required this.text,
    required this.context,
    required this.bgColor,
    required this.textColor,
    required this.isLink,
    required this.isCopied,
    required this.onCopy,
  });

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
                      ? Icon(Icons.check_circle, key: const ValueKey('copied'), color: Colors.green, size: 20)
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
