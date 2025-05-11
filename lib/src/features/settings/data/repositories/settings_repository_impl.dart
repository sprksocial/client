import 'dart:convert';
import 'package:sparksocial/src/features/settings/data/repositories/settings_repository.dart';

import '../models/label_preference.dart';
import '../models/settings_state.dart';
import 'package:sparksocial/src/core/storage/storage.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final StorageManager _storageManager;

  SettingsRepositoryImpl(this._storageManager);

  @override
  Future<bool> getFeedBlurEnabled() async {
    return await _storageManager.preferences.getBool(StorageKeys.feedBlurKey) ?? false;
  }

  @override
  Future<void> setFeedBlurEnabled(bool value) async {
    await _storageManager.preferences.setBool(StorageKeys.feedBlurKey, value);
  }

  @override
  Future<bool> getHideAdultContent() async {
    return await _storageManager.preferences.getBool(StorageKeys.hideAdultContentKey) ?? true;
  }

  @override
  Future<void> setHideAdultContent(bool value) async {
    await _storageManager.preferences.setBool(StorageKeys.hideAdultContentKey, value);
  }

  @override
  Future<List<String>> getFollowedLabelers() async {
    return await _storageManager.preferences.getStringList(StorageKeys.followedLabelers) ?? [];
  }

  @override
  Future<void> setFollowedLabelers(List<String> labelerDids) async {
    await _storageManager.preferences.setStringList(StorageKeys.followedLabelers, labelerDids);
  }

  @override
  Future<Map<String, Map<String, String>>> getLabelPreferences() async {
    final prefsJson = await _storageManager.preferences.getString(StorageKeys.labelPreferencePrefix);
    if (prefsJson == null) {
      return {};
    }

    final Map<String, dynamic> decoded = jsonDecode(prefsJson);
    return decoded.map((key, value) => MapEntry(
      key,
      (value as Map<String, dynamic>).map((k, v) => MapEntry(k, v.toString())),
    ));
  }

  @override
  Future<void> saveLabelPreferences(Map<String, Map<String, String>> preferences) async {
    final jsonStr = jsonEncode(preferences);
    await _storageManager.preferences.setString(StorageKeys.labelPreferencePrefix, jsonStr);
  }

  @override
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

  @override
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

  @override
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

  @override
  Future<void> clearLabelerPreferences(String labelerDid) async {
    final prefs = await getLabelPreferences();
    
    prefs.remove(labelerDid);
    await saveLabelPreferences(prefs);
  }

  // Feed settings implementations
  @override
  Future<bool> getFollowingFeedEnabled() async {
    return await _storageManager.preferences.getBool(StorageKeys.followingFeedEnabledKey) ?? true;
  }

  @override
  Future<void> setFollowingFeedEnabled(bool value) async {
    await _storageManager.preferences.setBool(StorageKeys.followingFeedEnabledKey, value);
  }

  @override
  Future<bool> getForYouFeedEnabled() async {
    return await _storageManager.preferences.getBool(StorageKeys.forYouFeedEnabledKey) ?? true;
  }

  @override
  Future<void> setForYouFeedEnabled(bool value) async {
    await _storageManager.preferences.setBool(StorageKeys.forYouFeedEnabledKey, value);
  }

  @override
  Future<bool> getLatestFeedEnabled() async {
    return await _storageManager.preferences.getBool(StorageKeys.latestFeedEnabledKey) ?? true;
  }

  @override
  Future<void> setLatestFeedEnabled(bool value) async {
    await _storageManager.preferences.setBool(StorageKeys.latestFeedEnabledKey, value);
  }

  @override
  Future<FeedType> getSelectedFeedType() async {
    final value = await _storageManager.preferences.getInt(StorageKeys.selectedFeedTypeKey);
    return value != null ? FeedType.fromValue(value) : FeedType.forYou;
  }

  @override
  Future<void> setSelectedFeedType(FeedType value) async {
    await _storageManager.preferences.setInt(StorageKeys.selectedFeedTypeKey, value.value);
  }
} 