import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sparksocial/widgets/action_buttons/share_action_button.dart';
import 'package:flutter/services.dart';

import 'action_buttons/comment_action_button.dart';
import 'action_buttons/like_action_button.dart';
import 'action_buttons/profile_action_button.dart';
import 'action_buttons/menu_action_button.dart';
import '../services/mod_service.dart';
import '../services/auth_service.dart';
import '../services/actions_service.dart';
import '../widgets/dialogs/report_dialog.dart';
// import 'action_buttons/bookmark_action_button.dart';

class VideoSideActionBar extends StatefulWidget {
  final VoidCallback? onProfilePressed;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onReportPressed;
  final VoidCallback? onPostDeleted;

  final String likeCount;
  final String commentCount;
  final String shareCount;
  final bool isLiked;
  final String? profileImageUrl;

  // Add post info for reporting
  final String? postUri;
  final String? postCid;
  final String? authorDid;
  
  // Add flag to identify image content
  final bool isImage;

  const VideoSideActionBar({
    super.key,
    this.onProfilePressed,
    this.onLikePressed,
    this.onCommentPressed,
    this.onSharePressed,
    this.onReportPressed,
    this.onPostDeleted,

    this.likeCount = '0',
    this.commentCount = '0',
    this.shareCount = '0',

    this.isLiked = false,
    this.profileImageUrl,

    this.postUri,
    this.postCid,
    this.authorDid,
    
    this.isImage = false,
  });

  @override
  State<VideoSideActionBar> createState() => _VideoSideActionBarState();
}

class _VideoSideActionBarState extends State<VideoSideActionBar> {
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
  }

  @override
  void didUpdateWidget(VideoSideActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked) {
      setState(() {
        _isLiked = widget.isLiked;
      });
    }
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    if (widget.onLikePressed != null) {
      widget.onLikePressed!();
    }
  }

  void _handleShare() {
    if (widget.postUri == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot share this content')));
      return;
    }
    
    String postUri = widget.postUri!;
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
        return SharePanel(
          shareUrl: shareUrl,
          embedCode: embedCode,
          showEmbed: showEmbed,
        );
      },
    );
    
    if (widget.onSharePressed != null) {
      widget.onSharePressed!();
    }
  }

  void _handleReport(BuildContext context, AuthService authService) {
    if (widget.postUri == null || widget.postCid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot report this content')));
      return;
    }

    final modService = ModService(authService);

    showDialog(
      context: context,
      builder:
          (context) => ReportDialog(
            postUri: widget.postUri!,
            postCid: widget.postCid!,
            onSubmit: (subject, reasonType, reason, service) async {
              // Cache ScaffoldMessenger before await
              final messenger = ScaffoldMessenger.of(context);
              try {
                final result = await modService.createReport(
                  subject: subject,
                  reasonType: reasonType,
                  reason: reason,
                  service: service,
                );

                // Use cached messenger
                if (result) {
                  messenger.showSnackBar(const SnackBar(content: Text('Report submitted successfully')));
                }
              } catch (e) {
                // Use cached messenger
                messenger.showSnackBar(SnackBar(content: Text('Error submitting report: $e')));
              }
            },
          ),
    );
  }

  void _handleDelete(BuildContext context) async {
    if (widget.postUri == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot delete this post')));
      return;
    }

    // Cache context-dependent objects *before* the first await (showDialog)
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final actionsService = Provider.of<ActionsService>(context, listen: false);

    // Confirm deletion
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Post'),
                content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        ) ??
        false;

    if (!shouldDelete || !mounted) return;

    try {
      final result = await actionsService.deletePost(widget.postUri!);

      // Check mounted ONLY if further async operations depend on the widget state
      if (!mounted) return;

      if (result) {
        // Use cached messenger
        messenger.showSnackBar(const SnackBar(content: Text('Post deleted successfully')));

        await Future.delayed(const Duration(milliseconds: 800));

        // Check mounted again after delay, before potentially interacting with widget state or navigator
        if (!mounted) return;

        if (widget.onPostDeleted != null) {
          widget.onPostDeleted!();
        }

        // Use cached navigator
        if (navigator.canPop()) {
          navigator.pop(true);
        }
      } else {
        // Use cached messenger
        messenger.showSnackBar(const SnackBar(content: Text('Failed to delete post')));
      }
    } catch (e) {
      // Use cached messenger (check mounted only if error handling depends on widget state)
      if (mounted) { // Keep this check if error handling logic might change based on state
        messenger.showSnackBar(SnackBar(content: Text('Error deleting post: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Column(
      children: [
        ProfileActionButton(profileImageUrl: widget.profileImageUrl, onPressed: widget.onProfilePressed),
        const SizedBox(height: 30),

        LikeActionButton(count: widget.likeCount, isLiked: _isLiked, onPressed: _handleLike),
        const SizedBox(height: 20),

        CommentActionButton(count: widget.commentCount, onPressed: widget.onCommentPressed),
        const SizedBox(height: 20),

        // Only show share button for videos, not for images
        if (!widget.isImage) ...[
          ShareActionButton(count: widget.shareCount, onPressed: _handleShare),
          const SizedBox(height: 20),
        ],

        MenuActionButton(
          onPressed: widget.onReportPressed ?? () => _handleReport(context, authService),
          onDeletePressed: () => _handleDelete(context),
          isOnVideo: true,
          authorDid: widget.authorDid,
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
  
  const SharePanel({
    super.key,
    required this.shareUrl,
    required this.embedCode,
    this.showEmbed = true,
  });

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
            const Icon(Icons.check_circle, color: Colors.white),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1F1F1F) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final fieldBgColor = isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5);
    final dividerColor = isDarkMode ? Colors.white24 : Colors.black12;
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
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
                decoration: BoxDecoration(
                  color: dividerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Share Video',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCopyField(widget.shareUrl, context, fieldBgColor, textColor, true, _copiedLink),
                    if (widget.showEmbed) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Video embed',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCopyField(widget.embedCode, context, fieldBgColor, textColor, false, _copiedEmbed),
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
  
  Widget _buildCopyField(String text, BuildContext context, Color bgColor, Color textColor, bool isLink, bool isCopied) {
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
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: textColor.withAlpha(204),
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _copyToClipboard(text, context, isLink),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: isCopied 
                    ? Icon(
                        Icons.check_circle,
                        key: const ValueKey('copied'),
                        color: Colors.green,
                        size: 20,
                      )
                    : Icon(
                        Icons.content_copy_rounded,
                        key: const ValueKey('copy'),
                        color: accentColor,
                        size: 20,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
