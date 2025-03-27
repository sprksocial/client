import 'package:shared_preferences/shared_preferences.dart';

class FeedType {
  static const int following = 0;
  static const int forYou = 1;
  static const int latest = 2;
}

class FeedSettingsService {
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

  // Feed states
  bool _followingFeedEnabled = true;
  bool _forYouFeedEnabled = true;
  bool _latestFeedEnabled = true;
  bool _disableVideoBackgroundBlur = false;
  int _selectedFeedType = FeedType.forYou;

  // Getters
  bool get followingFeedEnabled => _followingFeedEnabled;
  bool get forYouFeedEnabled => _forYouFeedEnabled;
  bool get latestFeedEnabled => _latestFeedEnabled;
  bool get disableVideoBackgroundBlur => _disableVideoBackgroundBlur;
  int get selectedFeedType => _selectedFeedType;

  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _followingFeedEnabled = prefs.getBool(_keyFollowingFeed) ?? true;
      _forYouFeedEnabled = prefs.getBool(_keyForYouFeed) ?? true;
      _latestFeedEnabled = prefs.getBool(_keyLatestFeed) ?? true;
      _disableVideoBackgroundBlur = prefs.getBool(_keyDisableBlur) ?? false;
      _selectedFeedType = prefs.getInt(_keySelectedFeed) ?? FeedType.forYou;

      // Make sure selected feed is enabled
      if (!isSelectedFeedEnabled()) {
        selectFirstEnabledFeed();
      }
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
      await prefs.setInt(_keySelectedFeed, _selectedFeedType);
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
  }

  bool canDisableFeed(String settingType) {
    // Get the number of active feeds (excluding the one being toggled)
    final int activeFeeds = (_followingFeedEnabled ? 1 : 0) + (_forYouFeedEnabled ? 1 : 0) + (_latestFeedEnabled ? 1 : 0);

    // Don't allow disabling if it's the last enabled feed
    if (activeFeeds <= 1) return false;

    // Don't allow disabling the currently selected feed
    final feedTypeIndex = getFeedTypeFromSetting(settingType);
    return feedTypeIndex != _selectedFeedType;
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
  }

  Future<void> setBackgroundBlur(bool disabled) async {
    _disableVideoBackgroundBlur = disabled;
    await savePreferences();
  }

  Future<void> setSelectedFeedType(int feedType) async {
    _selectedFeedType = feedType;
    await savePreferences();
  }

  int getFeedTypeFromSetting(String settingType) {
    switch (settingType) {
      case 'following_feed':
        return FeedType.following;
      case 'for_you_feed':
        return FeedType.forYou;
      case 'latest_feed':
        return FeedType.latest;
      default:
        return FeedType.forYou;
    }
  }

  String getFeedNameFromType(int feedType) {
    switch (feedType) {
      case FeedType.following:
        return 'Following';
      case FeedType.forYou:
        return 'For You';
      case FeedType.latest:
        return 'Latest';
      default:
        return 'For You';
    }
  }
}
