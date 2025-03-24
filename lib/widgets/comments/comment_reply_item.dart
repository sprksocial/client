import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../utils/app_colors.dart';

class CommentReplyItem extends StatefulWidget {
  final String id;
  final String userId;
  final String username;
  final String text;
  final String timeAgo;
  final int likeCount;
  final bool isDarkMode;
  final Function(String, String) onReply;

  const CommentReplyItem({
    super.key,
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
    required this.timeAgo,
    required this.likeCount,
    required this.isDarkMode,
    required this.onReply,
  });

  @override
  State<CommentReplyItem> createState() => _CommentReplyItemState();
}

class _CommentReplyItemState extends State<CommentReplyItem> {
  bool _isLiked = false;

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? AppColors.textLight : AppColors.textPrimary;
    final secondaryTextColor = widget.isDarkMode ? AppColors.textLight.withAlpha(179) : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 8),
          Expanded(child: _buildReplyContent(textColor, secondaryTextColor)),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(204),
        shape: BoxShape.circle,
        border: Border.all(color: widget.isDarkMode ? AppColors.deepPurple : AppColors.lightLavender, width: 1),
      ),
      child: Center(
        child: Text(
          widget.username.isNotEmpty ? widget.username[0].toUpperCase() : '?',
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildReplyContent(Color textColor, Color secondaryTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.username, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13)),
            const SizedBox(width: 6),
            Text(widget.timeAgo, style: TextStyle(fontSize: 11, color: secondaryTextColor)),
          ],
        ),
        const SizedBox(height: 2),

        Text(widget.text, style: TextStyle(color: textColor, fontSize: 13)),

        const SizedBox(height: 4),
        _buildActionButtons(secondaryTextColor),
      ],
    );
  }

  Widget _buildActionButtons(Color secondaryTextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildLikeButton(secondaryTextColor),
        const SizedBox(width: 16),
        _buildReplyButton(secondaryTextColor),
      ],
    );
  }

  Widget _buildLikeButton(Color secondaryTextColor) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: _toggleLike,
      child: Row(
        children: [
          Icon(
            _isLiked ? FluentIcons.heart_24_filled : FluentIcons.heart_24_regular,
            size: 12,
            color: _isLiked ? AppColors.red : secondaryTextColor,
          ),
          const SizedBox(width: 4),
          Text(widget.likeCount.toString(), style: TextStyle(fontSize: 11, color: secondaryTextColor)),
        ],
      ),
    );
  }

  Widget _buildReplyButton(Color secondaryTextColor) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => widget.onReply(widget.userId, widget.username),
      child: Text('Reply', style: TextStyle(fontSize: 11, color: secondaryTextColor)),
    );
  }
}
