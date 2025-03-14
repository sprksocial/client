import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import 'action_button.dart';

class ShareActionButton extends StatelessWidget {
  final String count;
  final VoidCallback? onPressed;

  const ShareActionButton({
    super.key,
    required this.count,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: Ionicons.arrow_redo_outline,
      label: count,
      onPressed: onPressed,
    );
  }
} 