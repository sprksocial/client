import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

/// A general-purpose primary button that can display any text.
///
/// This button uses the primary brand color and is commonly used in
/// authentication screens, but can be used anywhere a prominent primary action is needed.
/// It supports an optional trailing widget (e.g., SVG icon) and customizable minimum size.
class PrimaryButton extends StatelessWidget {
  /// The text to display on the button
  final String text;

  /// Optional widget to display after the text (e.g., SVG logo)
  final Widget? trailing;

  /// Callback when the button is pressed
  final VoidCallback? onPressed;

  /// Minimum width of the button (default: 320)
  final double? minWidth;

  /// Minimum height of the button (default: 60)
  final double? minHeight;

  const PrimaryButton({
    required this.text,
    this.trailing,
    this.onPressed,
    this.minWidth,
    this.minHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InteractivePressable(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        constraints: BoxConstraints(
          minWidth: minWidth ?? 320,
          minHeight: minHeight ?? 60,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary500,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: AppTypography.textLargeMedium.copyWith(
                color: AppColors.greyWhite,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
