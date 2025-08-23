import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); 

  // Primary colors - Main brand colors
  static const Color primary = Color(0xFFFF2696);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary colors - Accent colors
  static const Color secondary = Color(0xFFB20AFF);
  static const Color secondaryLight = Color(0xFF4FDFE7);
  static const Color secondaryDark = Color(0xFF02A894);
  static const Color onSecondary = Color(0xFF000000);

  // Surface colors - Backgrounds and containers
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceTint = Color(0xFFE3F2FD);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);

  // Background colors
  static const Color background = Color(0xFFFFFBFE);
  static const Color onBackground = Color(0xFF1C1B1F);

  // Status colors - For feedback and states
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  static const Color onSuccess = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);
  static const Color onWarning = Color(0xFF000000);

  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFC62828);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);
  static const Color onInfo = Color(0xFFFFFFFF);

  // Neutral colors - Grays and borders
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  // Border colors
  static const Color border = neutral300;
  static const Color borderFocus = primary;
  static const Color borderError = error;

  // Overlay colors - For modals and overlays
  static const Color overlay = Color(0x80000000);
  static const Color scrim = Color(0x1A000000);

  static const Color shadow = Color(0xFF000000);
}
