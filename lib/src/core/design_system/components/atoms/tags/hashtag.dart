import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

class GlassmorphicTag extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;
  final VoidCallback? onTap;

  const GlassmorphicTag({
    required this.label,
    super.key,
    this.onDeleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InteractivePressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 38,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AppIcons.hashtag(size: 14),
                const SizedBox(width: 5),
                Text(label, style: AppTypography.textMediumMedium),
              ],
            ),
            const Spacer(),
            if (onDeleted != null)
              InteractivePressable(
                onTap: onDeleted,
                borderRadius: BorderRadius.circular(22),
                child: AppIcons.cancel(size: 22),
              ),
          ],
        ),
      ),
    );
  }
}
