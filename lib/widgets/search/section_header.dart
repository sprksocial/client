import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAllTap;
  final IconData? icon;

  const SectionHeader({super.key, required this.title, this.onViewAllTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title with optional icon
          Row(
            children: [
              if (icon != null) ...[Icon(icon, color: AppTheme.getTextColor(context), size: 22), const SizedBox(width: 8)],
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.getTextColor(context))),
            ],
          ),

          // View all button
          if (onViewAllTap != null)
            GestureDetector(
              onTap: onViewAllTap,
              child: Text('view all', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500, fontSize: 14)),
            ),
        ],
      ),
    );
  }
}
