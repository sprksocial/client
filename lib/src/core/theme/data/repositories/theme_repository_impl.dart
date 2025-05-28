import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/core/theme/providers/theme_provider.dart';
import 'theme_repository.dart';

/// Implementation of ThemeRepository using SharedPreferences
class ThemeRepositoryImpl implements ThemeRepository {
  final StorageManager _storageManager;

  const ThemeRepositoryImpl(this._storageManager);

  @override
  Future<ThemeMode?> getThemeMode() async {
    final savedTheme = await _storageManager.preferences.getString(StorageKeys.themeKey);
    return savedTheme != null ? ThemeModeExtension.fromValue(savedTheme) : null;
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await _storageManager.preferences.setString(StorageKeys.themeKey, themeMode.value);
  }
}
