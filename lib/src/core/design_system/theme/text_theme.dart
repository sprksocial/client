import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

/// Creates text themes using our typography tokens
/// This ensures consistent typography throughout the app
/// https://medium.com/@vosarat1995/material-3-you-typography-cheatsheet-ffc58c540181
class AppTextTheme {
  AppTextTheme._();

  /// Light theme text theme
  static const TextTheme light = TextTheme(
    // Display styles - Used for hero text and large headings
    displayLarge: AppTypography.displayLarge,
    displayMedium: AppTypography.displayMedium,
    displaySmall: AppTypography.displaySmall,

    // Headline styles - Used for section headers and important text
    headlineLarge: AppTypography.headlineLarge,
    headlineMedium: AppTypography.headlineMedium,
    headlineSmall: AppTypography.headlineSmall,

    // Title styles - Used for list items, card titles
    titleLarge: AppTypography.titleLarge,
    titleMedium: AppTypography.titleMedium,
    titleSmall: AppTypography.titleSmall,

    // Body styles - Used for paragraphs and main content
    bodyLarge: AppTypography.bodyLarge,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.bodySmall,

    // Label styles - Used for buttons, tabs, form labels
    labelLarge: AppTypography.labelLarge,
    labelMedium: AppTypography.labelMedium,
    labelSmall: AppTypography.labelSmall,
  );

  /// Dark theme text theme
  /// Same typography but optimized for dark backgrounds
  static TextTheme get dark => light.apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  );
}
