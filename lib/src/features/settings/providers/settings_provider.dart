import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/storage/preferences/settings_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/settings/providers/settings_state.dart';
import 'package:sparksocial/src/features/settings/ui/pages/profile_settings_page.dart';

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
  late final SparkLogger _logger;

  @override
  SettingsState build() {
    _repository = ref.watch(settingsRepositoryProvider);
    _logger = GetIt.instance<LogService>().getLogger('Settings');

    // Load settings asynchronously but return a temporary state immediately
    // This prevents blocking the UI while loading
    Future.microtask(loadSettings);

    // Return temporary default state that will be replaced by loadSettings()
    return const SettingsState(
      activeFeed: Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.latestSprk),
    );
  }

  /// Loads all settings from persistent storage
  Future<void> loadSettings() async {
    try {
      _logger.d('Loading settings from storage...');

      final feedBlurEnabled = await _repository.getFeedBlurEnabled();
      final hideAdultContent = await _repository.getHideAdultContent();
      final followMode = await _repository.getFollowMode();
      final feeds = await _repository.getFeeds();
      final activeFeed = await _repository.getActiveFeed();
      final postToBskyEnabled = await _repository.getPostToBskyEnabled();

      _logger.d(
        'Settings loaded - activeFeed: ${activeFeed.name}, feeds: ${feeds.map((f) => f.name).join(', ')}, followMode: $followMode',
      );

      state = SettingsState(
        activeFeed: activeFeed,
        feedBlurEnabled: feedBlurEnabled,
        hideAdultContent: hideAdultContent,
        followMode: followMode,
        feeds: feeds,
        postToBskyEnabled: postToBskyEnabled,
      );

      _logger.d('Settings state updated successfully');
    } catch (e) {
      // If loading fails, keep the default state
      _logger.e('Error loading settings: $e');
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

  /// Sets follow mode setting
  Future<void> setFollowMode(FollowMode followMode) async {
    await _repository.setFollowModeWithSync(followMode);
    state = state.copyWith(followMode: followMode);
  }

  /// Sets Post to Bluesky setting
  Future<void> setPostToBsky(bool value) async {
    await _repository.setPostToBskyEnabled(value);
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
      _logger.d('Syncing preferences from server...');
      await _repository.syncFollowModeFromServer();

      // Reload settings to get updated values
      await loadSettings();
      _logger.d('Preferences synced successfully');
    } catch (e) {
      _logger.e('Error syncing preferences from server: $e');
    }
  }

  /// Adds a feed to feeds list
  Future<void> addFeed(Feed feed) async {
    if (!state.feeds.contains(feed)) {
      await _repository.addFeed(feed);
      state = state.copyWith(feeds: [...state.feeds, feed]);
    }
  }

  /// Removes a feed from feeds list
  Future<void> removeFeed(Feed feed) async {
    await _repository.removeFeed(feed);
    state = state.copyWith(feeds: state.feeds.where((f) => f != feed).toList());
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
    await _repository.setFeeds(updatedList);
    state = state.copyWith(feeds: updatedList);
  }

  /// Sets selected feed index
  Future<void> setActiveFeed(Feed feed) async {
    await _repository.setActiveFeed(feed);
    state = state.copyWith(activeFeed: feed);
  }

  /// Debug method to reload settings and verify persistence
  Future<void> reloadSettingsForTesting() async {
    _logger.d('Manually reloading settings for testing...');
    await loadSettings();
  }
}
