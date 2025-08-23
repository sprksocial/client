import 'package:flutter/material.dart';

class AppBorders {
  AppBorders._();

  // Border radius scale
  static const double radiusXs = 2;
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusXxl = 24;
  static const double radiusFull = 9999; // For circular elements

  // Border widths
  static const double borderWidthThin = 1;
  static const double borderWidthMedium = 2;
  static const double borderWidthThick = 4;

  // Common border radius configurations
  static BorderRadius get buttonRadius => BorderRadius.circular(radiusMd);
  static BorderRadius get cardRadius => BorderRadius.circular(radiusLg);
  static BorderRadius get inputRadius => BorderRadius.circular(radiusMd);
  static BorderRadius get dialogRadius => BorderRadius.circular(radiusXl);
}
