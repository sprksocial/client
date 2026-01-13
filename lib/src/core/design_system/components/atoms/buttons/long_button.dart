import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

/// A general-purpose button with gradient background that can display any text.
///
/// It has an accent gradient background with a glass stroke border.
/// It's commonly used in authentication screens and forms, but can be used
/// anywhere a prominent action button is needed.
class LongButton extends StatelessWidget {
  /// The text to display on the button
  final String label;

  /// Callback when the button is pressed
  final VoidCallback? onPressed;

  /// Button variant style
  /// - [primary]: Pink/primary gradient (default)
  /// - [regular]: Grey solid color
  final LongButtonVariant variant;

  const LongButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = LongButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == LongButtonVariant.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InteractivePressable(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        // height: 40,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 11),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary600
              : (isDark ? AppColors.darkGreyButton : AppColors.lightGreyButton),
          borderRadius: BorderRadius.circular(8),
          border: isPrimary
              ? null
              : Border.all(
                  color: isDark ? AppColors.greyBorder : AppColors.grey200,
                  width: 1.14667,
                ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.textMediumBold.copyWith(
              color: isPrimary
                  ? AppColors.greyWhite
                  : (isDark ? AppColors.greyWhite : AppColors.grey900),
            ),
          ),
        ),
      ),
    );
  }
}

/// Button variant styles for LongButton
enum LongButtonVariant {
  /// Primary variant with pink/primary gradient
  primary,

  /// Regular variant with grey solid color
  regular,
}
