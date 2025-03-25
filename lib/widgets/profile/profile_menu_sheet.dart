import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../utils/app_colors.dart';

class ProfileMenuSheet extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileMenuSheet({required this.onLogout, super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.deepPurple : Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
          ),

          // Title
          Text(
            'Profile Options',
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: AppColors.darkPurple
            ),
          ),

          const SizedBox(height: 32),

          // Logout Button
          _buildMenuButton(
            context,
            icon: FluentIcons.sign_out_24_filled,
            label: 'Logout',
            textColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              onLogout();
            },
          ),
          
          const SizedBox(height: 16),
          
          // Cancel Button
          _buildMenuButton(
            context,
            icon: FluentIcons.dismiss_20_filled,
            label: 'Cancel',
            onTap: () => Navigator.pop(context),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor ?? (isDarkMode ? Colors.white : Colors.black87),
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor ?? (isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 