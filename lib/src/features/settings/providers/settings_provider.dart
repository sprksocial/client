import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/pref_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/storage/preferences/default_preferences.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/settings/providers/settings_state.dart';

part 'settings_provider.g.dart';

/// Provider for the PrefRepository instance
@riverpod
PrefRepository prefRepository(Ref ref) {
  return GetIt.instance<PrefRepository>();
}

/// StateNotifier for managing settings state
@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  late final PrefRepository _prefRepository;
  late final FeedRepository _feedRepository;
  late final SQLCacheInterface _sqlCache;
  late final SparkLogger _logger;
  late final Feed _defaultFeed;

  @override
  SettingsState build() {
    _prefRepository = ref.watch(prefRepositoryProvider);
    _feedRepository = GetIt.instance<SprkRepository>().feed;
    _sqlCache = GetIt.instance<SQLCacheInterface>();
    _logger = GetIt.instance<LogService>().getLogger('Settings');
    _defaultFeed = Feed(
      type: 'timeline',
      config: SavedFeed(type: 'timeline', value: 'following', pinned: true),
    );

    // Load settings asynchronously but return a temporary state immediately
    // This prevents blocking the UI while loading
    Future.microtask(loadSettings);

    // Return temporary default state that will be replaced by loadSettings()
    return SettingsState(
      activeFeed: _defaultFeed,
    );
  }

  /// Loads all settings from server preferences
  Future<void> loadSettings() async {
    try {
      _logger.d('Loading settings from server...');
      final preferences = await _prefRepository.getPreferences();
      final savedFeeds = _getSavedFeedsFromPreferences(preferences);

      // If there are no feeds, set default preferences
      if (savedFeeds.isEmpty) {
        try {
          final defaultPrefs = DefaultPreferences.defaultPreferences;
          await _prefRepository.putPreferences(defaultPrefs);

          // Reload preferences after setting defaults
          final updatedPreferences = await _prefRepository.getPreferences();
          final updatedSavedFeeds = _getSavedFeedsFromPreferences(updatedPreferences);
          final updatedFeeds = await _feedRepository.getFeedsFromSavedFeeds(updatedSavedFeeds);
          final updatedActiveFeed = _getActiveFeedFromFeeds(updatedFeeds, updatedSavedFeeds);
          final updatedPostToBskyEnabled = _getPostToBskyEnabledFromPreferences(updatedPreferences);

          state = SettingsState(
            activeFeed: updatedActiveFeed,
            feeds: updatedFeeds,
            postToBskyEnabled: updatedPostToBskyEnabled,
          );
          return;
        } catch (e) {
          _logger.e('Error setting default preferences: $e');
          // Continue with default feed if setting defaults fails
        }
      }

      // Hydrate feeds with generator views using getFeedGenerators
      final feeds = await _feedRepository.getFeedsFromSavedFeeds(savedFeeds);
      final activeFeed = _getActiveFeedFromFeeds(feeds, savedFeeds);
      final postToBskyEnabled = _getPostToBskyEnabledFromPreferences(preferences);

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
    await _setPostToBskyEnabled(value);
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

  /// Updates preferences with new feeds list
  Future<void> _updateFeedsInPreferences(List<Feed> feeds) async {
    try {
      final preferences = await _prefRepository.getPreferences();
      final updatedPreferences = preferences.preferences.where((pref) => !pref.isSavedFeedsPref(pref)).toList();
      updatedPreferences.add(Preference.savedFeedsPref(items: feeds.map((feed) => feed.config).toList()));
      await _prefRepository.putPreferences(Preferences(preferences: updatedPreferences));
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
      await _sqlCache.cacheFeed(feed);
      state = state.copyWith(feeds: updatedFeeds);
    }
  }

  /// Removes a feed from feeds list
  Future<void> removeFeed(Feed feed) async {
    final updatedFeeds = state.feeds.where((f) => f.config.id != feed.config.id).toList();
    await _updateFeedsInPreferences(updatedFeeds);
    await _sqlCache.deleteFeed(feed);
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
    await _setActiveFeedInPreferences(feed);
    state = state.copyWith(activeFeed: feed);
  }

  /// Debug method to reload settings and verify persistence
  Future<void> reloadSettingsForTesting() async {
    _logger.d('Manually reloading settings for testing...');
    await loadSettings();
  }

  // Helper methods for working with Preferences

  List<SavedFeed> _getSavedFeedsFromPreferences(Preferences preferences) {
    // Extract feeds from the preferences list (fromJson doesn't populate savedFeeds)
    final savedFeeds = <SavedFeed>[];
    for (final pref in preferences.preferences) {
      pref.mapOrNull(
        savedFeedsPref: (savedFeedsPref) {
          savedFeeds.addAll(savedFeedsPref.items);
        },
      );
    }
    return savedFeeds;
  }

  Feed _getActiveFeedFromFeeds(List<Feed> feeds, List<SavedFeed> savedFeeds) {
    SavedFeed? activeSavedFeed;
    try {
      activeSavedFeed = savedFeeds.firstWhere((feed) => feed.pinned);
    } catch (e) {
      if (savedFeeds.isNotEmpty) {
        activeSavedFeed = savedFeeds.first;
      }
    }
    if (activeSavedFeed == null) {
      return _defaultFeed;
    }
    // Find the corresponding hydrated feed
    try {
      return feeds.firstWhere((feed) => feed.config.id == activeSavedFeed!.id);
    } catch (e) {
      // Fallback to creating feed without view if not found
      return Feed(
        type: activeSavedFeed.type,
        config: activeSavedFeed,
      );
    }
  }

  bool _getPostToBskyEnabledFromPreferences(Preferences preferences) {
    final postInteractionPref = preferences.preferences.firstWhere(
      (pref) => pref.isPostInteractionSettingsPref(pref),
      orElse: () => const Preference.postInteractionSettingsPref(enabled: false),
    );
    return postInteractionPref.mapOrNull(
          postInteractionSettingsPref: (pref) => pref.enabled,
        ) ??
        false;
  }

  Future<void> _setPostToBskyEnabled(bool value) async {
    final preferences = await _prefRepository.getPreferences();
    final updatedPreferences = preferences.preferences.where((pref) => !pref.isPostInteractionSettingsPref(pref)).toList();
    updatedPreferences.add(Preference.postInteractionSettingsPref(enabled: value));
    await _prefRepository.putPreferences(Preferences(preferences: updatedPreferences));
  }

  Future<void> _setActiveFeedInPreferences(Feed feed) async {
    final preferences = await _prefRepository.getPreferences();
    // Extract feeds from the preferences list (fromJson doesn't populate savedFeeds)
    final currentFeeds = <SavedFeed>[];
    for (final pref in preferences.preferences) {
      pref.mapOrNull(
        savedFeedsPref: (savedFeedsPref) {
          currentFeeds.addAll(savedFeedsPref.items);
        },
      );
    }

    final updatedFeeds = currentFeeds.map((f) => f.copyWith(pinned: f.id == feed.config.id)).toList();
    if (!updatedFeeds.any((f) => f.id == feed.config.id)) {
      updatedFeeds.add(feed.config.copyWith(pinned: true));
    }
    final updatedPreferences = preferences.preferences.where((pref) => !pref.isSavedFeedsPref(pref)).toList();
    updatedPreferences.add(Preference.savedFeedsPref(items: updatedFeeds));
    await _prefRepository.putPreferences(Preferences(preferences: updatedPreferences));
  }

  // Public methods for other providers to use

  Future<List<String>> getLabelers() async {
    final preferences = await _prefRepository.getPreferences();
    final labelers = preferences.labelers?.map((labeler) => labeler.did).toList() ?? [];
    if (!labelers.contains('did:plc:pbgyr67hftvpoqtvaurpsctc')) {
      labelers.add('did:plc:pbgyr67hftvpoqtvaurpsctc');
    }
    return labelers;
  }

  Future<LabelPreference> getLabelPreference(String value) async {
    final preferences = await _prefRepository.getPreferences();
    final contentLabelPrefs = preferences.contentLabelPrefs ?? [];
    final contentLabelPref = contentLabelPrefs.firstWhere(
      (pref) => pref.label == value,
      orElse: () => throw Exception('Label preference not found'),
    );
    return LabelPreference(
      value: contentLabelPref.label,
      blurs: _visibilityToBlurs(contentLabelPref.visibility),
      severity: _visibilityToSeverity(contentLabelPref.visibility),
      defaultSetting: _visibilityToSetting(contentLabelPref.visibility),
      setting: _visibilityToSetting(contentLabelPref.visibility),
      adultOnly: _isAdultOnlyLabel(value),
    );
  }

  Future<void> setLabelPreference(String value, Blurs blurs, Severity severity, bool adultOnly, Setting setting) async {
    final preferences = await _prefRepository.getPreferences();
    final updatedPreferences = preferences.preferences.where((pref) => !pref.isContentLabelPref(pref)).toList();
    final existingContentPrefs = preferences.contentLabelPrefs ?? [];
    for (final pref in existingContentPrefs) {
      if (pref.label == value) {
        updatedPreferences.add(
          Preference.contentLabelPref(
            labelerDid: pref.labelerDid,
            label: value,
            visibility: _settingToVisibility(setting),
          ),
        );
      } else {
        updatedPreferences.add(
          Preference.contentLabelPref(
            labelerDid: pref.labelerDid,
            label: pref.label,
            visibility: pref.visibility,
          ),
        );
      }
    }
    if (!existingContentPrefs.any((pref) => pref.label == value)) {
      updatedPreferences.add(
        Preference.contentLabelPref(
          labelerDid: 'did:plc:pbgyr67hftvpoqtvaurpsctc',
          label: value,
          visibility: _settingToVisibility(setting),
        ),
      );
    }
    await _prefRepository.putPreferences(Preferences(preferences: updatedPreferences));
  }

  Future<Feed> getActiveFeed() async {
    final preferences = await _prefRepository.getPreferences();
    final savedFeeds = _getSavedFeedsFromPreferences(preferences);
    final feeds = await _feedRepository.getFeedsFromSavedFeeds(savedFeeds);
    return _getActiveFeedFromFeeds(feeds, savedFeeds);
  }

  // Helper conversion methods

  String _settingToVisibility(Setting setting) {
    switch (setting) {
      case Setting.ignore:
        return 'ignore';
      case Setting.warn:
        return 'warn';
      case Setting.hide:
        return 'hide';
    }
  }

  Setting _visibilityToSetting(String visibility) {
    switch (visibility) {
      case 'ignore':
        return Setting.ignore;
      case 'warn':
        return Setting.warn;
      case 'hide':
        return Setting.hide;
      default:
        return Setting.ignore;
    }
  }

  Blurs _visibilityToBlurs(String visibility) {
    switch (visibility) {
      case 'ignore':
        return Blurs.none;
      case 'warn':
        return Blurs.media;
      case 'hide':
        return Blurs.content;
      default:
        return Blurs.none;
    }
  }

  Severity _visibilityToSeverity(String visibility) {
    switch (visibility) {
      case 'ignore':
        return Severity.none;
      case 'warn':
        return Severity.alert;
      case 'hide':
        return Severity.alert;
      default:
        return Severity.none;
    }
  }

  bool _isAdultOnlyLabel(String label) {
    const adultOnlyLabels = {
      'porn',
      'sexual',
      'nsfl',
    };
    return adultOnlyLabels.contains(label);
  }
}
