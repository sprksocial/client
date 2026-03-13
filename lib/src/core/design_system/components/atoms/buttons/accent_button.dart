import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/gradients.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

class AccentButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const AccentButton({required this.label, super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InteractivePressable(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(500),
      child: Container(
        constraints: BoxConstraints.tightFor(
          height: 30,
          width: label.length * 10 + 20,
        ),
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: AppGradients.accent,
          borderRadius: BorderRadius.circular(500), // pill shape
          border: const GradientBoxBorder(
            gradient: AppGradients.glassStroke,
            width: 2,
          ),
        ),
        child: Align(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.textSmallBold.copyWith(
              color: AppColors.greyWhite,
            ),
          ),
        ),
      ),
    );
  }
}
