import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

/// Creates text themes using our typography tokens
/// This ensures consistent typography throughout the app
/// https://medium.com/@vosarat1995/material-3-you-typography-cheatsheet-ffc58c540181
class AppTextTheme {
  AppTextTheme._();

  /// Light theme text theme
  static const TextTheme light = TextTheme(
    // Display styles - Used for hero text and large headings
    displayLarge: AppTypography.displayLargeBold,
    displayMedium: AppTypography.displayMediumBold,
    displaySmall: AppTypography.displaySmallBold,

    // Headline styles - Used for section headers and important text
    headlineLarge: AppTypography.headlineXlBold,
    headlineMedium: AppTypography.headlineLargeBold,
    headlineSmall: AppTypography.headlineMediumBold,

    // Title styles - Used for list items, card titles
    titleLarge: AppTypography.headlineLargeMedium,
    titleMedium: AppTypography.headlineMediumMedium,
    titleSmall: AppTypography.headlineSmallMedium,

    // Body styles - Used for paragraphs and main content
    bodyLarge: AppTypography.textLargeMedium,
    bodyMedium: AppTypography.textMediumMedium,
    bodySmall: AppTypography.textSmallMedium,

    // Label styles - Used for buttons, tabs, form labels
    labelLarge: AppTypography.textLargeBold,
    labelMedium: AppTypography.textMediumBold,
    labelSmall: AppTypography.textSmallBold,
  );

  /// Dark theme text theme
  /// Same typography but optimized for dark backgrounds
  static TextTheme get dark => light.apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  );
}
