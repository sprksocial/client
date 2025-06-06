import 'package:atproto/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';

import 'package:sparksocial/src/core/theme/data/models/colors.dart';
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

  const SideActionBar({
    super.key,
    this.likeCount = '0',
    this.commentCount = '0',
    this.shareCount = '0',
    this.isLiked = false,
    this.profileImageUrl,
    required this.post,
    this.isImage = false,
  });

  @override
  ConsumerState<SideActionBar> createState() => _VideoSideActionBarState();
}

class _VideoSideActionBarState extends ConsumerState<SideActionBar> {
  late PostView _post;
  bool _isLiked = false;
  late String _commentCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _commentCount = widget.commentCount;
    _post = widget.post;
  }

  @override
  void didUpdateWidget(SideActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked) {
      setState(() {
        _isLiked = widget.isLiked;
      });
    }
    if (oldWidget.commentCount != widget.commentCount) {
      setState(() {
        _commentCount = widget.commentCount;
      });
    }
  }

  Future<void> _handleLike() async {
    setState(() {
      _isLiked = !_isLiked;
    });
    if (_isLiked) {
      final newLike = ref.read(likePostProvider(widget.post.cid, widget.post.uri));
      newLike.whenData((data) {
        final newViewer = Viewer(like: data.uri);
        _post = _post.copyWith(viewer: _post.viewer?.copyWith(like: data.uri) ?? newViewer);
      });
      await GetIt.instance<SQLCacheInterface>().updatePost(widget.post);
    } else {
      ref.read(unlikePostProvider(AtUri.parse(_post.viewer!.like!.toString())));
      _post = _post.copyWith(viewer: _post.viewer?.copyWith(like: null));
      await GetIt.instance<SQLCacheInterface>().updatePost(widget.post);
    }
  }

  void _handleShare() {
    String postUri = widget.post.uri.toString();
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
    showDialog(
      context: context,
      builder: (context) => ReportDialog(postUri: widget.post.uri.toString(), postCid: widget.post.cid),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    // Cache context-dependent objects *before* the first await
    final messenger = ScaffoldMessenger.of(context);

    // Confirm deletion
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
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
      ref.read(deletePostProvider(AtUri.parse(widget.post.uri.toString())));
      messenger.showSnackBar(const SnackBar(content: Text('Post deleted successfully!')));
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Error deleting post: $e')));
      }
    }
  }

  void _handleProfilePressed() {
    context.router.push(ProfileRoute(did: widget.post.author.did));
  }

  void _handleCommentPressed() {
    context.router.push(CommentsRoute(postUri: widget.post.uri.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileActionButton(profileImageUrl: widget.profileImageUrl, onPressed: _handleProfilePressed),
        const SizedBox(height: 20),

        LikeActionButton(
          count: (int.parse(widget.likeCount) + (_post.viewer?.like != null ? 1 : 0)).toString(),
          isLiked: _isLiked,
          onPressed: _handleLike,
        ),
        const SizedBox(height: 20),

        CommentActionButton(count: _commentCount, onPressed: _handleCommentPressed),
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
          authorDid: widget.post.author.did,
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

    // Update state to show copied indicator
    setState(() {
      if (isLink) {
        _copiedLink = true;
      } else {
        _copiedEmbed = true;
      }
    });

    // Show a more noticeable snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.textOnDark),
            const SizedBox(width: 12),
            Text(isLink ? 'Video link copied!' : 'Embed code copied!'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * 0.9,
        duration: const Duration(seconds: 2),
      ),
    );

    // Reset the copied state after 2 seconds
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
    final backgroundColor = AppColors.background;
    final textColor = AppColors.textPrimary;
    final fieldBgColor = const Color(0xFFF5F5F5);
    final dividerColor = Colors.black12;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(51), blurRadius: 10, spreadRadius: 0)],
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
                child: Text('Share Video', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Divider(color: dividerColor, height: 30),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    Text('Video link', style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500)),
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
                      Text('Video embed', style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500)),
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
                  child:
                      isCopied
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
