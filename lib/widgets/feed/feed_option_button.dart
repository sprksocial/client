import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';

class FeedOptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double? width;
  final double height;
  final EdgeInsets? padding;

  const FeedOptionButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.width,
    this.height = 38,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.black : AppTheme.getTextColor(context),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
