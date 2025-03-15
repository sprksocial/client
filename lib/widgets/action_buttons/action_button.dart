import 'package:flutter/cupertino.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoButton(
          padding: const EdgeInsets.all(12),
          minSize: 0,
          borderRadius: BorderRadius.circular(30),
          onPressed: onPressed,
          child: Icon(
            icon,
            color: color ?? CupertinoColors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
} 