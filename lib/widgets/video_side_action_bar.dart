import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'action_buttons/comment_action_button.dart';
import 'action_buttons/like_action_button.dart';
import 'action_buttons/profile_action_button.dart';
import 'action_buttons/menu_action_button.dart';
import '../services/mod_service.dart';
import '../services/auth_service.dart';
import '../services/actions_service.dart';
import '../widgets/dialogs/report_dialog.dart';

class VideoSideActionBar extends StatefulWidget {
  final VoidCallback? onProfilePressed;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onReportPressed;
  final VoidCallback? onPostDeleted;

  final String likeCount;
  final String commentCount;
  final String bookmarkCount;
  final String shareCount;
  final bool isLiked;
  final bool isBookmarked;
  final String? profileImageUrl;

  // Add post info for reporting
  final String? postUri;
  final String? postCid;
  final String? authorDid;

  const VideoSideActionBar({
    super.key,
    this.onProfilePressed,
    this.onLikePressed,
    this.onCommentPressed,
    this.onBookmarkPressed,
    this.onSharePressed,
    this.onReportPressed,
    this.onPostDeleted,

    this.likeCount = '0',
    this.commentCount = '0',
    this.bookmarkCount = '0',
    this.shareCount = '0',

    this.isLiked = false,
    this.isBookmarked = false,
    this.profileImageUrl,

    this.postUri,
    this.postCid,
    this.authorDid,
  });

  @override
  State<VideoSideActionBar> createState() => _VideoSideActionBarState();
}

class _VideoSideActionBarState extends State<VideoSideActionBar> {
  bool _isLiked = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _isBookmarked = widget.isBookmarked;
  }

  @override
  void didUpdateWidget(VideoSideActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked) {
      setState(() {
        _isLiked = widget.isLiked;
      });
    }
    if (oldWidget.isBookmarked != widget.isBookmarked) {
      setState(() {
        _isBookmarked = widget.isBookmarked;
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

  void _handleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    if (widget.onBookmarkPressed != null) {
      widget.onBookmarkPressed!();
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
              try {
                final result = await modService.createReport(
                  subject: subject,
                  reasonType: reasonType,
                  reason: reason,
                  service: service,
                );

                if (result) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted successfully')));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting report: $e')));
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
      final actionsService = Provider.of<ActionsService>(context, listen: false);
      final result = await actionsService.deletePost(widget.postUri!);

      if (result) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post deleted successfully')));

          // Add a delay to ensure the server has processed the deletion
          await Future.delayed(const Duration(milliseconds: 800));

          // Check if widget is still mounted after the delay
          if (!mounted) return;

          // Notify parent that post was deleted
          if (widget.onPostDeleted != null) {
            widget.onPostDeleted!();
          }

          // Check if we can navigate back (for profile view)
          if (Navigator.of(context).canPop()) {
            // Pop back to the previous screen with result=true to indicate post was deleted
            Navigator.of(context).pop(true);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete post')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting post: $e')));
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

        // BookmarkActionButton(
        //   count: widget.bookmarkCount,
        //   isBookmarked: _isBookmarked,
        //   onPressed: _handleBookmark,
        //   key: const ValueKey('bookmark_button'), // Add a stable key
        // ),
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
