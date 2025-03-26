import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import 'comment_item.dart';
import 'comment_input.dart';
import '../../services/comments_service.dart';
import '../../models/comment.dart';

/// Shows the comments tray as a modal bottom sheet.
/// This utility function can be used from any screen that needs to display comments.
void showCommentsTray({
  required BuildContext context,
  required String postUri,
  required int commentCount,
  required VoidCallback onClose,
  required bool isDarkMode,
  required bool isSprk,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CommentsTray(
      postUri: postUri,
      commentCount: commentCount,
      onClose: () {
        Navigator.pop(context);
        onClose();
      },
      isDarkMode: isDarkMode,
      isSprk: isSprk,
    ),
  ).whenComplete(onClose);
}

class CommentsTray extends StatefulWidget {
  final String postUri;
  final int commentCount;
  final VoidCallback onClose;
  final bool isDarkMode;
  final bool isSprk;

  const CommentsTray({
    super.key,
    required this.postUri,
    required this.commentCount,
    required this.onClose,
    this.isDarkMode = true,
    required this.isSprk,
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

  List<Comment>? _comments;
  bool _isLoading = false;
  String? _error;
  bool _hasMoreComments = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _animationController.forward();

    // Add scroll listener for lazy loading
    _scrollController.addListener(_scrollListener);

    // Load comments
    _loadComments();
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

  Future<void> _loadComments() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get the service but don't listen to it here
      final commentsService = Provider.of<CommentsService>(context, listen: false);

      final List<Comment> comments;
      if (widget.isSprk) {
        comments = await commentsService.getSparkComments(widget.postUri);
      } else {
        comments = await commentsService.getBlueskyComments(widget.postUri);
      }

      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
          _hasMoreComments = false; // Currently we load all comments at once
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreComments() async {
    // In the current implementation, we load all comments at once
    // This is a placeholder for future pagination implementation
    setState(() {
      _hasMoreComments = false;
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
              videoId: widget.postUri,
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
    if (_isLoading && _comments == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Error loading comments',
                style: TextStyle(
                  color: widget.isDarkMode ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  color: widget.isDarkMode ? AppColors.textLight : AppColors.textPrimary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadComments,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_comments == null || _comments!.isEmpty) {
      return Center(
        child: Text(
          'No comments yet',
          style: TextStyle(
            color: widget.isDarkMode ? AppColors.textLight : AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _comments!.length + 1, // +1 for loading indicator or end message
      itemBuilder: (context, index) {
        if (index == _comments!.length) {
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

        final comment = _comments![index];
        return CommentItem(
          key: ValueKey('comment-${comment.id}'),
          id: comment.id,
          userId: comment.authorDid,
          username: comment.username,
          text: comment.text,
          timeAgo: comment.createdAt,
          likeCount: comment.likeCount,
          hasMedia: comment.hasMedia,
          mediaType: comment.mediaType,
          mediaUrl: comment.mediaUrl,
          replyCount: comment.replyCount,
          isDarkMode: widget.isDarkMode,
          onReply: _replyToComment,
        );
      },
    );
  }
}
