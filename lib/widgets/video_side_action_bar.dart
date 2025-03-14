import 'package:flutter/cupertino.dart';
import 'action_buttons/profile_action_button.dart';
import 'action_buttons/like_action_button.dart';
import 'action_buttons/comment_action_button.dart';
import 'action_buttons/bookmark_action_button.dart';
import 'action_buttons/share_action_button.dart';

class VideoSideActionBar extends StatelessWidget {
  // Callback functions for each action
  final VoidCallback? onProfilePressed;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onSharePressed;
  
  // Counts and states
  final String likeCount;
  final String commentCount;
  final String bookmarkCount;
  final String shareCount;
  final bool isLiked;
  final bool isBookmarked;
  
  const VideoSideActionBar({
    super.key,
    // Callbacks
    this.onProfilePressed,
    this.onLikePressed,
    this.onCommentPressed,
    this.onBookmarkPressed,
    this.onSharePressed,
    
    // Counts with defaults
    this.likeCount = '0',
    this.commentCount = '0',
    this.bookmarkCount = '0',
    this.shareCount = '0',
    
    // States
    this.isLiked = false,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile with plus button
        ProfileActionButton(onPressed: onProfilePressed),
        const SizedBox(height: 20),
        
        // Like button
        LikeActionButton(
          count: likeCount,
          isLiked: isLiked,
          onPressed: onLikePressed,
        ),
        const SizedBox(height: 20),
        
        // Comment button
        CommentActionButton(
          count: commentCount,
          onPressed: onCommentPressed,
        ),
        const SizedBox(height: 20),
        
        // Bookmark button
        BookmarkActionButton(
          count: bookmarkCount,
          isBookmarked: isBookmarked,
          onPressed: onBookmarkPressed,
        ),
        const SizedBox(height: 20),
        
        // Share button
        ShareActionButton(
          count: shareCount,
          onPressed: onSharePressed,
        ),
      ],
    );
  }
} 