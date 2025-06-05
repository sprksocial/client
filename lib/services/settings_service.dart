import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';
import 'sprk_client.dart';

/// Enum to represent the user's preference for a specific label
enum LabelPreference { show, warn, hide }

/// Enum to represent follow mode options
enum FollowMode {
  sprk,
  bsky;

  @override
  String toString() => name;
}

class SettingsService extends ChangeNotifier {
  static const String _feedBlurKey = 'feed_blur_enabled';
  static const String _followedLabelersKey = 'followed_labelers';
  static const String _labelerPreferencesKey = 'labeler_preferences';
  static const String _hideAdultContentKey = 'hide_adult_content';
  static const String _keyFollowMode = 'profile_follow_mode';
  static const String _postToBskyKey = 'post_to_bsky_enabled';

  SharedPreferences? _prefs;
  bool _isLoading = true;
  bool _feedBlurEnabled = false;
  bool _hideAdultContent = true;
  bool _postToBskyEnabled = false;
  List<String> _followedLabelers = [];
  FollowMode _followMode = FollowMode.sprk;
  final AuthService _authService;
  final SprkClient _sprkClient;

  /// Stores label preferences for each labeler
  /// Format: {labelerDid: {labelValue: preferenceValue}}
  Map<String, Map<String, String>> _labelPreferences = {};

  SettingsService({required AuthService authService}) : _authService = authService, _sprkClient = SprkClient(authService) {
    _loadSettings();
    // Listen for auth state changes to clear cached values on logout
    _authService.addListener(_handleAuthStateChange);
  }

  @override
  void dispose() {
    _authService.removeListener(_handleAuthStateChange);
    super.dispose();
  }

  void _handleAuthStateChange() {
    if (!_authService.isAuthenticated) {
      _clearCachedFollowMode();
    }
  }

  void _clearCachedFollowMode() {
    _prefs?.remove(_keyFollowMode);
  }

  bool get isLoading => _isLoading;
  bool get feedBlurEnabled => _feedBlurEnabled;
  bool get hideAdultContent => _hideAdultContent;
  bool get postToBskyEnabled => _postToBskyEnabled;
  List<String> get followedLabelers => List.unmodifiable(_followedLabelers);
  FollowMode get followMode => _followMode;

  /// Returns an immutable copy of all labeler preferences
  Map<String, Map<String, String>> get labelPreferences => Map.unmodifiable(_labelPreferences);

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _feedBlurEnabled = _prefs?.getBool(_feedBlurKey) ?? false;
    _hideAdultContent = _prefs?.getBool(_hideAdultContentKey) ?? true; // Default to true if not set
    _postToBskyEnabled = _prefs?.getBool(_postToBskyKey) ?? false;
    _followedLabelers = _prefs?.getStringList(_followedLabelersKey) ?? [];

    // Load the cached follow mode as a temporary value
    final savedMode = _prefs?.getString(_keyFollowMode) ?? 'sprk';
    _followMode = savedMode == 'bsky' ? FollowMode.bsky : FollowMode.sprk;

    // Load label preferences
    final prefsJson = _prefs?.getString(_labelerPreferencesKey);
    if (prefsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(prefsJson);
      _labelPreferences = decoded.map(
        (key, value) => MapEntry(key, (value as Map<String, dynamic>).map((k, v) => MapEntry(k, v.toString()))),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setFeedBlur(bool value) async {
    if (_isLoading) await _loadSettings();
    _feedBlurEnabled = value;
    await _prefs?.setBool(_feedBlurKey, value);
    notifyListeners();
  }

  Future<void> setHideAdultContent(bool value) async {
    if (_isLoading) await _loadSettings();
    _hideAdultContent = value;
    await _prefs?.setBool(_hideAdultContentKey, value);
    notifyListeners();
  }

  Future<void> setPostToBsky(bool value) async {
    if (_isLoading) await _loadSettings();
    _postToBskyEnabled = value;
    await _prefs?.setBool(_postToBskyKey, value);
    notifyListeners();
  }

  Future<void> setFollowedLabelers(List<String> labelerDids) async {
    if (_isLoading) await _loadSettings();
    _followedLabelers = List<String>.from(labelerDids);
    await _prefs?.setStringList(_followedLabelersKey, _followedLabelers);
    notifyListeners();
  }

  Future<void> addFollowedLabeler(String labelerDid) async {
    if (_isLoading) await _loadSettings();
    if (!_followedLabelers.contains(labelerDid)) {
      _followedLabelers.add(labelerDid);
      await _prefs?.setStringList(_followedLabelersKey, _followedLabelers);
      notifyListeners();
    }
  }

  Future<void> removeFollowedLabeler(String labelerDid) async {
    if (_isLoading) await _loadSettings();
    if (_followedLabelers.contains(labelerDid)) {
      _followedLabelers.remove(labelerDid);
      await _prefs?.setStringList(_followedLabelersKey, _followedLabelers);

      // Also remove preferences for this labeler
      _labelPreferences.remove(labelerDid);
      await _saveLabelPreferences();

      notifyListeners();
    }
  }

  /// Saves label preferences to SharedPreferences
  Future<void> _saveLabelPreferences() async {
    if (_prefs == null) return;

    final jsonStr = jsonEncode(_labelPreferences);
    await _prefs!.setString(_labelerPreferencesKey, jsonStr);
  }

  /// Sets a preference for a specific label from a labeler
  Future<void> setLabelPreference(String labelerDid, String labelValue, LabelPreference preference) async {
    if (_isLoading) await _loadSettings();

    // Ensure the labeler is initialized in the map
    _labelPreferences[labelerDid] ??= {};

    // Set the preference
    _labelPreferences[labelerDid]![labelValue] = preference.name;

    // Save to SharedPreferences
    await _saveLabelPreferences();
    notifyListeners();
  }

  /// Removes a preference for a specific label, reverting to the default
  Future<void> removeLabelPreference(String labelerDid, String labelValue) async {
    if (_isLoading) await _loadSettings();

    // Check if the labeler and preference exist
    if (_labelPreferences.containsKey(labelerDid)) {
      // Remove the specific preference
      _labelPreferences[labelerDid]?.remove(labelValue);

      // Save to SharedPreferences
      await _saveLabelPreferences();
      notifyListeners();
    }
  }

  /// Gets the preference for a specific label from a labeler
  /// Returns null if no preference is defined
  LabelPreference? getLabelPreference(String labelerDid, String labelValue) {
    if (_isLoading || !_labelPreferences.containsKey(labelerDid)) {
      return null;
    }

    final prefValue = _labelPreferences[labelerDid]?[labelValue];
    if (prefValue == null) return null;

    return LabelPreference.values.firstWhere(
      (e) => e.name == prefValue,
      orElse: () => LabelPreference.warn, // default
    );
  }

  /// Gets the preference for a specific label, or returns the default setting from the label definition
  LabelPreference getLabelPreferenceOrDefault(String labelerDid, String labelValue, Map<String, dynamic>? labelDefinition) {
    // First try to get user's explicit preference
    final userPreference = getLabelPreference(labelerDid, labelValue);
    if (userPreference != null) {
      return userPreference;
    }

    // If no user preference and we have a label definition with defaultSetting
    if (labelDefinition != null && labelDefinition.containsKey('defaultSetting')) {
      final defaultSetting = labelDefinition['defaultSetting'] as String;

      // Map the defaultSetting string to LabelPreference
      switch (defaultSetting) {
        case 'show':
          return LabelPreference.show;
        case 'hide':
          return LabelPreference.hide;
        case 'warn':
          return LabelPreference.warn;
        default:
          return LabelPreference.warn; // Fallback default
      }
    }

    // Final fallback
    return LabelPreference.warn;
  }

  /// Sets preferences in bulk for all labels from a labeler
  Future<void> setLabelerPreferences(String labelerDid, Map<String, LabelPreference> preferences) async {
    if (_isLoading) await _loadSettings();

    // Convert the map of enums to strings
    final stringPrefs = preferences.map((key, value) => MapEntry(key, value.name));

    _labelPreferences[labelerDid] = stringPrefs;
    await _saveLabelPreferences();
    notifyListeners();
  }

  /// Removes all preferences for a specific labeler
  Future<void> clearLabelerPreferences(String labelerDid) async {
    if (_isLoading) await _loadSettings();

    _labelPreferences.remove(labelerDid);
    await _saveLabelPreferences();
    notifyListeners();
  }

  /// Fetch and sync the follow mode from the backend, store locally, and notify listeners if changed.
  Future<void> syncFollowModeFromServer() async {
    if (_isLoading) await _loadSettings();
    try {
      final response = await _sprkClient.actor.getPreferences();
      final serverMode = response.data['followMode'] ?? 'sprk';
      final mode = serverMode == 'bsky' ? FollowMode.bsky : FollowMode.sprk;
      if (_followMode != mode) {
        _followMode = mode;
        await _prefs?.setString(_keyFollowMode, mode.name);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to sync follow mode from server: $e');
    }
  }

  /// Sets the profile follow mode, saves it, and notifies listeners.
  Future<void> setFollowMode(FollowMode mode) async {
    if (_isLoading) await _loadSettings();

    _followMode = mode;
    await _prefs?.setString(_keyFollowMode, mode.name);

    // Call the API to update the server-side preference
    try {
      await _sprkClient.actor.putPreferences(followMode: mode);
    } catch (e) {
      debugPrint('Failed to update server preference: $e');
    }

    notifyListeners();
  }
}
