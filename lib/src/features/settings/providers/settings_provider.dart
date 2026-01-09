import 'dart:convert';

import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/pref_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/storage/preferences/default_preferences.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/settings/providers/settings_state.dart';

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
  late final SprkRepository _sprkRepository;
  late final SparkLogger _logger;
  late final Feed _defaultFeed;

  String get _defaultModServiceDid {
    // Extract DID part from modDid (remove fragment if present)
    final modDid = _sprkRepository.modDid;
    return modDid.split('#').first;
  }

  @override
  SettingsState build() {
    _prefRepository = ref.watch(prefRepositoryProvider);
    _sprkRepository = GetIt.instance<SprkRepository>();
    _feedRepository = _sprkRepository.feed;
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
          final modServiceDid = _defaultModServiceDid;
          final defaultPrefs = DefaultPreferences.defaultPreferences(
            modServiceDid: modServiceDid,
          );
          await _prefRepository.putPreferences(defaultPrefs);

          // Reload preferences after setting defaults
          final updatedPreferences = await _prefRepository.getPreferences();
          final updatedSavedFeeds = _getSavedFeedsFromPreferences(
            updatedPreferences,
          );
          final updatedFeeds = await _feedRepository.getFeedsFromSavedFeeds(
            updatedSavedFeeds,
          );
          final updatedActiveFeed = _getActiveFeedFromFeeds(
            updatedFeeds,
            updatedSavedFeeds,
          );

          // Update liked feeds based on viewer state
          final likedFeeds = updatedFeeds
              .where((feed) => feed.view?.viewer?.like != null)
              .toList();

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

      _logger.d('Settings state updated successfully');
    } catch (e) {
      _logger.e('Error loading settings: $e');
    }
  }

  /// Likes a feed generator
  Future<void> likeFeed(Feed feed) async {
    if (feed.view != null) {
      final likeRef = await _feedRepository.likePost(
        feed.view!.cid,
        feed.view!.uri,
      );

      // Update the feed with the like information
      final updatedFeed = Feed(
        type: feed.type,
        config: feed.config,
        view: feed.view?.copyWith(
          viewer:
              feed.view!.viewer?.copyWith(like: likeRef.uri) ??
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

      state = state.copyWith(
        feeds: updatedFeeds,
        likedFeeds: likedFeeds,
      );

      await _updateFeedsInPreferences(updatedFeeds);
    }
  }

  /// Unlikes a feed generator
  Future<void> unlikeFeed(Feed feed) async {
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
      final updatedFeeds = state.feeds
          .map((f) => f.config.id == updatedFeed.config.id ? updatedFeed : f)
          .toList();

      // Remove from liked feeds
      final likedFeeds = state.likedFeeds
          .where((f) => f.config.id != updatedFeed.config.id)
          .toList();

      state = state.copyWith(
        feeds: updatedFeeds,
        likedFeeds: likedFeeds,
      );

      await _updateFeedsInPreferences(updatedFeeds);
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
    final preferences = await _prefRepository.getPreferences();
    final updatedPreferences = preferences.preferences
        .where((pref) => !pref.isSavedFeedsPref(pref))
        .toList();
    updatedPreferences.add(
      Preference.savedFeedsPref(
        items: feeds.map((feed) => feed.config).toList(),
      ),
    );
    await _prefRepository.putPreferences(
      Preferences(preferences: updatedPreferences),
    );
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
      state = state.copyWith(feeds: updatedFeeds);
    }
  }

  /// Removes a feed from feeds list
  Future<void> removeFeed(Feed feed) async {
    // Prevent deletion of the Following feed
    if (feed.type == 'timeline' && feed.config.value == 'following') {
      _logger.w('Attempted to delete the Following feed, which is not allowed');
      throw Exception('Cannot delete the Following feed');
    }

    final updatedFeeds = state.feeds
        .where((f) => f.config.id != feed.config.id)
        .toList();
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
    // Extract feeds from preferences (fromJson doesn't populate savedFeeds)
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
    var labelers =
        preferences.labelers?.map((labeler) => labeler.did).toList() ?? [];

    // Ensure default mod service labeler is always present
    final modServiceDid = _defaultModServiceDid;
    final wasAdded = !labelers.contains(modServiceDid);
    if (wasAdded) {
      _logger.d('Default mod service labeler not found, adding it');
      labelers = [modServiceDid, ...labelers];

      // Update preferences to include default labeler
      final updatedLabelers = <LabelerPrefItem>[
        LabelerPrefItem(did: modServiceDid),
        ...(preferences.labelers ?? []),
      ];
      final updatedPreferences = preferences.preferences
          .where((pref) => !pref.isLabelersPref(pref))
          .toList();
      updatedPreferences.add(
        Preference.labelersPref(labelers: updatedLabelers),
      );

      await _prefRepository.putPreferences(
        Preferences(preferences: updatedPreferences),
      );
    }

    // Ensure all labelers' label values are set as preferences
    // Do this asynchronously to avoid blocking
    Future.microtask(() => _ensureAllLabelersPoliciesSet(labelers));

    return labelers;
  }

  /// Ensures all label values from all subscribed labelers have preferences set
  Future<void> _ensureAllLabelersPoliciesSet(List<String> labelerDids) async {
    for (final did in labelerDids) {
      try {
        await _fetchLabelerPoliciesAndSetDefaults(did);
      } catch (e) {
        _logger.w('Error ensuring label values for labeler $did: $e');
      }
    }
  }

  /// Adds a labeler to the user's subscribed labelers list
  Future<void> addLabeler(String did) async {
    try {
      _logger.d('Adding labeler: $did');
      final preferences = await _prefRepository.getPreferences();
      final currentLabelers = preferences.labelers ?? [];

      // Check if labeler already exists
      if (currentLabelers.any((labeler) => labeler.did == did)) {
        _logger.w('Labeler already exists: $did');
        return;
      }

      // Create updated preferences with new labeler
      final updatedLabelers = [...currentLabelers, LabelerPrefItem(did: did)];
      final updatedPreferences = preferences.preferences
          .where((pref) => !pref.isLabelersPref(pref))
          .toList();
      updatedPreferences.add(
        Preference.labelersPref(labelers: updatedLabelers),
      );

      await _prefRepository.putPreferences(
        Preferences(preferences: updatedPreferences),
      );
      _logger.d('Labeler added successfully: $did');

      // Fetch and set default label preferences for this labeler
      await _fetchLabelerPoliciesAndSetDefaults(did);
    } catch (e) {
      _logger.e('Error adding labeler: $e');
      rethrow;
    }
  }

  /// Removes a labeler from the user's subscribed labelers list
  Future<void> removeLabeler(String did) async {
    try {
      // Prevent removal of default mod service labeler
      if (did == _defaultModServiceDid) {
        _logger.w(
          'Attempted to remove default mod service labeler, '
          'which is not allowed',
        );
        throw Exception('Cannot remove the default mod service labeler');
      }

      _logger.d('Removing labeler: $did');
      final preferences = await _prefRepository.getPreferences();
      final currentLabelers = preferences.labelers ?? [];

      // Remove the labeler
      final updatedLabelers = currentLabelers
          .where((labeler) => labeler.did != did)
          .toList();

      // Create updated preferences
      final updatedPreferences = preferences.preferences
          .where((pref) => !pref.isLabelersPref(pref))
          .toList();
      updatedPreferences.add(
        Preference.labelersPref(labelers: updatedLabelers),
      );

      await _prefRepository.putPreferences(
        Preferences(preferences: updatedPreferences),
      );
      _logger.d('Labeler removed successfully: $did');
    } catch (e) {
      _logger.e('Error removing labeler: $e');
      rethrow;
    }
  }

  /// Syncs labelers from server (useful for manual refresh)
  Future<void> syncLabelers() async {
    try {
      _logger.d('Syncing labelers from server...');
      // Fetch fresh preferences
      final preferences = await _prefRepository.getPreferences();
      final labelers =
          preferences.labelers?.map((labeler) => labeler.did).toList() ?? [];

      // Ensure default mod service labeler is present
      final modServiceDid = _defaultModServiceDid;
      if (!labelers.contains(modServiceDid)) {
        labelers.insert(0, modServiceDid);
        final updatedLabelers = <LabelerPrefItem>[
          LabelerPrefItem(did: modServiceDid),
          ...(preferences.labelers ?? []),
        ];
        final updatedPreferences = preferences.preferences
            .where((pref) => !pref.isLabelersPref(pref))
            .toList();
        updatedPreferences.add(
          Preference.labelersPref(labelers: updatedLabelers),
        );
        await _prefRepository.putPreferences(
          Preferences(preferences: updatedPreferences),
        );
      }

      _logger.d(
        'Syncing label value preferences for ${labelers.length} labelers',
      );

      // Ensure all labelers' label values are set as preferences
      await _ensureAllLabelersPoliciesSet(labelers);

      _logger.d('Labelers synced successfully');
    } catch (e) {
      _logger.e('Error syncing labelers: $e');
      rethrow;
    }
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

  Future<void> setLabelPreference(
    String value,
    Blurs blurs,
    Severity severity,
    bool adultOnly,
    Setting setting,
  ) async {
    final preferences = await _prefRepository.getPreferences();
    final updatedPreferences = preferences.preferences
        .where((pref) => !pref.isContentLabelPref(pref))
        .toList();
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
          labelerDid: _defaultModServiceDid,
          label: value,
          visibility: _settingToVisibility(setting),
        ),
      );
    }
    await _prefRepository.putPreferences(
      Preferences(preferences: updatedPreferences),
    );
  }

  /// Gets label preferences for a specific labeler
  Future<Map<String, LabelPreference>> getLabelPreferencesForLabeler(
    String labelerDid,
  ) async {
    final preferences = await _prefRepository.getPreferences();

    // Get content label preferences from the main preferences list
    final contentLabelPrefsMap = <String, String>{}; // label -> visibility
    for (final pref in preferences.preferences) {
      final contentLabelPref = pref.mapOrNull(contentLabelPref: (p) => p);
      if (contentLabelPref != null &&
          contentLabelPref.labelerDid == labelerDid) {
        contentLabelPrefsMap[contentLabelPref.label] =
            contentLabelPref.visibility;
      }
    }

    // Also check contentLabelPrefs property
    final contentLabelPrefsFromProperty = preferences.contentLabelPrefs ?? [];
    for (final pref in contentLabelPrefsFromProperty) {
      final prefLabelerDid = pref.labelerDid;
      final prefLabel = pref.label;
      final prefVisibility = pref.visibility;
      if (prefLabelerDid == labelerDid &&
          !contentLabelPrefsMap.containsKey(prefLabel)) {
        contentLabelPrefsMap[prefLabel] = prefVisibility;
      }
    }

    final result = <String, LabelPreference>{};
    for (final entry in contentLabelPrefsMap.entries) {
      final label = entry.key;
      final visibility = entry.value;

      // Get the actual saved setting from visibility
      final setting = _visibilityToSetting(visibility);

      // For blur, we need to infer it from the setting
      // If setting is 'warn', default to media blur, otherwise none
      final blurs = setting == Setting.warn ? Blurs.media : Blurs.none;

      result[label] = LabelPreference(
        value: label,
        blurs: blurs,
        severity: _visibilityToSeverity(visibility),
        defaultSetting: setting, // TODO: should come from label definitions
        setting: setting,
        adultOnly: _isAdultOnlyLabel(label),
      );
    }
    return result;
  }

  /// Sets label preference for a specific labeler
  Future<void> setLabelPreferenceForLabeler(
    String labelerDid,
    String value,
    Blurs blurs,
    Severity severity,
    bool adultOnly,
    Setting setting,
  ) async {
    final preferences = await _prefRepository.getPreferences();

    // Get all non-content-label preferences
    final updatedPreferences = preferences.preferences
        .where((pref) => !pref.isContentLabelPref(pref))
        .toList();

    // Get all existing content label preferences from preferences
    final existingContentLabelPreferences = preferences.preferences
        .where((pref) => pref.isContentLabelPref(pref))
        .toList();

    // Track if we found the preference to update
    var found = false;

    // Preserve all other content label prefs & update the one we're changing
    for (final pref in existingContentLabelPreferences) {
      final contentLabelPref = pref.mapOrNull(contentLabelPref: (p) => p);
      if (contentLabelPref != null) {
        if (contentLabelPref.labelerDid == labelerDid &&
            contentLabelPref.label == value) {
          // Update this specific preference
          updatedPreferences.add(
            Preference.contentLabelPref(
              labelerDid: labelerDid,
              label: value,
              visibility: _settingToVisibility(setting),
            ),
          );
          found = true;
        } else {
          // Keep other preferences as-is
          updatedPreferences.add(pref);
        }
      }
    }

    // If preference doesn't exist, add it
    if (!found) {
      updatedPreferences.add(
        Preference.contentLabelPref(
          labelerDid: labelerDid,
          label: value,
          visibility: _settingToVisibility(setting),
        ),
      );
    }

    await _prefRepository.putPreferences(
      Preferences(preferences: updatedPreferences),
    );
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

  /// Fetches labeler policies and sets default content label preferences
  /// for label values that don't already have preferences
  Future<void> _fetchLabelerPoliciesAndSetDefaults(String did) async {
    try {
      final rawResponse = await _sprkRepository.executeWithRetry(() async {
        if (!_sprkRepository.authRepository.isAuthenticated) {
          throw Exception('Not authenticated');
        }
        final atproto = _sprkRepository.authRepository.atproto;
        if (atproto == null) {
          throw Exception('AtProto not initialized');
        }
        final result = await atproto.get(
          NSID.parse('so.sprk.labeler.getServices'),
          parameters: {
            'dids': [did],
            'detailed': true,
          },
          headers: {'atproto-proxy': _sprkRepository.sprkDid},
          to: (jsonMap) => jsonMap,
          adaptor: (uint8) =>
              jsonDecode(utf8.decode(uint8 as List<int>))
                  as Map<String, dynamic>,
        );
        if (result.status != HttpStatus.ok) {
          throw Exception('Failed to retrieve labeler services');
        }
        return result.data as Map<String, dynamic>;
      });

      final viewsJson = rawResponse['views'] as List<dynamic>?;
      if (viewsJson == null || viewsJson.isEmpty) {
        return;
      }

      final viewJson = viewsJson.first as Map<String, dynamic>;
      final policiesJson = viewJson['policies'] as Map<String, dynamic>?;

      if (policiesJson == null) {
        return;
      }

      final labelValuesJson = policiesJson['labelValues'] as List<dynamic>?;
      if (labelValuesJson == null || labelValuesJson.isEmpty) {
        return;
      }

      final labelValues = labelValuesJson.map((v) => v as String).toList();

      final labelValueDefinitionsJson =
          policiesJson['labelValueDefinitions'] as List<dynamic>?;
      final labelDefinitionMap = <String, Map<String, dynamic>>{};
      if (labelValueDefinitionsJson != null) {
        for (final defJson in labelValueDefinitionsJson) {
          final def = defJson as Map<String, dynamic>;
          final identifier = def['identifier'] as String?;
          if (identifier != null) {
            labelDefinitionMap[identifier] = def;
          }
        }
      }

      final preferences = await _prefRepository.getPreferences();

      // Get all existing content label preferences from both sources
      final existingContentLabelPreferences = preferences.preferences
          .where((pref) => pref.isContentLabelPref(pref))
          .toList();
      final existingContentPrefsFromProperty =
          preferences.contentLabelPrefs ?? [];

      // Build a map of existing preferences by labelerDid:label
      final existingPrefsMap =
          <String, String>{}; // "labelerDid:label" -> "visibility"
      for (final pref in existingContentLabelPreferences) {
        final contentLabelPref = pref.mapOrNull(contentLabelPref: (p) => p);
        if (contentLabelPref != null) {
          existingPrefsMap['${contentLabelPref.labelerDid}:'
                  '${contentLabelPref.label}'] =
              contentLabelPref.visibility;
        }
      }
      for (final pref in existingContentPrefsFromProperty) {
        final key = '${pref.labelerDid}:${pref.label}';
        if (!existingPrefsMap.containsKey(key)) {
          existingPrefsMap[key] = pref.visibility;
        }
      }

      final preferencesToAdd = <Preference>[];

      for (final labelValue in labelValues) {
        final key = '$did:$labelValue';
        final hasExistingPref = existingPrefsMap.containsKey(key);

        if (!hasExistingPref) {
          String defaultVisibility;
          final definition = labelDefinitionMap[labelValue];
          if (definition != null) {
            defaultVisibility =
                definition['defaultSetting'] as String? ?? 'warn';
          } else {
            defaultVisibility = _getDefaultVisibilityForLabel(labelValue);
          }

          preferencesToAdd.add(
            Preference.contentLabelPref(
              labelerDid: did,
              label: labelValue,
              visibility: defaultVisibility,
            ),
          );
        }
      }

      if (preferencesToAdd.isNotEmpty) {
        // Preserve all existing preferences and add new ones
        final updatedPreferences = [
          ...preferences.preferences.where(
            (pref) => !pref.isContentLabelPref(pref),
          ),
          ...existingContentLabelPreferences,
          ...preferencesToAdd,
        ];
        await _prefRepository.putPreferences(
          Preferences(preferences: updatedPreferences),
        );
      }
    } catch (e) {
      _logger.e('Error fetching labeler policies for $did: $e');
    }
  }

  /// Determines default visibility setting for a label value
  String _getDefaultVisibilityForLabel(String labelValue) {
    // Use similar logic to LabelSettingsPage._createDefaultLabelPreference
    switch (labelValue) {
      case '!hide':
      case 'dmca-violation':
        return 'hide';
      case '!no-promote':
        return 'hide';
      case '!warn':
      case 'doxxing':
      case 'porn':
      case 'sexual':
      case 'nsfl':
      case 'gore':
        return 'warn';
      case '!no-unauthenticated':
        return 'ignore';
      case 'nudity':
        return 'ignore';
      default:
        // For unknown labels, default to warn
        return 'warn';
    }
  }
}
