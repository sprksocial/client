import 'package:flutter/cupertino.dart';
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
    final secondaryTextColor = widget.isDarkMode 
        ? AppColors.textLight.withOpacity(0.7) 
        : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // User avatar (smaller for replies)
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isDarkMode ? AppColors.deepPurple : AppColors.lightLavender,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                widget.username.isNotEmpty ? widget.username[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Reply content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username and time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                
                // Reply text
                Text(
                  widget.text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                  ),
                ),
                
                // Action buttons
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Like button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            _isLiked 
                                ? CupertinoIcons.heart_fill 
                                : CupertinoIcons.heart,
                            size: 14,
                            color: _isLiked ? AppColors.red : secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.likeCount.toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Reply button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () => widget.onReply(widget.userId, widget.username),
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 11,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 