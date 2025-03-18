import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';

class ProfileTabs extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final bool isAuthenticated;

  const ProfileTabs({super.key, required this.selectedIndex, required this.onTabSelected, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem(context, 0, FluentIcons.video_24_regular),
          _buildTabItem(context, 1, FluentIcons.image_24_regular),
          _buildTabItem(context, 2, FluentIcons.heart_24_regular),
          _buildTabItem(context, 3, FluentIcons.arrow_repeat_all_24_regular),
          if (isAuthenticated) _buildTabItem(context, 4, FluentIcons.bookmark_24_regular),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index, IconData icon) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final isSelected = selectedIndex == index;

    IconData getFilledIcon(IconData outlineIcon) {
      if (outlineIcon == FluentIcons.video_24_regular) {
        return FluentIcons.video_24_filled;
      } else if (outlineIcon == FluentIcons.image_24_regular) {
        return FluentIcons.image_24_filled;
      } else if (outlineIcon == FluentIcons.heart_24_regular) {
        return FluentIcons.heart_24_filled;
      } else if (outlineIcon == FluentIcons.arrow_repeat_all_24_regular) {
        return FluentIcons.arrow_repeat_all_24_filled;
      } else if (outlineIcon == FluentIcons.bookmark_24_regular) {
        return FluentIcons.bookmark_24_filled;
      } else {
        return outlineIcon;
      }
    }

    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : const Color(0x00000000), // Transparent color
              width: 2,
            ),
          ),
        ),
        child: Icon(
          isSelected ? getFilledIcon(icon) : icon,
          color: isSelected ? AppColors.primary : (isDarkMode ? AppColors.textLight : AppColors.textSecondary),
          size: 26,
        ),
      ),
    );
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  StickyTabBarDelegate({required this.child, this.height = 50.0});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
