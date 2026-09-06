import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';

/// Keeps automatically supplied navigation icons in the Spark design system.
final ActionIconThemeData appActionIconTheme = ActionIconThemeData(
  backButtonIconBuilder: (context) => AppIcon(
    Directionality.of(context) == TextDirection.rtl
        ? AppIconData.chevronRight
        : AppIconData.chevronLeft,
  ),
  closeButtonIconBuilder: (context) => const AppIcon(AppIconData.cancel),
);
