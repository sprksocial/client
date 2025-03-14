import 'package:flutter/cupertino.dart';
import '../../utils/app_colors.dart';

class ProfileTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const ProfileTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem(context, 0, CupertinoIcons.heart),
          _buildTabItem(context, 1, CupertinoIcons.bookmark),
          _buildTabItem(context, 2, CupertinoIcons.refresh),
          _buildTabItem(context, 3, CupertinoIcons.photo),
          _buildTabItem(context, 4, CupertinoIcons.person_2),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index, IconData icon) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final isSelected = selectedIndex == index;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Icon(
          icon,
          color: isSelected
              ? AppColors.primary
              : (isDarkMode ? AppColors.textLight : AppColors.textSecondary),
          size: 26,
        ),
      ),
    );
  }
}