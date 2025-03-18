import 'package:flutter/material.dart';

class AppColors {
  // Main color palette
  static const Color lightLavender = Color(0xFFDCD9E2);
  static const Color darkPurple = Color(0xFF403848);
  static const Color deepPurple = Color(0xFF28232D);
  static const Color nearBlack = Color(0xFF0D0A0F);
  static const Color richPurple = Color(0xFF330072);
  static const Color brightPurple = Color(0xFFB20AFF);
  static const Color pink = Color(0xFFFF2696); // Main app color for buttons and highlights
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // New colors
  static const Color blue = Color(0xFF0073FF); // For followers
  static const Color lightBlue = Color(0xFF40A9FF); // Lighter blue variant
  static const Color teal = Color(0xFF00C9B8); // For bookmarks
  static const Color green = Color(0xFF12DB59); // For comments
  static const Color red = Color(0xFFFF3A2C); // For likes
  static const Color orange = Color(0xFFFF7B00); // For alerts and danger

  // Semantic colors based on our palette
  static const Color primary = pink;
  static const Color secondary = brightPurple;
  static const Color accent = richPurple;

  // Background colors
  static const Color background = white;
  static const Color lightBackground = white;
  static const Color cardBackground = white;
  static const Color darkBackground = nearBlack;
  static const Color modalBackground = nearBlack;

  // Text colors
  static const Color textPrimary = deepPurple;
  static const Color textSecondary = darkPurple;
  static const Color textLight = lightLavender;
  static const Color textOnDark = white;

  // Border and divider colors
  static const Color border = darkPurple;
  static const Color divider = lightLavender;

  // Status colors
  static const Color success = green;
  static const Color error = red;
  static const Color warning = orange;
  static const Color info = blue;

  // Activity colors
  static const Color likeColor = red;
  static const Color commentColor = green;
  static const Color followColor = blue;

  // Unread indicator
  static const Color unreadIndicator = pink;

  // Navigation
  static const Color selectedIconLight = pink;
  static const Color unselectedIconLight = darkPurple;
  static const Color selectedIconDark = white;
  static const Color unselectedIconDark = darkPurple;
}
