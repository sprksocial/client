import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? leading;
  final Widget? trailing;
  final bool fullWidth;
  final double? minWidth;
  final double? minHeight;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;

  const AppButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.leading,
    this.trailing,
    this.fullWidth = false,
    this.minWidth,
    this.minHeight,
    this.padding,
    this.borderRadius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final isEnabled = onPressed != null;
    final resolvedSize = _AppButtonSizeStyle.from(size);
    final resolvedVariant = _AppButtonVariantStyle.resolve(
      variant: variant,
      isDark: isDark,
      colorScheme: colorScheme,
      isEnabled: isEnabled,
    );
    final resolvedBorderRadius = borderRadius ?? resolvedSize.borderRadius;

    final labelText = Text(
      label,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: (textStyle ?? resolvedSize.textStyle).copyWith(
        color: resolvedVariant.foregroundColor,
      ),
    );

    final content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading!, SizedBox(width: resolvedSize.gap)],
        if (fullWidth) Flexible(child: labelText) else labelText,
        if (trailing != null) ...[SizedBox(width: resolvedSize.gap), trailing!],
      ],
    );

    return Semantics(
      button: true,
      enabled: isEnabled,
      child: InteractivePressable(
        onTap: onPressed,
        borderRadius: resolvedBorderRadius,
        child: Container(
          width: fullWidth ? double.infinity : null,
          constraints: BoxConstraints(
            minWidth: minWidth ?? resolvedSize.minWidth,
            minHeight: minHeight ?? resolvedSize.minHeight,
          ),
          padding: padding ?? resolvedSize.padding,
          decoration: BoxDecoration(
            color: resolvedVariant.backgroundColor,
            borderRadius: resolvedBorderRadius,
            border: resolvedVariant.border,
          ),
          child: content,
        ),
      ),
    );
  }
}

enum AppButtonVariant { primary, secondary, neutral, destructive }

enum AppButtonSize { compact, medium, large }

class _AppButtonSizeStyle {
  final double minWidth;
  final double minHeight;
  final double gap;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final TextStyle textStyle;

  const _AppButtonSizeStyle({
    required this.minWidth,
    required this.minHeight,
    required this.gap,
    required this.padding,
    required this.borderRadius,
    required this.textStyle,
  });

  factory _AppButtonSizeStyle.from(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.compact:
        return _AppButtonSizeStyle(
          minWidth: 0,
          minHeight: 40,
          gap: 8,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 11),
          borderRadius: BorderRadius.circular(8),
          textStyle: AppTypography.textMediumBold,
        );
      case AppButtonSize.medium:
        return _AppButtonSizeStyle(
          minWidth: 0,
          minHeight: 48,
          gap: 8,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          borderRadius: BorderRadius.circular(12),
          textStyle: AppTypography.textMediumBold,
        );
      case AppButtonSize.large:
        return _AppButtonSizeStyle(
          minWidth: 0,
          minHeight: 60,
          gap: 8,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          borderRadius: BorderRadius.circular(16),
          textStyle: AppTypography.textLargeMedium,
        );
    }
  }
}

class _AppButtonVariantStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final Border? border;

  const _AppButtonVariantStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    this.border,
  });

  factory _AppButtonVariantStyle.resolve({
    required AppButtonVariant variant,
    required bool isDark,
    required ColorScheme colorScheme,
    required bool isEnabled,
  }) {
    if (!isEnabled) {
      return _AppButtonVariantStyle(
        backgroundColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        foregroundColor: colorScheme.onSurface.withValues(alpha: 0.55),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.45)),
      );
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return const _AppButtonVariantStyle(
          backgroundColor: AppColors.primary600,
          foregroundColor: AppColors.greyWhite,
        );
      case AppButtonVariant.secondary:
        return _AppButtonVariantStyle(
          backgroundColor: isDark ? AppColors.primary900 : AppColors.primary50,
          foregroundColor: isDark ? AppColors.primary100 : AppColors.primary700,
          border: Border.all(
            color: isDark ? AppColors.primary800 : AppColors.primary200,
          ),
        );
      case AppButtonVariant.neutral:
        return _AppButtonVariantStyle(
          backgroundColor: isDark
              ? AppColors.darkGreyButton
              : AppColors.lightGreyButton,
          foregroundColor: isDark ? AppColors.greyWhite : AppColors.grey900,
          border: Border.all(
            color: isDark ? AppColors.greyBorder : AppColors.grey200,
            width: 1.14667,
          ),
        );
      case AppButtonVariant.destructive:
        return _AppButtonVariantStyle(
          backgroundColor: isDark ? AppColors.red900 : AppColors.red50,
          foregroundColor: isDark ? AppColors.red100 : AppColors.red700,
          border: Border.all(
            color: isDark ? AppColors.red800 : AppColors.red200,
          ),
        );
    }
  }
}
