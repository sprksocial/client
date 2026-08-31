import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/pref_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/storage/preferences/default_preferences.dart';
import 'package:spark/src/core/storage/preferences/storage_manager.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/core/providers/preferences_provider.dart';
import 'package:spark/src/features/settings/providers/labeler_settings_controller.dart';
import 'package:spark/src/features/settings/providers/settings_state.dart';

part 'settings_provider.g.dart';

class SavedFeedsUnavailableException implements Exception {
  const SavedFeedsUnavailableException();

  @override
  String toString() => 'Could not load the current saved feeds';
}

/// Provider for the PrefRepository instance
@riverpod
PrefRepository prefRepository(Ref ref) {
  return GetIt.instance<PrefRepository>();
}

/// StateNotifier for managing settings state
@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  FeedRepository? _feedRepository;
  SprkRepository? _sprkRepository;
  SparkLogger? _logger;
  Feed? _defaultFeed;

  /// Tracks if settings have been loaded to prevent resetting state on rebuild
  bool _hasLoadedSettings = false;

  Future<void>? _settingsOperation;

  bool _createdDefaultFeedsThisSession = false;

  SettingsState? _preservedState;

  FeedRepository get feedRepository =>
      _feedRepository ??= _sprkRepository!.feed;
  SprkRepository get sprkRepository =>
      _sprkRepository ??= GetIt.instance<SprkRepository>();
  SparkLogger get logger =>
      _logger ??= GetIt.instance<LogService>().getLogger('Settings');
  Feed get defaultFeed => _defaultFeed ??= Feed(
    type: 'timeline',
    config: makeSavedFeed(type: 'timeline', value: 'following', pinned: true),
  );

  /// Storage key for the last active feed, unique per user (DID)
  String get _activeFeedStorageKey {
    final did = sprkRepository.authRepository.did ?? 'anonymous';
    return 'active_feed_$did';
  }

  String get _pendingInitialFeedStorageKey {
    final did = sprkRepository.authRepository.did ?? 'anonymous';
    return 'pending_initial_feed_$did';
  }

  String get _defaultModServiceDid {
    // Extract DID part from modDid (remove fragment if present)
    final modDid = sprkRepository.modDid;
    return modDid.split('#').first;
  }

  /// Gets the current preferences from the UserPreferences provider.
  /// This is the single source of truth for preferences.
  Preferences? get _currentPreferences =>
      ref.read(userPreferencesProvider).asData?.value;

  /// Gets preferences, waiting for them to load if necessary.
  /// This is guaranteed to return a non-null value.
  Future<Preferences> _getPreferences() async {
    final current = _currentPreferences;
    if (current != null) return current;
    return ref.read(userPreferencesProvider.future);
  }

  /// Updates preferences through the UserPreferences provider.
  /// This ensures all watchers are notified of changes.
  Future<Preferences> _updatePreferences(
    Preferences Function(Preferences current) updater,
  ) {
    return ref
        .read(userPreferencesProvider.notifier)
        .updatePreferencesWithFn(updater);
  }

  Future<void> _refreshPreferencesForFeedUpdate() async {
    try {
      await ref.read(userPreferencesProvider.notifier).refresh();
      final preferences = _currentPreferences;
      if (preferences == null) {
        throw const SavedFeedsUnavailableException();
      }
    } catch (e, st) {
      logger.e(
        'Cannot update feeds because current saved feeds could not be loaded',
        error: e,
        stackTrace: st,
      );
      throw const SavedFeedsUnavailableException();
    }
  }

  Future<List<Feed>> _updateSavedFeeds(
    List<SavedFeed> Function(List<SavedFeed> currentSavedFeeds) update,
  ) async {
    await _refreshPreferencesForFeedUpdate();
    final updatedPreferences = await _updatePreferences((current) {
      final updatedSavedFeeds = update(
        List<SavedFeed>.of(_getSavedFeedsFromPreferences(current)),
      );
      final updatedPreferencesList =
          current.preferences
              .where((preference) => !preference.isSavedFeedsPref)
              .toList()
            ..add(savedFeedsPreference(updatedSavedFeeds));
      return Preferences(preferences: updatedPreferencesList);
    });
    final updatedSavedFeeds = _getSavedFeedsFromPreferences(updatedPreferences);
    return _loadFeedsFromSavedFeeds(updatedSavedFeeds);
  }

  void _setFeedsState(List<Feed> feeds) {
    final likedFeeds = feeds
        .where((feed) => feed.view?.viewer?.like != null)
        .toList();
    state = state.copyWith(feeds: feeds, likedFeeds: likedFeeds);
  }

  Future<List<Feed>> _loadFeedsFromSavedFeeds(
    List<SavedFeed> savedFeeds,
  ) async {
    try {
      return await feedRepository.getFeedsFromSavedFeeds(savedFeeds);
    } catch (e, st) {
      logger.w(
        'Could not hydrate saved feed details; using saved feed configs',
        error: e,
        stackTrace: st,
      );
      return savedFeeds
          .map(
            (savedFeed) => Feed(type: savedFeed.typeValue, config: savedFeed),
          )
          .toList();
    }
  }

  /// Loads the last active feed from local storage
  /// Returns null if no feed is saved or if loading fails
  Future<Feed?> _loadLastActiveFeedFromStorage() async {
    try {
      final storage = GetIt.instance<StorageManager>().preferences;
      final json = await storage.getObject<Map<String, dynamic>>(
        _activeFeedStorageKey,
      );
      if (json != null) {
        final feed = Feed.fromJson(json);
        logger.d('Loaded saved active feed: ${feed.config.value}');
        return feed;
      }
    } catch (e) {
      logger.w('Error loading saved active feed: $e');
    }
    return null;
  }

  /// Saves the active feed to local storage
  Future<void> _saveActiveFeedToStorage(
    Feed feed, {
    bool rethrowErrors = false,
  }) async {
    try {
      final storage = GetIt.instance<StorageManager>().preferences;
      await storage.setObject(_activeFeedStorageKey, feed.toJson());
      logger.d('Saved active feed to storage: ${feed.config.value}');
    } catch (e, st) {
      logger.w('Error saving active feed', error: e, stackTrace: st);
      if (rethrowErrors) rethrow;
    }
  }

  Future<void> _markInitialFeedSelectionPending() async {
    try {
      final storage = GetIt.instance<StorageManager>().preferences;
      await storage.setBool(_pendingInitialFeedStorageKey, true);
    } catch (e, st) {
      logger.w(
        'Error marking initial feed selection as pending',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<bool> _isInitialFeedSelectionPending() async {
    if (_createdDefaultFeedsThisSession) return true;
    final storage = GetIt.instance<StorageManager>().preferences;
    return await storage.getBool(_pendingInitialFeedStorageKey) ?? false;
  }

  Future<void> _clearInitialFeedSelectionPending() async {
    final storage = GetIt.instance<StorageManager>().preferences;
    await storage.remove(_pendingInitialFeedStorageKey);
    _createdDefaultFeedsThisSession = false;
  }

  @override
  SettingsState build() {
    // Note: We intentionally don't watch userPreferencesProvider here.
    // Watching it causes rebuilds that can race with loadSettings() and
    // reset the state. Instead, we explicitly call syncPreferencesFromServer()
    // when we need to refresh preferences.

    // Preserve state across rebuilds to prevent feeds tabs from disappearing
    listenSelf((previous, next) {
      _preservedState = next;
    });

    // If we've already loaded settings once, preserve the state
    if (_hasLoadedSettings && _preservedState != null) {
      return _preservedState!;
    }

    // Load settings asynchronously but return a temporary state immediately
    // This prevents blocking the UI while loading
    if (!_hasLoadedSettings && _settingsOperation == null) {
      Future.microtask(loadSettings);
    }

    // Return temporary default state that will be replaced by loadSettings()
    return SettingsState(activeFeed: defaultFeed);
  }

  /// Loads all settings from the preferences provider
  Future<void> loadSettings() =>
      _runSettingsOperation(() => _loadSettings(rethrowErrors: false));

  Future<void> _loadSettings({required bool rethrowErrors}) async {
    if (_hasLoadedSettings) {
      logger.d('Settings already loaded, skipping');
      return;
    }

    try {
      logger.d('Loading settings from preferences...');

      // Wait for auth to be initialized before trying to load settings
      final authRepository = sprkRepository.authRepository;
      await authRepository.initializationComplete;

      // Don't load settings if not authenticated - wait for login
      if (!authRepository.isAuthenticated) {
        if (rethrowErrors) {
          throw StateError('Cannot prepare feeds while unauthenticated');
        }
        return;
      }

      // Get preferences from the provider (waits for it to load if needed)
      final preferences = await _getPreferences();
      final savedFeeds = _getSavedFeedsFromPreferences(preferences);

      // If there are no feeds, set default preferences
      if (savedFeeds.isEmpty) {
        try {
          var createdDefaultFeeds = false;
          final modServiceDid = _defaultModServiceDid;
          final defaultPrefs = DefaultPreferences.defaultPreferences(
            modServiceDid: modServiceDid,
          );
          final updatedPreferences = await _updatePreferences((current) {
            if (_getSavedFeedsFromPreferences(current).isNotEmpty) {
              return current;
            }
            createdDefaultFeeds = true;
            return Preferences(
              preferences: [
                ...current.preferences.where(
                  (preference) => !preference.isSavedFeedsPref,
                ),
                ...defaultPrefs.preferences.where((preference) {
                  if (preference.isSavedFeedsPref) return true;
                  if (preference.isLabelersPref) {
                    return current.labelers == null;
                  }
                  if (preference.isContentLabelPref) {
                    return current.contentLabelPrefs == null;
                  }
                  return false;
                }),
              ],
            );
          });

          final updatedSavedFeeds = _getSavedFeedsFromPreferences(
            updatedPreferences,
          );
          final updatedFeeds = await _loadFeedsFromSavedFeeds(
            updatedSavedFeeds,
          );
          final updatedActiveFeed = createdDefaultFeeds
              ? _getPreferredInitialFeed(updatedFeeds)
              : _getActiveFeedFromFeeds(updatedFeeds, updatedSavedFeeds);

          // Update liked feeds based on viewer state
          final likedFeeds = updatedFeeds
              .where((feed) => feed.view?.viewer?.like != null)
              .toList();

          state = SettingsState(
            activeFeed: updatedActiveFeed,
            feeds: updatedFeeds,
            likedFeeds: likedFeeds,
          );
          _hasLoadedSettings = true;

          if (createdDefaultFeeds) {
            _createdDefaultFeedsThisSession = true;
            await _markInitialFeedSelectionPending();
          }

          // Save the default active feed to storage
          await _saveActiveFeedToStorage(updatedActiveFeed);
          return;
        } catch (e, st) {
          logger.e(
            'Error setting default preferences',
            error: e,
            stackTrace: st,
          );
          if (rethrowErrors) rethrow;
          // Continue with default feed if setting defaults fails
        }
      }

      // Hydrate feeds with generator views using getFeedGenerators
      final feeds = await _loadFeedsFromSavedFeeds(savedFeeds);

      // Try to load the last active feed from local storage
      final savedActiveFeed = await _loadLastActiveFeedFromStorage();

      // Determine active feed: use saved feed if it still exists in feeds list,
      // otherwise fall back to server preferences (first pinned)
      final Feed activeFeed;
      if (savedActiveFeed != null &&
          savedActiveFeed.config.pinned &&
          feeds.any((f) => f.config.id == savedActiveFeed.config.id)) {
        activeFeed = feeds.firstWhere(
          (f) => f.config.id == savedActiveFeed.config.id,
        );
        logger.d(
          'Restored last active feed from storage: ${activeFeed.config.value}',
        );
      } else {
        activeFeed = _getActiveFeedFromFeeds(feeds, savedFeeds);
      }

      logger.d(
        'Settings loaded - activeFeed: ${activeFeed.config.value}, '
        'feeds: ${feeds.map((f) => f.config.value).join(', ')}',
      );

      // Update liked feeds based on viewer state
      final likedFeeds = feeds
          .where((feed) => feed.view?.viewer?.like != null)
          .toList();

      state = SettingsState(
        activeFeed: activeFeed,
        feeds: feeds,
        likedFeeds: likedFeeds,
      );
      _hasLoadedSettings = true;

      logger.d('Settings state updated successfully');
    } catch (e, st) {
      logger.e('Error loading settings', error: e, stackTrace: st);
      if (rethrowErrors) rethrow;
    }
  }

  Future<void> _runSettingsOperation(Future<void> Function() operation) async {
    while (_settingsOperation != null) {
      try {
        await _settingsOperation;
      } catch (_) {
        // The caller that started the operation owns its error. A queued
        // operation should still get an opportunity to run.
      }
    }

    final future = operation();
    _settingsOperation = future;
    try {
      await future;
    } finally {
      if (identical(_settingsOperation, future)) {
        _settingsOperation = null;
      }
    }
  }

  /// Updates whether the current user likes a feed generator.
  Future<void> setFeedLiked(Feed feed, {required bool liked}) async {
    final generator = feed.view;
    if (generator == null || (generator.viewer?.like != null) == liked) {
      return;
    }

    if (liked) {
      final likeRef = await feedRepository.likePost(
        generator.cid,
        generator.uri,
      );

      // Update the feed with the like information
      final updatedFeed = Feed(
        type: feed.type,
        config: feed.config,
        view: generator.copyWith(
          viewer:
              generator.viewer?.copyWith(like: likeRef.uri) ??
              GeneratorViewerState(like: likeRef.uri),
        ),
      );

      // Update feeds list
      final updatedFeeds = state.feeds
          .map((f) => f.config.id == updatedFeed.config.id ? updatedFeed : f)
          .toList();

      // Add to liked feeds if not already there
      final likedFeeds = [...state.likedFeeds];
      if (!likedFeeds.any((f) => f.config.id == updatedFeed.config.id)) {
        likedFeeds.add(updatedFeed);
      }

      state = state.copyWith(feeds: updatedFeeds, likedFeeds: likedFeeds);
      return;
    }

    await feedRepository.unlikePost(generator.viewer!.like!);

    // Update the feed to remove like information
    final updatedFeed = Feed(
      type: feed.type,
      config: feed.config,
      view: generator.copyWith(viewer: generator.viewer!.copyWith(like: null)),
    );

    // Update feeds list
    final updatedFeeds = state.feeds
        .map((f) => f.config.id == updatedFeed.config.id ? updatedFeed : f)
        .toList();

    // Remove from liked feeds
    final likedFeeds = state.likedFeeds
        .where((f) => f.config.id != updatedFeed.config.id)
        .toList();

    state = state.copyWith(feeds: updatedFeeds, likedFeeds: likedFeeds);
  }

  /// Syncs all preferences from server
  ///
  /// This method should be called:
  /// - When the user logs in (to get server preferences)
  /// - When entering the app (to sync any changes from other devices)
  /// - Manually from the settings UI if user wants to refresh preferences
  Future<void> syncPreferencesFromServer() async {
    try {
      await _runSettingsOperation(
        () => _syncPreferencesFromServer(rethrowErrors: false),
      );
      logger.d('Preferences synced successfully');
    } catch (e, st) {
      logger.e(
        'Error syncing preferences from server',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Prepares a deterministic first feed before onboarding enters the app.
  ///
  /// Unlike background preference synchronization, this method reports
  /// failures to its caller. It selects Discover only when this installation
  /// previously created the user's default feeds, preserving established
  /// active-feed choices.
  Future<void> preparePostOnboardingFeed() => _runSettingsOperation(() async {
    await _syncPreferencesFromServer(rethrowErrors: true);
    if (!await _isInitialFeedSelectionPending()) return;

    final initialFeed = _getPreferredInitialFeed(state.feeds);
    state = state.copyWith(activeFeed: initialFeed);
    await _saveActiveFeedToStorage(initialFeed, rethrowErrors: true);
    await _clearInitialFeedSelectionPending();
  });

  Future<void> _syncPreferencesFromServer({required bool rethrowErrors}) async {
    try {
      _hasLoadedSettings = false;
      ref.read(labelerSettingsControllerProvider).resetSessionCache();
      await Future(() async {
        await ref.read(userPreferencesProvider.notifier).refresh();
      });
      await _loadSettings(rethrowErrors: rethrowErrors);
    } catch (e, st) {
      logger.e(
        'Error syncing preferences from server',
        error: e,
        stackTrace: st,
      );
      if (rethrowErrors) rethrow;
    }
  }

  /// Adds a feed to feeds list
  Future<void> addFeed(Feed feed) async {
    final pinnedConfig = feed.config.copyWith(pinned: true);
    final updatedFeeds = await _updateSavedFeeds((currentSavedFeeds) {
      if (currentSavedFeeds.any(
        (savedFeed) => savedFeed.id == pinnedConfig.id,
      )) {
        return currentSavedFeeds;
      }
      return [...currentSavedFeeds, pinnedConfig];
    });

    if (updatedFeeds.any(
      (updatedFeed) => updatedFeed.config.id == pinnedConfig.id,
    )) {
      _setFeedsState(updatedFeeds);
    }
  }

  /// Removes a feed from feeds list
  Future<void> removeFeed(Feed feed) async {
    // Prevent deletion of the Following feed
    if (feed.type == 'timeline' && feed.config.value == 'following') {
      logger.w('Attempted to delete the Following feed, which is not allowed');
      throw Exception('Cannot delete the Following feed');
    }

    final updatedFeeds = await _updateSavedFeeds(
      (currentSavedFeeds) => currentSavedFeeds
          .where((savedFeed) => savedFeed.id != feed.config.id)
          .toList(),
    );
    _setFeedsState(updatedFeeds);
  }

  /// Reorders a feed in feeds list
  Future<void> reorderFeed({
    required String movedFeedId,
    String? beforeFeedId,
  }) async {
    final updatedFeeds = await _updateSavedFeeds((currentSavedFeeds) {
      final movedIndex = currentSavedFeeds.indexWhere(
        (savedFeed) => savedFeed.id == movedFeedId,
      );
      if (movedIndex == -1) {
        throw StateError('Cannot reorder feed that is not saved');
      }

      final updatedList = [...currentSavedFeeds];
      final feed = updatedList.removeAt(movedIndex);
      if (beforeFeedId == null) {
        updatedList.add(feed);
      } else {
        final beforeIndex = updatedList.indexWhere(
          (savedFeed) => savedFeed.id == beforeFeedId,
        );
        if (beforeIndex == -1) {
          throw StateError('Cannot reorder before a feed that is not saved');
        }
        updatedList.insert(beforeIndex, feed);
      }
      return updatedList;
    });
    _setFeedsState(updatedFeeds);
  }

  /// Updates a feed's pinned state without removing and re-adding it.
  Future<void> setFeedPinned(Feed feed, {required bool pinned}) async {
    final updatedFeeds = await _updateSavedFeeds((currentSavedFeeds) {
      return currentSavedFeeds
          .map(
            (savedFeed) => savedFeed.id == feed.config.id
                ? savedFeed.copyWith(pinned: pinned)
                : savedFeed,
          )
          .toList();
    });
    _setFeedsState(updatedFeeds);
  }

  /// Sets selected feed index and saves to local storage
  Future<void> setActiveFeed(Feed feed) async {
    state = state.copyWith(activeFeed: feed);
    await _saveActiveFeedToStorage(feed);
    try {
      await _clearInitialFeedSelectionPending();
    } catch (e, st) {
      logger.w(
        'Error clearing initial feed selection after user choice',
        error: e,
        stackTrace: st,
      );
    }
  }

  // Helper methods for working with Preferences

  List<SavedFeed> _getSavedFeedsFromPreferences(Preferences preferences) {
    // Extract feeds from preferences (fromJson doesn't populate savedFeeds)
    final savedFeeds = <SavedFeed>[];
    for (final pref in preferences.preferences) {
      final savedFeedsPref = pref.savedFeedsPref;
      if (savedFeedsPref != null) {
        savedFeeds.addAll(savedFeedsPref.items);
      }
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
      return defaultFeed;
    }
    // Find the corresponding hydrated feed
    try {
      return feeds.firstWhere((feed) => feed.config.id == activeSavedFeed!.id);
    } catch (e) {
      // Fallback to creating feed without view if not found
      return Feed(type: activeSavedFeed.typeValue, config: activeSavedFeed);
    }
  }

  Feed _getPreferredInitialFeed(List<Feed> feeds) {
    for (final feed in feeds) {
      if (feed.config.pinned &&
          feed.config.value == DefaultPreferences.discoverFeedUri) {
        return feed;
      }
    }
    for (final feed in feeds) {
      if (feed.config.pinned && feed.type != 'timeline') return feed;
    }
    for (final feed in feeds) {
      if (feed.config.pinned) return feed;
    }
    return feeds.isEmpty ? defaultFeed : feeds.first;
  }

  Future<Feed> getActiveFeed() async {
    final preferences = await _getPreferences();
    final savedFeeds = _getSavedFeedsFromPreferences(preferences);
    final feeds = await _loadFeedsFromSavedFeeds(savedFeeds);
    return _getActiveFeedFromFeeds(feeds, savedFeeds);
  }
}
