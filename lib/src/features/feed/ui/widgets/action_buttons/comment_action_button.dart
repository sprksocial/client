import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/widgets/action_button.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/providers/video_state_provider.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/comments/comments_tray.dart';

class CommentActionButton extends ConsumerWidget {
  final String count;
  final VoidCallback? onPressed;
  final String postUri;
  final String postCid;
  final int commentCount;
  final bool isSprk;
  final int videoIndex;

  const CommentActionButton({
    super.key,
    required this.count,
    this.onPressed,
    required this.postUri,
    required this.postCid,
    required this.commentCount,
    required this.isSprk,
    required this.videoIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ActionButton(
      key: ValueKey('comment_button_$count'),
      icon: FluentIcons.chat_24_regular,
      label: count,
      color: AppColors.white,
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        }
        ref.read(videoStateProvider(videoIndex).notifier).toggleComments();
        showCommentsTray(
          context: context,
          postUri: postUri,
          postCid: postCid,
          commentCount: commentCount,
          isSprk: isSprk,
        );
      },
    );
  }
}
