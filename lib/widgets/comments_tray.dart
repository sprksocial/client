import 'package:flutter/material.dart';
import 'dart:ui'; // Import for ImageFilter
import '../utils/app_colors.dart';
import 'comments/comment_item.dart';
import 'comments/comment_input.dart';

class CommentsTray extends StatefulWidget {
  final String videoId;
  final int commentCount;
  final VoidCallback onClose;
  final bool isDarkMode;

  const CommentsTray({
    super.key,
    required this.videoId,
    required this.commentCount,
    required this.onClose,
    this.isDarkMode = true,
  });

  @override
  State<CommentsTray> createState() => _CommentsTrayState();
}

class _CommentsTrayState extends State<CommentsTray> {
  final _scrollController = ScrollController();
  String? _replyingToUsername;
  String? _replyingToId;

  void _replyToComment(String userId, String username) {
    setState(() {
      _replyingToUsername = username;
      _replyingToId = userId;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToUsername = null;
      _replyingToId = null;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isDarkMode ? AppColors.nearBlack : Colors.white;
    final borderColor = widget.isDarkMode ? AppColors.darkPurple : AppColors.lightLavender;
    final textColor = widget.isDarkMode ? AppColors.textLight : AppColors.textPrimary;

    // Sample data for demonstration
    final sampleComments = [
      // Text only comment
      {
        'id': '1',
        'userId': 'user1',
        'username': 'Emma',
        'text': 'Protect Natasha Pang from Hackers all cost!!!!',
        'timeAgo': '5h',
        'likeCount': 7,
        'hasMedia': false,
        'replyCount': 0,
      },
      // Text only comment with replies
      {
        'id': '2',
        'userId': 'user2',
        'username': 'Nic',
        'text': 'Natasha what did you download',
        'timeAgo': '1d',
        'likeCount': 2124,
        'hasMedia': false,
        'replyCount': 2,
      },
      // Comment with image
      {
        'id': '3',
        'userId': 'user3',
        'username': 'PhotoEnthusiast',
        'text': 'Check out this incredible sunset I captured yesterday!',
        'timeAgo': '2h',
        'likeCount': 189,
        'hasMedia': true,
        'mediaType': 'image',
        'mediaUrl': 'https://placekitten.com/500/300',
        'replyCount': 5,
      },
      // Comment with video
      {
        'id': '4',
        'userId': 'user4',
        'username': 'VideoCreator',
        'text': 'Made a quick tutorial on how to use this app:',
        'timeAgo': '3h',
        'likeCount': 432,
        'hasMedia': true,
        'mediaType': 'video',
        'mediaUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        'replyCount': 12,
      },
      // More text comments
      {
        'id': '5',
        'userId': 'user5',
        'username': 'Hen Ry',
        'text': 'Natasha pang baddie pics?',
        'timeAgo': '14h',
        'likeCount': 1,
        'hasMedia': false,
        'replyCount': 0,
      },
      {
        'id': '6',
        'userId': 'user6',
        'username': 'WowCrazy',
        'text':
            'I think those are your future sales! Natasha Pang, the top Robotics Industry Sales Director for the India market and global influencer.',
        'timeAgo': '1d',
        'likeCount': 232,
        'hasMedia': false,
        'replyCount': 2,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with handle
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor, width: 0.5))),
            child: Column(
              children: [
                // Handle for dragging
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2.5)),
                ),
                // Title
                Center(
                  child: Text(
                    '${widget.commentCount} comments',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ),
              ],
            ),
          ),

          // Comments list - use Flexible with a limited height
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 8),
                shrinkWrap: true,
                itemCount: sampleComments.length,
                itemBuilder: (context, index) {
                  final comment = sampleComments[index];
                  return CommentItem(
                    id: comment['id'] as String,
                    userId: comment['userId'] as String,
                    username: comment['username'] as String,
                    text: comment['text'] as String,
                    timeAgo: comment['timeAgo'] as String,
                    likeCount: comment['likeCount'] as int,
                    hasMedia: comment['hasMedia'] as bool,
                    mediaType: comment['mediaType'] as String?,
                    mediaUrl: comment['mediaUrl'] as String?,
                    replyCount: comment['replyCount'] as int,
                    isDarkMode: widget.isDarkMode,
                    onReply: _replyToComment,
                  );
                },
              ),
            ),
          ),

          // Input area
          CommentInput(
            videoId: widget.videoId,
            replyingToUsername: _replyingToUsername,
            replyingToId: _replyingToId,
            onCancelReply: _cancelReply,
            isDarkMode: widget.isDarkMode,
          ),
        ],
      ),
    );
  }
}

/// Static method to show the comments tray as a proper Material bottom sheet
void showCommentsTray({
  required BuildContext context,
  required String videoId,
  required int commentCount,
  required VoidCallback onClose,
  bool isDarkMode = true,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    enableDrag: true,
    builder:
        (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: CommentsTray(videoId: videoId, commentCount: commentCount, onClose: onClose, isDarkMode: isDarkMode),
        ),
  );
}
