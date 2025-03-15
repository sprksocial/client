import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';
import 'comment_item.dart';
import 'comment_input.dart';

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

class _CommentsTrayState extends State<CommentsTray> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final _scrollController = ScrollController();
  String? _replyingToUsername;
  String? _replyingToId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _closeComments() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

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
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.75;
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
        'text': 'I think those are your future sales! Natasha Pang, the top Robotics Industry Sales Director for the India market and global influencer.',
        'timeAgo': '1d',
        'likeCount': 232,
        'hasMedia': false,
        'replyCount': 2,
      },
    ];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, height * (1 - _animation.value)),
          child: child,
        );
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            // Header with handle and title
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 0.5),
                ),
              ),
              child: Column(
                children: [
                  // Handle for dragging
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title and close button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.commentCount} comments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _closeComments,
                          child: Icon(
                            FluentIcons.dismiss_24_regular,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Comments list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 16),
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
      ),
    );
  }
} 