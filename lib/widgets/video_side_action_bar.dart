import 'package:flutter/material.dart';

import 'action_buttons/comment_action_button.dart';
import 'action_buttons/like_action_button.dart';
import 'action_buttons/profile_action_button.dart';
import 'action_buttons/menu_action_button.dart';
import '../services/mod_service.dart';
import '../services/auth_service.dart';
import '../widgets/dialogs/report_dialog.dart';

class VideoSideActionBar extends StatefulWidget {
  final VoidCallback? onProfilePressed;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onReportPressed;

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

  const VideoSideActionBar({
    super.key,
    this.onProfilePressed,
    this.onLikePressed,
    this.onCommentPressed,
    this.onBookmarkPressed,
    this.onSharePressed,
    this.onReportPressed,

    this.likeCount = '0',
    this.commentCount = '0',
    this.bookmarkCount = '0',
    this.shareCount = '0',

    this.isLiked = false,
    this.isBookmarked = false,
    this.profileImageUrl,

    this.postUri,
    this.postCid,
  });

  @override
  State<VideoSideActionBar> createState() => _VideoSideActionBarState();
}

class _VideoSideActionBarState extends State<VideoSideActionBar> {
  late bool _isLiked;
  late bool _isBookmarked;

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
    if (oldWidget.commentCount != widget.commentCount) {
      setState(() {});
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

  @override
  Widget build(BuildContext context) {
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
          onPressed:
              widget.onReportPressed ??
              () {
                // Use inherited widget or dependency injection to get the AuthService
                // This is a placeholder - you need to properly inject AuthService
                final authService = AuthService();
                _handleReport(context, authService);
              },
          isOnVideo: true,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
