import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// this whole file will need to be refactored when we add modular feed types
// for now, I just transformed the gambiarra enum class into an actual enum
// when we add modular feed types, this enum will be replaced by a class
enum FeedType {
  following(0, 'Following'),
  forYou(1, 'For You'),
  latest(2, 'Latest');

  final int value;
  final String name;

  const FeedType(this.value, this.name);

  static FeedType fromValue(int value) {
    return FeedType.values.firstWhere((feedType) => feedType.value == value, orElse: () => FeedType.forYou);
  }
}

class FeedSettingsService extends ChangeNotifier {
  // Singleton instance
  static final FeedSettingsService _instance = FeedSettingsService._internal();
  factory FeedSettingsService() => _instance;
  FeedSettingsService._internal();

  // Preference keys
  static const String _keyFollowingFeed = 'following_feed_enabled';
  static const String _keyForYouFeed = 'for_you_feed_enabled';
  static const String _keyLatestFeed = 'latest_feed_enabled';
  static const String _keyDisableBlur = 'disable_background_blur';
  static const String _keySelectedFeed = 'selected_feed_type';
  static const String _keyDisableNsfwContent = 'disable_nsfw_content';
  // there should be a key for each label of each labeler
  // for now, we'll just use the default labels

  // Feed states
  bool _followingFeedEnabled = true;
  bool _forYouFeedEnabled = true;
  bool _latestFeedEnabled = true;
  bool _disableVideoBackgroundBlur = false;
  FeedType _selectedFeedType = FeedType.forYou;
  bool _disableNsfwContent = true;

  // Getters
  bool get followingFeedEnabled => _followingFeedEnabled;
  bool get forYouFeedEnabled => _forYouFeedEnabled;
  bool get latestFeedEnabled => _latestFeedEnabled;
  bool get disableVideoBackgroundBlur => _disableVideoBackgroundBlur;
  FeedType get selectedFeedType => _selectedFeedType;
  bool get disableNsfwContent => _disableNsfwContent;

  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _followingFeedEnabled = prefs.getBool(_keyFollowingFeed) ?? true;
      _forYouFeedEnabled = prefs.getBool(_keyForYouFeed) ?? true;
      _latestFeedEnabled = prefs.getBool(_keyLatestFeed) ?? true;
      _disableVideoBackgroundBlur = prefs.getBool(_keyDisableBlur) ?? false;
      _selectedFeedType = FeedType.values[prefs.getInt(_keySelectedFeed) ?? FeedType.forYou.value];
      _disableNsfwContent = prefs.getBool(_keyDisableNsfwContent) ?? true;

      // Make sure selected feed is enabled
      if (!isSelectedFeedEnabled()) {
        selectFirstEnabledFeed();
      }
      notifyListeners();
    } catch (e) {
      // If preferences fail to load, use defaults
      resetToDefaults();
    }
  }

  Future<void> savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyFollowingFeed, _followingFeedEnabled);
      await prefs.setBool(_keyForYouFeed, _forYouFeedEnabled);
      await prefs.setBool(_keyLatestFeed, _latestFeedEnabled);
      await prefs.setBool(_keyDisableBlur, _disableVideoBackgroundBlur);
      await prefs.setInt(_keySelectedFeed, _selectedFeedType.value);
      await prefs.setBool(_keyDisableNsfwContent, _disableNsfwContent);
      notifyListeners();
    } catch (e) {
      // Silently handle preference save errors
    }
  }

  void resetToDefaults() {
    _followingFeedEnabled = true;
    _forYouFeedEnabled = true;
    _latestFeedEnabled = true;
    _disableVideoBackgroundBlur = false;
    _selectedFeedType = FeedType.forYou;
    notifyListeners();
  }

  bool isSelectedFeedEnabled() {
    return _selectedFeedType == FeedType.following
        ? _followingFeedEnabled
        : _selectedFeedType == FeedType.forYou
        ? _forYouFeedEnabled
        : _latestFeedEnabled;
  }

  void selectFirstEnabledFeed() {
    if (_followingFeedEnabled) {
      _selectedFeedType = FeedType.following;
    } else if (_forYouFeedEnabled) {
      _selectedFeedType = FeedType.forYou;
    } else if (_latestFeedEnabled) {
      _selectedFeedType = FeedType.latest;
    } else {
      // If somehow all feeds are disabled, enable For You
      _forYouFeedEnabled = true;
      _selectedFeedType = FeedType.forYou;
    }
    notifyListeners();
  }

  bool canDisableFeed(String settingType) {
    // Get the number of active feeds (excluding the one being toggled)
    final int activeFeeds = (_followingFeedEnabled ? 1 : 0) + (_forYouFeedEnabled ? 1 : 0) + (_latestFeedEnabled ? 1 : 0);

    // Don't allow disabling if it's the last enabled feed
    if (activeFeeds <= 1) return false;

    // Don't allow disabling the currently selected feed
    final feedTypeIndex = getFeedTypeFromSetting(settingType);
    return feedTypeIndex != _selectedFeedType.value;
  }

  Future<void> toggleFeed(String settingType, bool isEnabled) async {
    if (!isEnabled && !canDisableFeed(settingType)) {
      return;
    }

    switch (settingType) {
      case 'following_feed':
        _followingFeedEnabled = isEnabled;
        break;
      case 'for_you_feed':
        _forYouFeedEnabled = isEnabled;
        break;
      case 'latest_feed':
        _latestFeedEnabled = isEnabled;
        break;
    }

    await savePreferences();
    notifyListeners();
  }

  Future<void> setBackgroundBlur(bool disabled) async {
    _disableVideoBackgroundBlur = disabled;
    await savePreferences();
    notifyListeners();
  }

  Future<void> setSelectedFeedType(FeedType feedType) async {
    _selectedFeedType = feedType;
    await savePreferences();
    notifyListeners();
  }

  int getFeedTypeFromSetting(String settingType) {
    switch (settingType) {
      case 'following_feed':
        return FeedType.following.value;
      case 'for_you_feed':
        return FeedType.forYou.value;
      case 'latest_feed':
        return FeedType.latest.value;
      default:
        return FeedType.forYou.value;
    }
  }
}
