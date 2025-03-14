import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import 'action_button.dart';

class LikeActionButton extends StatelessWidget {
  final String count;
  final bool isLiked;
  final VoidCallback? onPressed;

  const LikeActionButton({
    super.key,
    required this.count,
    this.isLiked = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: isLiked ? Ionicons.heart : Ionicons.heart_outline,
      label: count,
      onPressed: onPressed,
    );
  }
} 