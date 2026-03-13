import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

class TextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const TextButton({required this.label, super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InteractivePressable(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 36),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 11),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGreyButton : AppColors.lightGreyButton,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: const Border.fromBorderSide(
            BorderSide(color: AppColors.greyBorder, width: 1.14667),
          ),
        ),
        child: Align(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.textSmallMedium,
          ),
        ),
      ),
    );
  }
}
