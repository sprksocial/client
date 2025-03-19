import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
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
