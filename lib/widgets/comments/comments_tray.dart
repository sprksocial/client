import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../utils/app_colors.dart';
import 'comment_item.dart';
import 'comment_input.dart';

/// Shows the comments tray as a modal bottom sheet.
/// This utility function can be used from any screen that needs to display comments.
void showCommentsTray({
  required BuildContext context,
  required String videoId,
  required int commentCount,
  required VoidCallback onClose,
  required bool isDarkMode,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CommentsTray(
      videoId: videoId,
      commentCount: commentCount,
      onClose: () {
        Navigator.pop(context);
        onClose();
      },
      isDarkMode: isDarkMode,
    ),
  ).whenComplete(onClose);
}

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

  // Sample data - in a real app this would come from a data source
  final List<Map<String, dynamic>> _sampleComments = const [
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
    {
      'id': '4',
      'userId': 'user4',
      'username': 'VideoCreator',
      'text': 'Made a quick tutorial on how to use this app:',
      'timeAgo': '3h',
      'likeCount': 432,
      'hasMedia': false,
      //'mediaType': 'video',
      //'mediaUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'replyCount': 12,
    },
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

  bool _isLoading = false;
  bool _hasMoreComments = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _animationController.forward();

    // Add scroll listener for lazy loading
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Only load more if we're near the end, not loading, and have more comments to load
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMoreComments) {
      _loadMoreComments();
    }
  }

  Future<void> _loadMoreComments() async {
    // This would be an API call in a real app
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // In a real app, you would add new comments to your list
    // For this simulation, we'll set _hasMoreComments to false after first load
    setState(() {
      _isLoading = false;
      _hasMoreComments = false; // Indicate we've loaded all available comments
    });
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

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(offset: Offset(0, height * (1 - _animation.value)), child: child);
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            _buildHeader(borderColor, textColor),
            Expanded(child: _buildCommentsList()),
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

  Widget _buildHeader(Color borderColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor, width: 0.5))),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.commentCount} comments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _closeComments,
                  icon: Icon(FluentIcons.dismiss_24_regular, color: textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _sampleComments.length + 1, // +1 for loading indicator or end message
      itemBuilder: (context, index) {
        if (index == _sampleComments.length) {
          // Show loading indicator or end of list message
          if (_isLoading) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ));
          } else if (!_hasMoreComments) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No more comments',
                style: TextStyle(
                  color: widget.isDarkMode ? AppColors.textLight : AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ));
          }
          return const SizedBox.shrink();
        }

        final comment = _sampleComments[index];
        return CommentItem(
          key: ValueKey('comment-${comment['id']}'),
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
    );
  }
}
