import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/design_system/tokens/gradients.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';
class GlassTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const GlassTextButton({
    required this.label, super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InteractivePressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 11),
        decoration: BoxDecoration(
          gradient: AppGradients.glassStroke,
          borderRadius: BorderRadius.circular(8),
          border: const GradientBoxBorder(
            gradient: AppGradients.glassStroke,
            width: 1.25,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.textSmallMedium.copyWith(
            fontSize: 14,
            color: AppColors.greyWhite,
          ),
        ),
      ),
    );
  }
}
