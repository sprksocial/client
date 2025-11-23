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

          // Update liked feeds based on viewer state
          final likedFeeds = updatedFeeds.where((feed) => feed.view?.viewer?.like != null).toList();

          state = SettingsState(
            activeFeed: updatedActiveFeed,
            feeds: updatedFeeds,
            likedFeeds: likedFeeds,
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

      _logger.d(
        'Settings loaded - activeFeed: ${activeFeed.config.value}, feeds: ${feeds.map((f) => f.config.value).join(', ')}',
      );

      // Update liked feeds based on viewer state
      final likedFeeds = feeds.where((feed) => feed.view?.viewer?.like != null).toList();

      state = SettingsState(
        activeFeed: activeFeed,
        feeds: feeds,
        likedFeeds: likedFeeds,
      );

      _logger.d('Settings state updated successfully');
    } catch (e) {
      _logger.e('Error loading settings: $e');
    }
  }

  /// Likes a feed generator
  Future<void> likeFeed(Feed feed) async {
    try {
      if (feed.view != null) {
        final likeRef = await _feedRepository.likePost(feed.view!.cid, feed.view!.uri);

        // Update the feed with the like information
        final updatedFeed = Feed(
          type: feed.type,
          config: feed.config,
          view: feed.view?.copyWith(
            viewer: feed.view!.viewer?.copyWith(like: likeRef.uri) ?? GeneratorViewerState(like: likeRef.uri),
          ),
        );

        // Update feeds list
        final updatedFeeds = state.feeds.map((f) => f.config.id == updatedFeed.config.id ? updatedFeed : f).toList();

        // Add to liked feeds if not already there
        final likedFeeds = [...state.likedFeeds];
        if (!likedFeeds.any((f) => f.config.id == updatedFeed.config.id)) {
          likedFeeds.add(updatedFeed);
        }

        state = state.copyWith(
          feeds: updatedFeeds,
          likedFeeds: likedFeeds,
        );

        await _updateFeedsInPreferences(updatedFeeds);
      }
    } catch (e) {
      _logger.e('Error liking feed: $e');
      rethrow;
    }
  }

  /// Unlikes a feed generator
  Future<void> unlikeFeed(Feed feed) async {
    try {
      if (feed.view?.viewer?.like != null) {
        await _feedRepository.unlikePost(feed.view!.viewer!.like!);

        // Update the feed to remove like information
        final updatedFeed = Feed(
          type: feed.type,
          config: feed.config,
          view: feed.view?.copyWith(
            viewer: feed.view!.viewer?.copyWith(like: null),
          ),
        );

        // Update feeds list
        final updatedFeeds = state.feeds.map((f) => f.config.id == updatedFeed.config.id ? updatedFeed : f).toList();

        // Remove from liked feeds
        final likedFeeds = state.likedFeeds.where((f) => f.config.id != updatedFeed.config.id).toList();

        state = state.copyWith(
          feeds: updatedFeeds,
          likedFeeds: likedFeeds,
        );

        await _updateFeedsInPreferences(updatedFeeds);
      }
    } catch (e) {
      _logger.e('Error unliking feed: $e');
      rethrow;
    }
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
      // Make all feeds pinned by default
      final pinnedFeed = Feed(
        type: feed.type,
        config: feed.config.copyWith(pinned: true),
        view: feed.view,
      );
      final updatedFeeds = [...state.feeds, pinnedFeed];
      await _updateFeedsInPreferences(updatedFeeds);
      await _sqlCache.cacheFeed(pinnedFeed);
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
    state = state.copyWith(feeds: updatedList);
    await _updateFeedsInPreferences(updatedList);
  }

  /// Sets selected feed index
  Future<void> setActiveFeed(Feed feed) async {
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
