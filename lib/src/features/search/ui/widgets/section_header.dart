import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAllTap;
  final IconData? icon;

  const SectionHeader({super.key, required this.title, this.onViewAllTap, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, color: textColor, size: 22), const SizedBox(width: 8)],
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: textColor),
              ),
            ],
          ),

          if (onViewAllTap != null)
            GestureDetector(
              onTap: onViewAllTap,
              child: Text(
                'view all',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}
