import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/comments/comment_item.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/comments/comment_input.dart';

class CommentsTray extends StatefulWidget {
  final String postUri;
  final String postCid;
  final List<Comment> comments;
  final Future<void> Function({
    required String text,
    required String targetCid,
    required String targetUri,
    String? rootCid,
    String? rootUri,
    List<XFile>? imageFiles,
    Map<String, String>? altTexts,
  })
  postComment;
  final Future<void> Function(String uri) likeComment;
  final Future<void> Function(String uri) unlikeComment;
  final Future<void> Function(String uri) deleteComment;
  final Function(Comment) reportComment;
  final ScrollController? scrollController;
  final VoidCallback? onLoadMore;
  final bool isLoading;

  const CommentsTray({
    super.key,
    required this.postUri,
    required this.postCid,
    required this.comments,
    required this.postComment,
    required this.likeComment,
    required this.unlikeComment,
    required this.deleteComment,
    required this.reportComment,
    this.scrollController,
    this.onLoadMore,
    this.isLoading = false,
  });

  @override
  State<CommentsTray> createState() => _CommentsTrayState();
}

class _CommentsTrayState extends State<CommentsTray> {
  String? _replyingToUsername;
  String? _replyingToId;
  final FocusNode _focusNode = FocusNode();
  final _logger = GetIt.instance<LogService>().getLogger('CommentsTray');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _setReplyingTo(String userId, String username) {
    _logger.d('Setting reply to user: $username ($userId)');
    setState(() {
      _replyingToId = userId;
      _replyingToUsername = username;
    });

    // Give focus to the text field
    _focusNode.requestFocus();
  }

  void _clearReplyingTo() {
    _logger.d('Clearing replying to user');
    setState(() {
      _replyingToId = null;
      _replyingToUsername = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.surface;

    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _CommentsHeader(),

          Expanded(
            child: _CommentsListView(
              comments: widget.comments,
              isLoading: widget.isLoading,
              scrollController: widget.scrollController,
              onReply: _setReplyingTo,
              likeComment: widget.likeComment,
              unlikeComment: widget.unlikeComment,
              deleteComment: widget.deleteComment,
              reportComment: widget.reportComment,
            ),
          ),

          // Comments input
          CommentInput(
            postUri: widget.postUri,
            postCid: widget.postCid,
            replyingToUsername: _replyingToUsername,
            replyingToId: _replyingToId,
            onCancelReply: _clearReplyingTo,
            focusNode: _focusNode,
            postComment: widget.postComment,
          ),
        ],
      ),
    );
  }
}

class _CommentsHeader extends StatelessWidget {
  const _CommentsHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final dividerColor = colorScheme.onSurfaceVariant.withAlpha(26);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Comments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
              IconButton(icon: Icon(Icons.close, color: textColor), onPressed: () => context.router.maybePop()),
            ],
          ),
        ),
        Divider(color: dividerColor, height: 1),
      ],
    );
  }
}

class _CommentsListView extends StatelessWidget {
  final List<Comment> comments;
  final bool isLoading;
  final ScrollController? scrollController;
  final Function(String, String) onReply;
  final Future<void> Function(String) likeComment;
  final Future<void> Function(String) unlikeComment;
  final Future<void> Function(String) deleteComment;
  final Function(Comment) reportComment;

  const _CommentsListView({
    required this.comments,
    required this.isLoading,
    required this.onReply,
    required this.likeComment,
    required this.unlikeComment,
    required this.deleteComment,
    required this.reportComment,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty && !isLoading) {
      return const _EmptyCommentsState();
    }

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: comments.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == comments.length) {
          return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
        }

        final comment = comments[index];

        return CommentItem(
          id: comment.id,
          userId: comment.authorDid,
          username: comment.username,
          text: comment.text,
          timeAgo: comment.createdAt,
          likeCount: comment.likeCount,
          hasMedia: comment.hasMedia,
          mediaType: comment.mediaType,
          mediaUrl: comment.mediaUrl,
          imageUrls: comment.imageUrls,
          replyCount: comment.replyCount,
          onReply: onReply,
          replies: comment.replies,
          uri: comment.uri,
          cid: comment.cid,
          profileImageUrl: comment.profileImageUrl,
          authorDid: comment.authorDid,
          isLiked: Comment.isLiked(comment),
          onLikePressed: () => _handleCommentLike(comment),
          onDeletePressed: () => _handleDeleteComment(comment),
          onReportPressed: () => reportComment(comment),
        );
      },
    );
  }

  Future<void> _handleCommentLike(Comment comment) async {
    if (Comment.isLiked(comment)) {
      await unlikeComment(comment.uri);
    } else {
      await likeComment(comment.uri);
    }
  }

  Future<void> _handleDeleteComment(Comment comment) async {
    await deleteComment(comment.uri);
  }
}

class _EmptyCommentsState extends StatelessWidget {
  const _EmptyCommentsState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface.withAlpha(179);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'No comments yet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to comment on this post!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
