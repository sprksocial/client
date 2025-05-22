import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/label_preference.dart';
import '../data/models/settings_state.dart';
import '../data/repositories/settings_repository.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

part 'settings_provider.g.dart';

/// Provider for the SettingsRepository instance
@riverpod
SettingsRepository settingsRepository(Ref ref) {
  return GetIt.instance<SettingsRepository>();
}

/// StateNotifier for managing settings state
@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  late final SettingsRepository _repository;

  @override
  SettingsState build() {
    _repository = ref.watch(settingsRepositoryProvider);
    _loadSettings();
    return const SettingsState(isLoading: true);
  }

  /// Loads all settings from persistent storage
  Future<void> _loadSettings() async {
    final feedBlurEnabled = await _repository.getFeedBlurEnabled();
    final hideAdultContent = await _repository.getHideAdultContent();
    final followedLabelers = await _repository.getFollowedLabelers();
    final labelPreferences = await _repository.getLabelPreferences();

    // Load new feed settings
    final followingFeedEnabled = await _repository.getFollowingFeedEnabled();
    final forYouFeedEnabled = await _repository.getForYouFeedEnabled();
    final latestFeedEnabled = await _repository.getLatestFeedEnabled();
    final selectedFeedType = await _repository.getSelectedFeedType();

    state = state.copyWith(
      feedBlurEnabled: feedBlurEnabled,
      hideAdultContent: hideAdultContent,
      followedLabelers: followedLabelers,
      labelPreferences: labelPreferences,
      followingFeedEnabled: followingFeedEnabled,
      forYouFeedEnabled: forYouFeedEnabled,
      latestFeedEnabled: latestFeedEnabled,
      selectedFeedType: selectedFeedType,
      isLoading: false,
    );

    // Make sure selected feed is enabled
    if (!isSelectedFeedEnabled()) {
      await selectFirstEnabledFeed();
    }
  }

  /// Sets feed blur setting
  Future<void> setFeedBlur(bool value) async {
    await _repository.setFeedBlurEnabled(value);
    state = state.copyWith(feedBlurEnabled: value);
  }

  /// Sets adult content visibility setting
  Future<void> setHideAdultContent(bool value) async {
    await _repository.setHideAdultContent(value);
    state = state.copyWith(hideAdultContent: value);
  }

  /// Sets following feed enabled setting
  Future<void> setFollowingFeedEnabled(bool value) async {
    await _repository.setFollowingFeedEnabled(value);
    state = state.copyWith(followingFeedEnabled: value);
  }

  /// Sets for you feed enabled setting
  Future<void> setForYouFeedEnabled(bool value) async {
    await _repository.setForYouFeedEnabled(value);
    state = state.copyWith(forYouFeedEnabled: value);
  }

  /// Sets latest feed enabled setting
  Future<void> setLatestFeedEnabled(bool value) async {
    await _repository.setLatestFeedEnabled(value);
    state = state.copyWith(latestFeedEnabled: value);
  }

  /// Sets selected feed type
  Future<void> setSelectedFeedType(FeedType value) async {
    await _repository.setSelectedFeedType(value);
    state = state.copyWith(selectedFeedType: value);
  }

  /// Checks if the currently selected feed is enabled
  bool isSelectedFeedEnabled() {
    return state.selectedFeedType == FeedType.following
        ? state.followingFeedEnabled
        : state.selectedFeedType == FeedType.forYou
        ? state.forYouFeedEnabled
        : state.latestFeedEnabled;
  }

  /// Selects the first enabled feed
  Future<void> selectFirstEnabledFeed() async {
    FeedType feedType;
    if (state.followingFeedEnabled) {
      feedType = FeedType.following;
    } else if (state.forYouFeedEnabled) {
      feedType = FeedType.forYou;
    } else if (state.latestFeedEnabled) {
      feedType = FeedType.latest;
    } else {
      // If somehow all feeds are disabled, enable For You
      await setForYouFeedEnabled(true);
      feedType = FeedType.forYou;
    }

    if (feedType != state.selectedFeedType) {
      await setSelectedFeedType(feedType);
    }
  }

  /// Checks if a feed can be disabled
  bool canDisableFeed(String settingType) {
    // Get the number of active feeds
    final int activeFeeds =
        (state.followingFeedEnabled ? 1 : 0) + (state.forYouFeedEnabled ? 1 : 0) + (state.latestFeedEnabled ? 1 : 0);

    // Don't allow disabling if it's the last enabled feed
    if (activeFeeds <= 1) return false;

    // Don't allow disabling the currently selected feed
    final feedType = getFeedTypeFromSetting(settingType);
    return feedType != state.selectedFeedType;
  }

  /// Toggles a feed by its setting type
  Future<void> toggleFeed(String settingType, bool isEnabled) async {
    if (!isEnabled && !canDisableFeed(settingType)) {
      return;
    }

    switch (settingType) {
      case 'following_feed':
        await setFollowingFeedEnabled(isEnabled);
        break;
      case 'for_you_feed':
        await setForYouFeedEnabled(isEnabled);
        break;
      case 'latest_feed':
        await setLatestFeedEnabled(isEnabled);
        break;
    }
  }

  /// Gets the feed type from a setting name
  FeedType getFeedTypeFromSetting(String settingType) {
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

  /// Sets followed labelers list
  Future<void> setFollowedLabelers(List<String> labelerDids) async {
    await _repository.setFollowedLabelers(labelerDids);
    state = state.copyWith(followedLabelers: labelerDids);
  }

  /// Adds a labeler to followed labelers list
  Future<void> addFollowedLabeler(String labelerDid) async {
    if (!state.followedLabelers.contains(labelerDid)) {
      final updatedList = [...state.followedLabelers, labelerDid];
      await _repository.setFollowedLabelers(updatedList);
      state = state.copyWith(followedLabelers: updatedList);
    }
  }

  /// Removes a labeler from followed labelers list
  Future<void> removeFollowedLabeler(String labelerDid) async {
    if (state.followedLabelers.contains(labelerDid)) {
      final updatedList = state.followedLabelers.where((id) => id != labelerDid).toList();
      await _repository.setFollowedLabelers(updatedList);

      // Also remove preferences for this labeler
      await _repository.clearLabelerPreferences(labelerDid);

      // Update state
      final updatedPrefs = Map<String, Map<String, String>>.from(state.labelPreferences);
      updatedPrefs.remove(labelerDid);

      state = state.copyWith(followedLabelers: updatedList, labelPreferences: updatedPrefs);
    }
  }

  /// Sets a preference for a specific label from a labeler
  Future<void> setLabelPreference(String labelerDid, String labelValue, LabelPreference preference) async {
    await _repository.setLabelPreference(labelerDid, labelValue, preference);

    // Update the state
    final updatedPrefs = Map<String, Map<String, String>>.from(state.labelPreferences);
    updatedPrefs[labelerDid] ??= {};
    updatedPrefs[labelerDid]![labelValue] = preference.name;

    state = state.copyWith(labelPreferences: updatedPrefs);
  }

  /// Removes a preference for a specific label, reverting to the default
  Future<void> removeLabelPreference(String labelerDid, String labelValue) async {
    await _repository.removeLabelPreference(labelerDid, labelValue);

    // Update the state
    if (state.labelPreferences.containsKey(labelerDid)) {
      final updatedPrefs = Map<String, Map<String, String>>.from(state.labelPreferences);
      updatedPrefs[labelerDid]?.remove(labelValue);

      state = state.copyWith(labelPreferences: updatedPrefs);
    }
  }

  /// Sets preferences in bulk for all labels from a labeler
  Future<void> setLabelerPreferences(String labelerDid, Map<String, LabelPreference> preferences) async {
    // Convert the map of enums to strings
    final stringPrefs = preferences.map((key, value) => MapEntry(key, value.name));

    // Create a new map with the updated preferences
    final updatedPrefs = Map<String, Map<String, String>>.from(state.labelPreferences);
    updatedPrefs[labelerDid] = stringPrefs;

    // Update repository
    await _repository.saveLabelPreferences(updatedPrefs);

    // Update state
    state = state.copyWith(labelPreferences: updatedPrefs);
  }

  /// Clears all preferences for a specific labeler
  Future<void> clearLabelerPreferences(String labelerDid) async {
    await _repository.clearLabelerPreferences(labelerDid);

    // Update state
    if (state.labelPreferences.containsKey(labelerDid)) {
      final updatedPrefs = Map<String, Map<String, String>>.from(state.labelPreferences);
      updatedPrefs.remove(labelerDid);

      state = state.copyWith(labelPreferences: updatedPrefs);
    }
  }
}

/// Convenience extension methods to get label preferences
extension SettingsLabelPreferences on SettingsState {
  /// Gets the preference for a specific label from a labeler
  /// Returns null if no preference is defined
  LabelPreference? getLabelPreference(String labelerDid, String labelValue) {
    if (isLoading || !labelPreferences.containsKey(labelerDid)) {
      return null;
    }

    final prefValue = labelPreferences[labelerDid]?[labelValue];
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
}
