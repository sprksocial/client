import 'package:flutter/material.dart';

import 'action_buttons/comment_action_button.dart';
import 'action_buttons/like_action_button.dart';
import 'action_buttons/profile_action_button.dart';

class VideoSideActionBar extends StatefulWidget {
  final VoidCallback? onProfilePressed;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onSharePressed;

  final String likeCount;
  final String commentCount;
  final String bookmarkCount;
  final String shareCount;
  final bool isLiked;
  final bool isBookmarked;
  final String? profileImageUrl;

  const VideoSideActionBar({
    super.key,
    this.onProfilePressed,
    this.onLikePressed,
    this.onCommentPressed,
    this.onBookmarkPressed,
    this.onSharePressed,

    this.likeCount = '0',
    this.commentCount = '0',
    this.bookmarkCount = '0',
    this.shareCount = '0',

    this.isLiked = false,
    this.isBookmarked = false,
    this.profileImageUrl,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileActionButton(profileImageUrl: widget.profileImageUrl, onPressed: widget.onProfilePressed),
        const SizedBox(height: 20),

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
        const SizedBox(height: 20),

        // ShareActionButton(count: widget.shareCount, onPressed: widget.onSharePressed),
      ],
    );
  }
}
