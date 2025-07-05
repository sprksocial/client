import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/widgets/action_button.dart';

class CommentActionButton extends StatelessWidget {
  const CommentActionButton({
    required this.count,
    super.key,
    this.onPressed,
  });
  final String count;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      key: ValueKey('comment_button_$count'),
      icon: FluentIcons.chat_24_regular,
      label: count,
      color: AppColors.white,
      onPressed: onPressed,
    );
  }
}
