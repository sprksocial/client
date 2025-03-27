import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _feedBlurKey = 'feed_blur_enabled';
  
  SharedPreferences? _prefs;
  bool _isLoading = true;
  bool _feedBlurEnabled = false;

  SettingsService() {
    _loadSettings();
  }

  bool get isLoading => _isLoading;
  bool get feedBlurEnabled => _feedBlurEnabled;

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _feedBlurEnabled = _prefs?.getBool(_feedBlurKey) ?? false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setFeedBlur(bool value) async {
    if (_isLoading) await _loadSettings();
    _feedBlurEnabled = value;
    await _prefs?.setBool(_feedBlurKey, value);
    notifyListeners();
  }
} 