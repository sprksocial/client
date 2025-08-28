import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/design_system/tokens/gradients.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

class LongButton extends StatelessWidget {
  final String label;
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
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 11),
        decoration: BoxDecoration(
          gradient: AppGradients.accent,
          borderRadius: BorderRadius.circular(8),
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
