import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'action_button.dart';

class CommentActionButton extends StatelessWidget {
  final String count;
  final VoidCallback? onPressed;

  const CommentActionButton({super.key, required this.count, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      key: ValueKey('comment_button_$count'),
      icon: FluentIcons.chat_24_regular,
      label: count,
      onPressed: onPressed,
    );
  }
}
