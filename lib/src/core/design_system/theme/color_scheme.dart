import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';

/// Creates color schemes for light and dark themes using design tokens
class AppColorScheme {
  AppColorScheme._();

  /// Light theme color scheme
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    // Primary colors - Used for prominent UI elements like FAB, app bars
    primary: AppColors.primary500,
    onPrimary: AppColors.primary900,
    primaryContainer: AppColors.primary100,
    onPrimaryContainer: AppColors.primary900,

    // Secondary colors - Used for less prominent elements like chips, switches
    secondary: AppColors.turquoise600,
    onSecondary: AppColors.greyWhite,
    secondaryContainer: AppColors.turquoise100,
    onSecondaryContainer: AppColors.turquoise900,

    // Tertiary colors - Used as an additional accent color
    tertiary: AppColors.coralReef600,
    onTertiary: AppColors.greyWhite,
    tertiaryContainer: AppColors.coralReef100,
    onTertiaryContainer: AppColors.coralReef900,

    // Error colors - Used for error states and destructive actions
    error: AppColors.red600,
    onError: AppColors.red900,
    errorContainer: AppColors.red100,
    onErrorContainer: AppColors.red900,
    onSurface: AppColors.grey800,
    surfaceContainerHighest: AppColors.lightGreyButton,
    onSurfaceVariant: AppColors.grey700,

    // Additional colors for borders and outlines
    surface: AppColors.greyWhite,
    outline: AppColors.grey200,
    outlineVariant: AppColors.grey100,
    inverseSurface: AppColors.grey800,
    onInverseSurface: AppColors.lightGreyButton,
    inversePrimary: AppColors.primary300,
    shadow: AppColors.greyBlack,
    scrim: AppColors.greyBlack,
  );

  /// Dark theme color scheme
  /// Provides appropriate colors for dark mode while maintaining brand identity
  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    // Primary colors
    primary: AppColors.primary500,
    onPrimary: AppColors.primary900,
    primaryContainer: AppColors.primary800,
    onPrimaryContainer: AppColors.primary100,

    // Secondary colors
    secondary: AppColors.turquoise400,
    onSecondary: AppColors.turquoise900,
    secondaryContainer: AppColors.turquoise800,
    onSecondaryContainer: AppColors.turquoise100,

    // Tertiary colors
    tertiary: AppColors.coralReef400,
    onTertiary: AppColors.coralReef900,
    tertiaryContainer: AppColors.coralReef800,
    onTertiaryContainer: AppColors.coralReef100,

    // Error colors
    error: AppColors.red400,
    onError: AppColors.red900,
    errorContainer: AppColors.red800,
    onErrorContainer: AppColors.red100,
    surface: AppColors.grey900,
    onSurface: AppColors.grey100,
    surfaceContainerHighest: AppColors.grey700,
    onSurfaceVariant: AppColors.grey200,

    // Additional colors for borders and outlines
    outline: AppColors.grey500,
    outlineVariant: AppColors.grey600,
    inverseSurface: AppColors.grey100,
    onInverseSurface: AppColors.grey800,
    inversePrimary: AppColors.primary700,
    shadow: AppColors.greyBlack,
    scrim: AppColors.greyBlack,
  );
}
