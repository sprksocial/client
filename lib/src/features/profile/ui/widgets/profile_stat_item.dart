import 'package:flutter/material.dart';

// Placeholder for ProfileStatItem widget
class ProfileStatItem extends StatelessWidget {
  const ProfileStatItem({required this.count, required this.label, super.key});
  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurfaceVariant, fontSize: 14),
        ),
      ],
    );
  }
}
