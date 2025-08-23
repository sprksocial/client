import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';

/// Creates color schemes for light and dark themes using design tokens
class AppColorScheme {
  AppColorScheme._();

  /// Light theme color scheme
  /// This translates our design tokens into Material Design's ColorScheme
  static const ColorScheme light = ColorScheme.light(
    // Primary colors - Used for prominent UI elements like FAB, app bars
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.onPrimary,

    // Secondary colors - Used for less prominent elements like chips, switches
    secondary: AppColors.secondary,
    secondaryContainer: AppColors.secondaryLight,
    onSecondaryContainer: AppColors.onSecondary,
    onSurface: AppColors.onSurface,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.onSurfaceVariant,

    // Error colors - Used for error states and destructive actions
    error: AppColors.error,
    errorContainer: AppColors.errorLight,
    onErrorContainer: AppColors.onError,

    // Additional colors for borders and outlines
    outline: AppColors.border,
    outlineVariant: AppColors.neutral200,
    shadow: AppColors.neutral900,
    scrim: AppColors.overlay,
    inverseSurface: AppColors.neutral800,
    onInverseSurface: AppColors.surface,
    inversePrimary: AppColors.primaryLight,
    surfaceTint: AppColors.surfaceTint,
  );

  /// Dark theme color scheme
  /// Provides appropriate colors for dark mode while maintaining brand identity
  static const ColorScheme dark = ColorScheme.dark(
    primary: AppColors.primaryLight,
    onPrimary: AppColors.neutral900,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.surface,

    secondary: AppColors.secondaryLight,
    onSecondary: AppColors.neutral900,
    secondaryContainer: AppColors.secondaryDark,
    onSecondaryContainer: AppColors.surface,

    surface: AppColors.neutral800,
    surfaceContainerHighest: AppColors.neutral700,
    onSurfaceVariant: AppColors.neutral200,

    error: AppColors.errorLight,
    onError: AppColors.neutral900,
    errorContainer: AppColors.errorDark,
    onErrorContainer: AppColors.surface,

    outline: AppColors.neutral600,
    outlineVariant: AppColors.neutral700,
    shadow: AppColors.shadow,
    scrim: AppColors.overlay,
    inverseSurface: AppColors.surface,
    onInverseSurface: AppColors.neutral900,
    inversePrimary: AppColors.primary,
    surfaceTint: AppColors.primary,
  );
}
