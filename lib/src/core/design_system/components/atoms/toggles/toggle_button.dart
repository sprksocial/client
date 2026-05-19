import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

enum ToggleButtonTone { primary, neutral, danger }

class ToggleButton extends StatelessWidget {
  const ToggleButton({
    required this.isSelected,
    required this.selectedLabel,
    required this.unselectedLabel,
    required this.onChanged,
    super.key,
    this.selectedTone = ToggleButtonTone.neutral,
    this.unselectedTone = ToggleButtonTone.primary,
    this.width,
    this.height = 36,
  });

  final bool isSelected;
  final String selectedLabel;
  final String unselectedLabel;
  final ValueChanged<bool> onChanged;
  final ToggleButtonTone selectedTone;
  final ToggleButtonTone unselectedTone;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tone = isSelected ? selectedTone : unselectedTone;

    return InteractivePressable(
      onTap: () {
        HapticFeedback.mediumImpact();
        onChanged(!isSelected);
      },
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Container(
        width: width ?? 109.47,
        height: height,
        decoration: _decorationFor(tone, isDark),
        child: Align(
          child: Text(
            isSelected ? selectedLabel : unselectedLabel,
            textAlign: TextAlign.center,
            style: AppTypography.textSmallMedium.copyWith(
              color: _textColorFor(tone, isDark),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _decorationFor(ToggleButtonTone tone, bool isDark) {
    switch (tone) {
      case ToggleButtonTone.primary:
        return const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: AppColors.primary600,
        );
      case ToggleButtonTone.neutral:
        return BoxDecoration(
          color: isDark ? AppColors.darkGreyButton : AppColors.lightGreyButton,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.fromBorderSide(
            BorderSide(
              color: isDark
                  ? AppColors.grey700.withValues(alpha: 0.3)
                  : AppColors.grey100.withValues(alpha: 0.3),
              width: 1.14667,
            ),
          ),
        );
      case ToggleButtonTone.danger:
        return BoxDecoration(
          color: isDark ? AppColors.red900 : AppColors.red50,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.fromBorderSide(
            BorderSide(color: isDark ? AppColors.red800 : AppColors.red200),
          ),
        );
    }
  }

  Color _textColorFor(ToggleButtonTone tone, bool isDark) {
    switch (tone) {
      case ToggleButtonTone.primary:
        return AppColors.greyWhite;
      case ToggleButtonTone.neutral:
        return isDark ? AppColors.greyWhite : AppColors.greyBlack;
      case ToggleButtonTone.danger:
        return isDark ? AppColors.red400 : AppColors.red700;
    }
  }
}
