import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class ProfileTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const ProfileTabBar({super.key, required this.selectedIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem(context, 0, FluentIcons.heart_24_regular),
          _buildTabItem(context, 1, FluentIcons.bookmark_24_regular),
          _buildTabItem(context, 2, FluentIcons.arrow_repeat_all_24_regular),
          _buildTabItem(context, 3, FluentIcons.image_24_regular),
          _buildTabItem(context, 4, FluentIcons.people_24_regular),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index, IconData icon) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final isSelected = selectedIndex == index;

    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40),
      onPressed: () => onTabSelected(index),
      icon: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : (isDarkMode ? AppColors.textLight : AppColors.textSecondary),
          size: 26,
        ),
      ),
    );
  }
}
