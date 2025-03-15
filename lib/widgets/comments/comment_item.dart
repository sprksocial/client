import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:video_player/video_player.dart';
import '../../utils/app_colors.dart';
import 'comment_reply_item.dart';

class CommentItem extends StatefulWidget {
  final String id;
  final String userId;
  final String username;
  final String text;
  final String timeAgo;
  final int likeCount;
  final bool hasMedia;
  final String? mediaType;
  final String? mediaUrl;
  final int replyCount;
  final bool isDarkMode;
  final Function(String, String) onReply;

  const CommentItem({
    super.key,
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
    required this.timeAgo,
    required this.likeCount,
    required this.hasMedia,
    this.mediaType,
    this.mediaUrl,
    required this.replyCount,
    required this.isDarkMode,
    required this.onReply,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _isLiked = false;
  bool _showReplies = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.hasMedia && widget.mediaType == 'video' && widget.mediaUrl != null) {
      _initializeVideoPlayer();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer() {
    _videoController = VideoPlayerController.network(widget.mediaUrl!)
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
      });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  void _toggleReplies() {
    setState(() {
      _showReplies = !_showReplies;
    });
  }

  void _toggleVideoPlayback() {
    if (_videoController != null && _isVideoInitialized) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? AppColors.textLight : AppColors.textPrimary;
    final secondaryTextColor = widget.isDarkMode 
        ? AppColors.textLight.withAlpha(179) 
        : AppColors.textSecondary;
    final dividerColor = widget.isDarkMode 
        ? AppColors.deepPurple.withAlpha(128) 
        : AppColors.lightLavender;

    // Mock replies data
    final mockReplies = [
      {
        'id': 'reply1',
        'userId': 'replier1',
        'username': 'ReplyUser1',
        'text': 'This is amazing!',
        'timeAgo': '2h',
        'likeCount': 15,
      },
      {
        'id': 'reply2',
        'userId': 'replier2',
        'username': 'ReplyUser2',
        'text': 'I completely agree with this.',
        'timeAgo': '1h',
        'likeCount': 8,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accent,
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
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Comment content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username and time
                    Row(
                      children: [
                        Text(
                          widget.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Comment text
                    Text(
                      widget.text,
                      style: TextStyle(color: textColor),
                    ),
                    
                    // Media content (if any)
                    if (widget.hasMedia) ...[
                      const SizedBox(height: 8),
                      _buildMediaContent(),
                    ],
                    
                    // Action buttons
                    const SizedBox(height: 8),
                    Row(
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
                                size: 16,
                                color: _isLiked ? AppColors.red : secondaryTextColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.likeCount.toString(),
                                style: TextStyle(
                                  fontSize: 12,
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
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                        
                        // View replies button (if any)
                        if (widget.replyCount > 0) ...[
                          const SizedBox(width: 16),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            minSize: 0,
                            onPressed: _toggleReplies,
                            child: Row(
                              children: [
                                Icon(
                                  _showReplies
                                      ? CupertinoIcons.chevron_up
                                      : CupertinoIcons.chevron_down,
                                  size: 16,
                                  color: AppColors.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.replyCount} ${widget.replyCount == 1 ? 'reply' : 'replies'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Replies section
        if (_showReplies && widget.replyCount > 0) ...[
          Container(
            margin: const EdgeInsets.only(left: 64),
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add a slight padding at the top for better visual separation
                const SizedBox(height: 2),
                // Use Column instead of ListView to avoid nested scrolling issues
                ...mockReplies.map((reply) => CommentReplyItem(
                  id: reply['id'] as String,
                  userId: reply['userId'] as String,
                  username: reply['username'] as String,
                  text: reply['text'] as String,
                  timeAgo: reply['timeAgo'] as String,
                  likeCount: reply['likeCount'] as int,
                  isDarkMode: widget.isDarkMode,
                  onReply: widget.onReply,
                )).toList(),
              ],
            ),
          ),
        ],
        
        // Divider
        Container(
          height: 0.5,
          color: dividerColor,
        ),
      ],
    );
  }

  Widget _buildMediaContent() {
    if (!widget.hasMedia || widget.mediaUrl == null) {
      return const SizedBox.shrink();
    }

    final borderRadius = BorderRadius.circular(8);
    
    if (widget.mediaType == 'image') {
      // Image content
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: widget.isDarkMode ? AppColors.deepPurple : AppColors.lightLavender,
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          widget.mediaUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CupertinoActivityIndicator(
                color: widget.isDarkMode ? AppColors.white : AppColors.deepPurple,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.darkPurple.withAlpha(26),
              child: Center(
                child: Icon(
                  CupertinoIcons.photo,
                  color: widget.isDarkMode ? AppColors.white : AppColors.deepPurple,
                ),
              ),
            );
          },
        ),
      );
    } else if (widget.mediaType == 'video') {
      // Video content
      return GestureDetector(
        onTap: _toggleVideoPlayback,
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: widget.isDarkMode ? AppColors.deepPurple : AppColors.lightLavender,
              width: 0.5,
            ),
            color: Colors.black,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_videoController != null && _isVideoInitialized)
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              
              if (!_isVideoInitialized)
                const CupertinoActivityIndicator(
                  color: AppColors.white,
                ),
              
              if (_isVideoInitialized && !_videoController!.value.isPlaying)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(128),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.play_fill,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
            ],
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
} 