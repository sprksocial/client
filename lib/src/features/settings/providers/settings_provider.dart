import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';
import 'package:sparksocial/src/core/storage/preferences/settings_repository.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/settings/providers/settings_state.dart';

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
  late final StorageManager _storageManager;
  late final SparkLogger _logger;

  @override
  SettingsState build() {
    _repository = ref.watch(settingsRepositoryProvider);
    _storageManager = GetIt.instance<StorageManager>();
    _logger = GetIt.instance<LogService>().getLogger('Settings');

    // Load settings asynchronously but return a temporary state immediately
    // This prevents blocking the UI while loading
    Future.microtask(loadSettings);

    // Return temporary default state that will be replaced by loadSettings()
    return SettingsState(
      activeFeed: Feed(
        type: 'timeline',
        config: SavedFeed(type: 'timeline', value: 'timeline', pinned: true),
      ),
    );
  }

  /// Loads all settings from persistent storage
  Future<void> loadSettings() async {
    try {
      _logger.d('Loading settings from storage...');

      // Sync preferences from server (this also saves to local storage)
      await _repository.getPreferences();

      // Read from local storage
      final postToBskyEnabled = await _storageManager.preferences.getBool(StorageKeys.postToBskyKey) ?? false;

      // Read feeds from storage
      final feedsJson = await _storageManager.preferences.getObject<List<Map<String, dynamic>>>(StorageKeys.feedsKey);
      final feeds = feedsJson?.map(Feed.fromJson).toList() ?? [];

      // Read active feed from storage
      final activeFeedJson = await _storageManager.preferences.getObject<Map<String, dynamic>>(StorageKeys.activeFeedKey);
      final activeFeed = activeFeedJson != null
          ? Feed.fromJson(activeFeedJson)
          : (feeds.isNotEmpty
                ? feeds.first
                : Feed(
                    type: 'timeline',
                    config: SavedFeed(type: 'timeline', value: 'timeline', pinned: true),
                  ));

      _logger.d(
        'Settings loaded - activeFeed: ${activeFeed.config.value}, feeds: ${feeds.map((f) => f.config.value).join(', ')}',
      );

      state = SettingsState(
        activeFeed: activeFeed,
        feeds: feeds,
        postToBskyEnabled: postToBskyEnabled,
      );

      _logger.d('Settings state updated successfully');
    } catch (e) {
      // If loading fails, keep the default state
      _logger.e('Error loading settings: $e');
    }
  }

  /// Sets Post to Bluesky setting
  Future<void> setPostToBsky(bool value) async {
    await _storageManager.preferences.setBool(StorageKeys.postToBskyKey, value);
    state = state.copyWith(postToBskyEnabled: value);
  }

  /// Syncs all preferences from server
  ///
  /// This method should be called:
  /// - When the user logs in (to get server preferences)
  /// - When entering the app (to sync any changes from other devices)
  /// - Manually from the settings UI if user wants to refresh preferences
  Future<void> syncPreferencesFromServer() async {
    try {
      await loadSettings();
      _logger.d('Preferences synced successfully');
    } catch (e) {
      _logger.e('Error syncing preferences from server: $e');
    }
  }

  /// Converts a Feed to a SavedFeed
  SavedFeed _feedToSavedFeed(Feed feed) {
    return feed.config;
  }

  /// Updates preferences with new feeds list
  Future<void> _updateFeedsInPreferences(List<Feed> feeds) async {
    try {
      // Get current preferences
      final preferences = await _repository.getPreferences();

      // Convert feeds to SavedFeeds
      final savedFeeds = feeds.map(_feedToSavedFeed).toList();

      // Find existing savedFeedsPref or create new one
      final existingPrefs = preferences.preferences;
      final updatedPrefs = <Preference>[];

      var foundSavedFeedsPref = false;
      for (final pref in existingPrefs) {
        if (pref.mapOrNull(savedFeedsPref: (_) => true) ?? false) {
          updatedPrefs.add(Preference.savedFeedsPref(items: savedFeeds));
          foundSavedFeedsPref = true;
        } else {
          updatedPrefs.add(pref);
        }
      }

      if (!foundSavedFeedsPref) {
        updatedPrefs.add(Preference.savedFeedsPref(items: savedFeeds));
      }

      // Update preferences
      await _repository.putPreferences(Preferences(preferences: updatedPrefs));

      // Update local storage
      final feedsJson = feeds.map((feed) => feed.toJson()).toList();
      await _storageManager.preferences.setObject<List<Map<String, dynamic>>>(StorageKeys.feedsKey, feedsJson);
    } catch (e) {
      _logger.e('Error updating feeds in preferences: $e');
      rethrow;
    }
  }

  /// Adds a feed to feeds list
  Future<void> addFeed(Feed feed) async {
    if (!state.feeds.any((f) => f.config.id == feed.config.id)) {
      final updatedFeeds = [...state.feeds, feed];
      await _updateFeedsInPreferences(updatedFeeds);
      state = state.copyWith(feeds: updatedFeeds);
    }
  }

  /// Removes a feed from feeds list
  Future<void> removeFeed(Feed feed) async {
    final updatedFeeds = state.feeds.where((f) => f.config.id != feed.config.id).toList();
    await _updateFeedsInPreferences(updatedFeeds);
    state = state.copyWith(feeds: updatedFeeds);
  }

  /// Reorders a feed in feeds list
  Future<void> reorderFeed(int oldIndex, int newIndex) async {
    var actualNewIndex = newIndex;
    if (newIndex == state.feeds.length) {
      actualNewIndex = state.feeds.length - 1;
    }
    final updatedList = [...state.feeds];
    final feed = updatedList.removeAt(oldIndex);
    updatedList.insert(actualNewIndex, feed);
    await _updateFeedsInPreferences(updatedList);
    state = state.copyWith(feeds: updatedList);
  }

  /// Sets selected feed index
  Future<void> setActiveFeed(Feed feed) async {
    await _storageManager.preferences.setObject<Map<String, dynamic>>(StorageKeys.activeFeedKey, feed.toJson());
    state = state.copyWith(activeFeed: feed);
  }

  /// Debug method to reload settings and verify persistence
  Future<void> reloadSettingsForTesting() async {
    _logger.d('Manually reloading settings for testing...');
    await loadSettings();
  }
}
