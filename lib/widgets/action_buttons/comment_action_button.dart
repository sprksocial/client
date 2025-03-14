import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import 'action_button.dart';

class CommentActionButton extends StatelessWidget {
  final String count;
  final VoidCallback? onPressed;

  const CommentActionButton({
    super.key,
    required this.count,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: Ionicons.chatbubble_outline,
      label: count,
      onPressed: onPressed,
    );
  }
} 