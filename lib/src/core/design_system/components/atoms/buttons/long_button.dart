import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/gradients.dart';
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

  const LongButton({
    required this.label,
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InteractivePressable(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        // height: 40,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 11),
        decoration: BoxDecoration(
          gradient: AppGradients.accent,
          borderRadius: BorderRadius.circular(8),
          border: const GradientBoxBorder(
            gradient: AppGradients.glassStroke,
            width: 3,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.textMediumBold.copyWith(
              color: AppColors.greyWhite,
            ),
          ),
        ),
      ),
    );
  }
}
