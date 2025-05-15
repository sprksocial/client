import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart'; // Updated import

class ProfileMenuSheet extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileMenuSheet({required this.onLogout, super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.deepPurple : theme.colorScheme.surface, // Updated color
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)), // Updated color
          ),
          Text(
            'Profile Options',
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: theme.colorScheme.onSurface // Updated color
            ),
          ),
          const SizedBox(height: 32),
          _MenuButton(
            icon: FluentIcons.sign_out_24_filled,
            label: 'Logout',
            textColor: Colors.red, // Specific color, kept as is
            onTap: () {
              context.router.maybePop();
              onLogout();
            },
          ),
          const SizedBox(height: 16),
          _MenuButton(
            icon: FluentIcons.dismiss_20_filled, 
            label: 'Cancel', 
            onTap: () => context.router.maybePop()
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Refactored _buildMenuButton to a StatelessWidget
class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // Default text color from theme, overridden by textColor if provided
    final Color effectiveTextColor = textColor ?? theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), // Consider adding a background if needed
        child: Row(
          children: [
            Icon(icon, color: effectiveTextColor, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: effectiveTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 