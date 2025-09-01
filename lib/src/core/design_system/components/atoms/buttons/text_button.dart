import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

class TextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const TextButton({
    required this.label,
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InteractivePressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 11),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkGreyButton : AppColors.lightGreyButton,
              borderRadius: BorderRadius.circular(8),
              border: BoxBorder.all(
                color: AppColors.greyBorder,
                width: 1.25,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.textSmallMedium
            ),
          ),
        ),
      ),
    );
  }
}
