import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/comments/like_button.dart';
import 'package:sparksocial/widgets/common/user_avatar.dart';

class CommentReplyItem extends StatefulWidget {
  final String id;
  final String userId;
  final String username;
  final String text;
  final String timeAgo;
  final int likeCount;
  final Function(String, String) onReply;
  final String? profileImageUrl;
  final VoidCallback? onLikePressed;
  final bool isLiked;

  const CommentReplyItem({
    super.key,
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
    required this.timeAgo,
    required this.likeCount,
    required this.onReply,
    this.profileImageUrl,
    this.onLikePressed,
    this.isLiked = false,
  });

  @override
  State<CommentReplyItem> createState() => _CommentReplyItemState();
}

class _CommentReplyItemState extends State<CommentReplyItem> {
  bool _isLiked = false;
  bool _isLikeLoading = false;
  final _logger = GetIt.instance<LogService>().getLogger('CommentReplyItem');

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
  }

  @override
  void didUpdateWidget(CommentReplyItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isLikeLoading && oldWidget.isLiked != widget.isLiked) {
      setState(() {
        _isLiked = widget.isLiked;
      });
    }
  }

  void _toggleLike() {
    if (_isLikeLoading) return;

    _logger.d('Like toggled for reply: ${widget.id}');

    setState(() {
      _isLikeLoading = true;
      _isLiked = !_isLiked;
    });

    if (widget.onLikePressed != null) {
      widget.onLikePressed!();
    }

    // Reset loading state after a short delay to ensure smooth animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLikeLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          UserAvatar(imageUrl: widget.profileImageUrl, username: widget.username, size: 28, borderWidth: 1),
          const SizedBox(width: 8),
          Expanded(
            child: _ReplyContent(
              username: widget.username,
              timeAgo: widget.timeAgo,
              text: widget.text,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
              isLiked: _isLiked,
              likeCount: widget.likeCount,
              onLikePressed: _toggleLike,
              onReplyPressed: () => widget.onReply(widget.userId, widget.username),
              isLikeLoading: _isLikeLoading,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyContent extends StatelessWidget {
  final String username;
  final String timeAgo;
  final String text;
  final Color textColor;
  final Color secondaryTextColor;
  final bool isLiked;
  final bool isLikeLoading;
  final int likeCount;
  final VoidCallback onLikePressed;
  final VoidCallback onReplyPressed;

  const _ReplyContent({
    required this.username,
    required this.timeAgo,
    required this.text,
    required this.textColor,
    required this.secondaryTextColor,
    required this.isLiked,
    required this.likeCount,
    required this.onLikePressed,
    required this.onReplyPressed,
    required this.isLikeLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(username, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13)),
            const SizedBox(width: 6),
            Text(timeAgo, style: TextStyle(fontSize: 11, color: secondaryTextColor)),
          ],
        ),
        const SizedBox(height: 2),
        Text(text, style: TextStyle(color: textColor, fontSize: 13)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            LikeButton(
              isLiked: isLiked,
              isLoading: isLikeLoading,
              likeCount: likeCount,
              onPressed: onLikePressed,
              textColor: secondaryTextColor,
              fontSize: 11,
              iconSize: 12,
            ),
            const SizedBox(width: 16),
            _ReplyButton(onPressed: onReplyPressed, textColor: secondaryTextColor),
          ],
        ),
      ],
    );
  }
}

class _ReplyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color textColor;

  const _ReplyButton({required this.onPressed, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Text('Reply', style: TextStyle(fontSize: 11, color: textColor)),
    );
  }
}
