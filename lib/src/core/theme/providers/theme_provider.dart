import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/theme/providers/theme_state.dart';
import 'package:sparksocial/src/core/theme/data/repositories/theme_repository.dart';

part 'theme_provider.g.dart';

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

/// Theme notifier that manages theme state
@Riverpod(keepAlive: true)
class Theme extends _$Theme {
  late final ThemeRepository _themeRepository;
  
  @override
  ThemeState build() {
    _themeRepository = GetIt.instance<ThemeRepository>();
    // Initialize with system theme
    return const ThemeState(themeMode: ThemeMode.system);
  }
  
  /// Initialize by loading the saved theme
  Future<void> initialize() async {
    final savedTheme = await _themeRepository.getThemeMode();
    if (savedTheme != null) {
      state = state.copyWith(themeMode: savedTheme);
    }
  }
  
  /// Change theme and persist the choice
  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _themeRepository.saveThemeMode(themeMode);
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

/// Convenience provider that exposes just the ThemeMode
@Riverpod(keepAlive: true)
ThemeMode themeMode(Ref ref) {
  return ref.watch(themeProvider).themeMode;
}
