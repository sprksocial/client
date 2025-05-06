import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../storage/storage_manager.dart';

/// ThemeMode enum extension for serialization
extension ThemeModeExtension on ThemeMode {
  String get value {
    switch (this) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode fromValue(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

/// Theme state class
class ThemeState {
  final ThemeMode themeMode;
  
  const ThemeState({required this.themeMode});
  
  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

/// Theme notifier that manages theme state
class ThemeNotifier extends StateNotifier<ThemeState> {
  final StorageManager _storageManager;
  static const String _themeKey = 'app_theme_mode';
  
  ThemeNotifier(this._storageManager) 
    : super(const ThemeState(themeMode: ThemeMode.system)) {
    _loadSavedTheme();
  }
  
  /// Load the saved theme from storage
  Future<void> _loadSavedTheme() async {
    final savedTheme = await _storageManager.preferences.getString(_themeKey);
    if (savedTheme != null) {
      state = state.copyWith(themeMode: ThemeModeExtension.fromValue(savedTheme));
    }
  }
  
  /// Change theme and persist the choice
  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _storageManager.preferences.setString(_themeKey, themeMode.value);
    state = state.copyWith(themeMode: themeMode);
  }
  
  /// Toggle between light and dark themes
  Future<void> toggleTheme() async {
    final ThemeMode newThemeMode;
    
    if (state.themeMode == ThemeMode.light) {
      newThemeMode = ThemeMode.dark;
    } else {
      newThemeMode = ThemeMode.light;
    }
    
    await setThemeMode(newThemeMode);
  }
}

/// Provider for theme state that uses the service locator
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  // Use the instance from GetIt
  return GetIt.instance<ThemeNotifier>();
});

/// Convenience provider that exposes just the ThemeMode
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeProvider).themeMode;
});
