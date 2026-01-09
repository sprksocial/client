import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

class Tag extends StatelessWidget {
  final String mainText;
  final String secondaryText;
  final VoidCallback? onTap;

  const Tag({
    required this.mainText,
    required this.secondaryText,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InteractivePressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        // width: 107,
        // height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGreyButton : AppColors.lightGreyButton,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: AppColors.greyBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mainText, style: AppTypography.textMediumMedium),
            const SizedBox(width: 5),
            Text(
              secondaryText,
              style: AppTypography.textExtraSmallMedium.copyWith(
                color: AppColors.grey300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
