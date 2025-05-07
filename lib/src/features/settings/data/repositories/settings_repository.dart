import 'dart:convert';
import '../models/label_preference.dart';
import 'package:sparksocial/src/core/storage/storage.dart';

class SettingsRepository {
  static const String _feedBlurKey = 'feed_blur_enabled';
  static const String _followedLabelersKey = 'followed_labelers';
  static const String _labelerPreferencesKey = 'labeler_preferences';
  static const String _hideAdultContentKey = 'hide_adult_content';

  final StorageManager _storageManager;

  SettingsRepository(this._storageManager);

  Future<bool> getFeedBlurEnabled() async {
    return await _storageManager.preferences.getBool(_feedBlurKey) ?? false;
  }

  Future<void> setFeedBlurEnabled(bool value) async {
    await _storageManager.preferences.setBool(_feedBlurKey, value);
  }

  Future<bool> getHideAdultContent() async {
    return await _storageManager.preferences.getBool(_hideAdultContentKey) ?? true;
  }

  Future<void> setHideAdultContent(bool value) async {
    await _storageManager.preferences.setBool(_hideAdultContentKey, value);
  }

  Future<List<String>> getFollowedLabelers() async {
    return await _storageManager.preferences.getStringList(_followedLabelersKey) ?? [];
  }

  Future<void> setFollowedLabelers(List<String> labelerDids) async {
    await _storageManager.preferences.setStringList(_followedLabelersKey, labelerDids);
  }

  Future<Map<String, Map<String, String>>> getLabelPreferences() async {
    final prefsJson = await _storageManager.preferences.getString(_labelerPreferencesKey);
    if (prefsJson == null) {
      return {};
    }

    final Map<String, dynamic> decoded = jsonDecode(prefsJson);
    return decoded.map((key, value) => MapEntry(
      key,
      (value as Map<String, dynamic>).map((k, v) => MapEntry(k, v.toString())),
    ));
  }

  Future<void> saveLabelPreferences(Map<String, Map<String, String>> preferences) async {
    final jsonStr = jsonEncode(preferences);
    await _storageManager.preferences.setString(_labelerPreferencesKey, jsonStr);
  }

  Future<LabelPreference?> getLabelPreference(String labelerDid, String labelValue) async {
    final prefs = await getLabelPreferences();
    
    if (!prefs.containsKey(labelerDid)) {
      return null;
    }
    
    final prefValue = prefs[labelerDid]?[labelValue];
    if (prefValue == null) return null;
    
    return LabelPreference.values.firstWhere(
      (e) => e.name == prefValue, 
      orElse: () => LabelPreference.warn
    );
  }

  Future<void> setLabelPreference(
    String labelerDid, 
    String labelValue, 
    LabelPreference preference
  ) async {
    final prefs = await getLabelPreferences();
    
    // Ensure the labeler is initialized in the map
    prefs[labelerDid] ??= {};
    
    // Set the preference
    prefs[labelerDid]![labelValue] = preference.name;
    
    // Save to storage
    await saveLabelPreferences(prefs);
  }

  Future<void> removeLabelPreference(String labelerDid, String labelValue) async {
    final prefs = await getLabelPreferences();
    
    // Check if the labeler exists
    if (prefs.containsKey(labelerDid)) {
      // Remove the specific preference
      prefs[labelerDid]?.remove(labelValue);
      
      // Save to storage
      await saveLabelPreferences(prefs);
    }
  }

  Future<void> clearLabelerPreferences(String labelerDid) async {
    final prefs = await getLabelPreferences();
    
    prefs.remove(labelerDid);
    await saveLabelPreferences(prefs);
  }
} 