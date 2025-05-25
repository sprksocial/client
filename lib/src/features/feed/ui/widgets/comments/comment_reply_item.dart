import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/utils/comment_utils.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/widgets/user_avatar.dart';
import 'package:sparksocial/src/features/feed/data/models/comment_state.dart';
import 'package:sparksocial/src/features/feed/providers/comment_provider.dart';
import 'package:sparksocial/src/features/feed/providers/comments_tray_provider.dart';

class CommentReplyItem extends ConsumerStatefulWidget {
  final Comment reply;
  final String parentUri;
  final String parentCid;

  const CommentReplyItem({super.key, required this.reply, required this.parentUri, required this.parentCid});

  @override
  ConsumerState<CommentReplyItem> createState() => _CommentReplyItemState();
}

class _CommentReplyItemState extends ConsumerState<CommentReplyItem> {
  late CommentState state;

  @override
  void initState() {
    state = CommentState(comment: widget.reply);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _Avatar(comment: state.comment),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(state.comment.username, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13)),
                    const SizedBox(width: 6),
                    Text(
                      CommentUtils.formatTimeAgo(state.comment.createdAt),
                      style: TextStyle(fontSize: 11, color: secondaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                Text(state.comment.text, style: TextStyle(color: textColor, fontSize: 13)),

                const SizedBox(height: 4),
                _ActionButtons(state: state, parentUri: widget.parentUri, parentCid: widget.parentCid),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.state,
    required this.parentUri,
    required this.parentCid,
  });

  final CommentState state;
  final String parentUri;
  final String parentCid;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _LikeButton(state: state),
        const SizedBox(width: 16),
        _ReplyButton(comment: state.comment, parentUri: parentUri, parentCid: parentCid),
      ],
    );
  }
}

class _ReplyButton extends ConsumerWidget {
  const _ReplyButton({required this.comment, required this.parentUri, required this.parentCid});

  final Comment comment;
  final String parentUri;
  final String parentCid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trayNotifier = ref.read(CommentsTrayProvider(postUri: parentUri, postCid: parentCid, isSprk: false).notifier);
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => trayNotifier.replyToComment(comment.authorDid, comment.username),
      child: Text('Reply', style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white)),
    );
  }
}

class _LikeButton extends ConsumerWidget {
  const _LikeButton({required this.state});

  final CommentState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(CommentNotifierProvider(state.comment).notifier);
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: notifier.toggleLike,
      child: Row(
        children: [
          Icon(
            state.isLiked ? FluentIcons.heart_24_filled : FluentIcons.heart_24_regular,
            size: 12,
            color: state.isLiked ? AppColors.red : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white,
          ),
          const SizedBox(width: 4),
          Text(state.comment.likeCount.toString(), style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white)),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.comment});

  final Comment comment;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: UserAvatar(
        imageUrl: comment.profileImageUrl,
        username: comment.username,
        size: 28,
        borderWidth: 0,
        backgroundColor: AppColors.accent.withAlpha(204),
      ),
    );
  }
}
