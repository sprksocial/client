import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

class TabItem extends StatelessWidget {
  const TabItem({
    super.key,
    required this.isSelected,
    required this.label,
    required this.onTap,
    required this.isDarkMode,
  });

  final bool isSelected;
  final String label;
  final VoidCallback onTap;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? label == 'Messages'
                      ? AppColors.pink
                      : AppColors.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? label == 'Messages'
                      ? AppColors.pink
                      : AppColors.primary
                  : isDarkMode
                      ? AppColors.textLight.withAlpha(179)
                      : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
} 