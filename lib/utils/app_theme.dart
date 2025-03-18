import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.background,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.background, foregroundColor: AppColors.textPrimary, elevation: 0),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        bodySmall: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        titleMedium: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.deepPurple,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.textLight, fontSize: 16),
        bodySmall: TextStyle(color: AppColors.textLight, fontSize: 14),
        titleMedium: TextStyle(color: AppColors.textLight, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  static Color getNavBackgroundColor(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    

    return brightness == Brightness.dark ? AppColors.nearBlack : AppColors.lightBackground;
  }

  static Color getSelectedIconColor(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark ? AppColors.selectedIconDark : AppColors.selectedIconLight;
  }

  static Color getUnselectedIconColor(BuildContext context) {
    return AppColors.unselectedIconDark;
  }

  static Color getBackgroundColor(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    

    return brightness == Brightness.dark ? AppColors.darkBackground : AppColors.background;
  }

  static Color getTextColor(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark ? AppColors.textLight : AppColors.textPrimary;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark ? AppColors.textLight.withAlpha(179) : AppColors.textSecondary;
  }
}
