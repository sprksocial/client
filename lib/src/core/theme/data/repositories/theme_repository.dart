import 'package:flutter/material.dart';

/// Interface for theme persistence operations
abstract interface class ThemeRepository {
  /// Get the saved theme mode or null if not saved
  Future<ThemeMode?> getThemeMode();
  
  /// Save the current theme mode
  Future<void> saveThemeMode(ThemeMode themeMode);
}
