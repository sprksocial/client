import 'package:flutter/cupertino.dart';
import 'app_colors.dart';

class AppTheme {
  // This theme will automatically adapt based on platform brightness
  static CupertinoThemeData get theme => const CupertinoThemeData(
    brightness: Brightness.light,  // Default brightness, will be overridden by system
    primaryColor: AppColors.primary,
    primaryContrastingColor: AppColors.white,
    barBackgroundColor: AppColors.background,
    scaffoldBackgroundColor: AppColors.background,
  );
  
  // Helper methods to determine colors based on theme brightness
  static Color getNavBackgroundColor(BuildContext context, bool isHomePage) {
    final brightness = MediaQuery.of(context).platformBrightness;
    if (isHomePage) {
      return AppColors.nearBlack;
    }
    
    return brightness == Brightness.dark 
        ? AppColors.nearBlack 
        : AppColors.lightBackground;
  }
  
  static Color getSelectedIconColor(BuildContext context, bool isHomePage) {
    final brightness = MediaQuery.of(context).platformBrightness;
    if (isHomePage) {
      return AppColors.selectedIconDark;
    }
    
    return brightness == Brightness.dark 
        ? AppColors.selectedIconDark 
        : AppColors.selectedIconLight;
  }
  
  static Color getUnselectedIconColor(BuildContext context, bool isHomePage) {
    return AppColors.unselectedIconDark;
  }
  
  static Color getBackgroundColor(BuildContext context, bool isHomePage) {
    final brightness = MediaQuery.of(context).platformBrightness;
    if (isHomePage) {
      return AppColors.nearBlack;
    }
    
    return brightness == Brightness.dark 
        ? AppColors.darkBackground 
        : AppColors.background;
  }
  
  // Get text color based on brightness
  static Color getTextColor(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark 
        ? AppColors.textLight 
        : AppColors.textPrimary;
  }
  
  // Get secondary text color based on brightness
  static Color getSecondaryTextColor(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark 
        ? AppColors.textLight.withAlpha(179) 
        : AppColors.textSecondary;
  }
} 