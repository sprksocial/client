import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/pref_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/pref_repository.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/storage/preferences/settings_repository.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl() {
    _sqlCache = GetIt.instance<SQLCacheInterface>();
    _storageManager = GetIt.instance<StorageManager>();
    _logger = GetIt.instance<LogService>().getLogger('SettingsRepository');
    _prefRepository = GetIt.instance<PrefRepository>();
    _defaultFeed = Feed(
      type: 'timeline',
      config: SavedFeed(type: 'timeline', value: 'following', pinned: true),
    );
    _setupDefaultLabelPreferences();
  }
  late final SQLCacheInterface _sqlCache;
  late final StorageManager _storageManager;
  late final SparkLogger _logger;
  late final PrefRepository _prefRepository;
  late final Feed _defaultFeed;

  Future<void> _setupDefaultLabelPreferences() async {
    if (await _storageManager.preferences.getObject<bool>(StorageKeys.defaultLabelsAreSetupKey) ?? false) {
      return;
    } else {
      await _storageManager.preferences.setObject<bool>(StorageKeys.defaultLabelsAreSetupKey, true);
      // "!hide",
      // "!no-promote",
      // "!warn",
      // "!no-unauthenticated",
      // "dmca-violation",
      // "doxxing",
      // "porn",
      // "sexual",
      // "nudity",
      // "nsfl",
      // "gore",
      await _storageManager.preferences.setObject<Map<String, dynamic>>(
        '${StorageKeys.labelPreferenceKey}_!hide',
        LabelPreference(
          value: '!hide',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.hide,
          setting: Setting.hide,
          adultOnly: false,
        ).toJson(),
      );
      await _storageManager.preferences.setObject<Map<String, dynamic>>(
        '${StorageKeys.labelPreferenceKey}_!no-promote',
        LabelPreference(
          value: '!no-promote',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.hide,
          setting: Setting.hide,
          adultOnly: false,
        ).toJson(),
      );
      await _storageManager.preferences.setObject<Map<String, dynamic>>(
        '${StorageKeys.labelPreferenceKey}_!warn',
        LabelPreference(
          value: '!warn',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.warn,
          setting: Setting.warn,
          adultOnly: false,
        ).toJson(),
      );
      await _storageManager.preferences.setObject<Map<String, dynamic>>(
        '${StorageKeys.labelPreferenceKey}_!no-unauthenticated',
        LabelPreference(
          value: '!no-unauthenticated',
          blurs: Blurs.none,
          severity: Severity.none,
          defaultSetting: Setting.ignore,
          setting: Setting.ignore,
          adultOnly: false,
        ).toJson(),
      );
      await _storageManager.preferences.setObject<Map<String, dynamic>>(
        '${StorageKeys.labelPreferenceKey}_dmca-violation',
        LabelPreference(
          value: 'dmca-violation',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.hide,
          setting: Setting.hide,
          adultOnly: false,
        ).toJson(),
      );
      await _storageManager.preferences.setObject<Map<String, dynamic>>(
        '${StorageKeys.labelPreferenceKey}_doxxing',
        LabelPreference(
          value: 'doxxing',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.warn,
          setting: Setting.warn,
          adultOnly: false,
        ).toJson(),
      );
      await _storageManager.preferences.setObject<Map<String, dynamic>>(
        '${StorageKeys.labelPreferenceKey}_porn',
        LabelPreference(
          value: 'porn',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.warn,
          setting: Setting.warn,
          adultOnly: true,
        ).toJson(),
      );
      await _storageManager.preferences.setObject<Map<String, dynamic>>(
        '${StorageKeys.labelPreferenceKey}_sexual',
        LabelPreference(
          value: 'sexual',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.warn,
          setting: Setting.warn,
          adultOnly: true,
        ).toJson(),
      );
      await _storageManager.preferences.setObject<Map<String, dynamic>>(
        '${StorageKeys.labelPreferenceKey}_nudity',
        LabelPreference(
          value: 'nudity',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.warn,
          setting: Setting.warn,
          adultOnly: false,
        ).toJson(),
      );
      await _storageManager.preferences.setObject<Map<String, dynamic>>(
        '${StorageKeys.labelPreferenceKey}_nsfl',
        LabelPreference(
          value: 'nsfl',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.warn,
          setting: Setting.warn,
          adultOnly: true,
        ).toJson(),
      );
      await _storageManager.preferences.setObject<Map<String, dynamic>>(
        '${StorageKeys.labelPreferenceKey}_gore',
        LabelPreference(
          value: 'gore',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.warn,
          setting: Setting.warn,
          adultOnly: true,
        ).toJson(),
      );
    }
  }

  @override
  Future<void> setFeeds(List<Feed> feeds) async {
    _logger.d('Saving feeds: ${feeds.map((f) => f.config.id).join(', ')}');
    
    try {
      final preferences = await getPreferences();
      
      // Remove existing saved feeds preference
      final updatedPreferences = preferences.preferences
          .where((pref) => !pref.isSavedFeedsPref(pref))
          .toList();
      
      // Add new saved feeds preference
      updatedPreferences.add(Preference.savedFeedsPref(items: feeds.map((feed) => feed.config).toList()));
      
      final newPreferences = Preferences(preferences: updatedPreferences);
      await putPreferences(newPreferences);
      
      _logger.d('Feeds saved successfully');
    } catch (e) {
      _logger.e('Error saving feeds: $e');
      rethrow;
    }
  }

  @override
  Future<List<Feed>> getFeeds() async {
    _logger.d('Loading feeds from preferences...');
    
    try {
      final preferences = await getPreferences();
      final savedFeedPref = preferences.savedFeeds;
      
      if (savedFeedPref == null || savedFeedPref.isEmpty) {
        _logger.d('No feeds found in preferences');
        return [];
      }
      
      final feeds = savedFeedPref.map((savedFeed) => Feed(
        type: savedFeed.type,
        config: savedFeed,
      )).toList();
      
      _logger.d('Loaded feeds from preferences: ${feeds.map((f) => f.config.id).join(', ')}');
      return feeds;
    } catch (e) {
      _logger.e('Error loading feeds: $e');
      return [];
    }
  }

  @override
  Future<Feed> getActiveFeed() async {
    _logger.d('Loading active feed from preferences...');
    
    try {
      final preferences = await getPreferences();
      final feeds = preferences.savedFeeds ?? [];
      
      // Find the first pinned feed, or the first feed if none are pinned
      SavedFeed? activeSavedFeed;
      try {
        activeSavedFeed = feeds.firstWhere((feed) => feed.pinned);
      } catch (e) {
        if (feeds.isNotEmpty) {
          activeSavedFeed = feeds.first;
        }
      }
      
      if (activeSavedFeed == null) {
        _logger.d('No active feed found in preferences, using default (Latest)');
        return _defaultFeed;
      }

      final activeFeed = Feed(
        type: activeSavedFeed.type,
        config: activeSavedFeed,
      );
      
      _logger.d('Loaded active feed from preferences: ${activeFeed.config.id}');
      return activeFeed;
    } catch (e) {
      _logger.e('Error loading active feed: $e');
      return _defaultFeed;
    }
  }

  @override
  Future<void> setActiveFeed(Feed feed) async {
    _logger.d('Setting active feed: ${feed.config.id}');
    
    try {
      final preferences = await getPreferences();
      final currentFeeds = preferences.savedFeeds ?? [];
      
      // Update the pinned status - unpin all feeds, then pin the selected one
      final updatedFeeds = currentFeeds.map((f) => 
        f.copyWith(pinned: f.id == feed.config.id)
      ).toList();
      
      // If the feed doesn't exist, add it as pinned
      if (!updatedFeeds.any((f) => f.id == feed.config.id)) {
        updatedFeeds.add(feed.config.copyWith(pinned: true));
      }
      
      // Remove existing saved feeds preference and add new one
      final updatedPreferences = preferences.preferences
          .where((pref) => !pref.isSavedFeedsPref(pref))
          .toList();
      
      updatedPreferences.add(Preference.savedFeedsPref(items: updatedFeeds));
      
      final newPreferences = Preferences(preferences: updatedPreferences);
      await putPreferences(newPreferences);
      
      _logger.d('Active feed set successfully');
    } catch (e) {
      _logger.e('Error setting active feed: $e');
      rethrow;
    }
  }

  @override
  Future<void> addFeed(Feed feed) async {
    _logger.d('Adding feed: ${feed.config.id}');
    
    try {
      final feeds = await getFeeds();
      await setFeeds([...feeds, feed]);
      await _sqlCache.cacheFeed(feed);
      _logger.d('Feed added successfully');
    } catch (e) {
      _logger.e('Error adding feed: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeFeed(Feed feed) async {
    _logger.d('Removing feed: ${feed.config.id}');
    
    try {
      final feeds = await getFeeds();
      await setFeeds(feeds.where((f) => f.config.id != feed.config.id).toList());
      await _sqlCache.deleteFeed(feed);
      _logger.d('Feed removed successfully');
    } catch (e) {
      _logger.e('Error removing feed: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> getLabelers() async {
    _logger.d('Loading labelers from preferences...');
    
    try {
      final preferences = await getPreferences();
      final labelers = preferences.labelers?.map((labeler) => labeler.did).toList() ?? [];
      
      // Ensure mod.sprk.team is always included
      if (!labelers.contains('did:plc:pbgyr67hftvpoqtvaurpsctc')) {
        labelers.add('did:plc:pbgyr67hftvpoqtvaurpsctc');
      }
      
      _logger.d('Loaded labelers: ${labelers.join(', ')}');
      return labelers;
    } catch (e) {
      _logger.e('Error loading labelers: $e');
      // Return default labeler on error
      return ['did:plc:pbgyr67hftvpoqtvaurpsctc'];
    }
  }

  @override
  Future<void> setLabelers(List<String> labelers, List<LabelPreference> labelPreferences) async {
    _logger.d('Saving labelers: ${labelers.join(', ')}');
    
    try {
      final preferences = await getPreferences();
      
      // Ensure mod.sprk.team is always included
      if (!labelers.contains('did:plc:pbgyr67hftvpoqtvaurpsctc')) {
        labelers.add('did:plc:pbgyr67hftvpoqtvaurpsctc');
      }
      
      // Remove existing labelers and content label preferences
      final updatedPreferences = preferences.preferences
          .where((pref) => !pref.isLabelersPref(pref) && !pref.isContentLabelPref(pref))
          .toList();
      
      // Add new labelers preference
      updatedPreferences.add(Preference.labelersPref(
        labelers: labelers.map((did) => LabelerPrefItem(did: did)).toList(),
      ));
      
      // Add content label preferences
      for (final labelPreference in labelPreferences) {
        updatedPreferences.add(Preference.contentLabelPref(
          labelerDid: 'did:plc:pbgyr67hftvpoqtvaurpsctc', // Default to mod.sprk.team
          label: labelPreference.value,
          visibility: _settingToVisibility(labelPreference.setting),
        ));
      }
      
      final newPreferences = Preferences(preferences: updatedPreferences);
      await putPreferences(newPreferences);
      
      _logger.d('Labelers saved successfully');
    } catch (e) {
      _logger.e('Error saving labelers: $e');
      rethrow;
    }
  }

  @override
  Future<LabelPreference> getLabelPreference(String value) async {
    _logger.d('Loading label preference: $value');
    
    try {
      final preferences = await getPreferences();
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
    } catch (e) {
      _logger.e('Error loading label preference for $value: $e');
      throw Exception('Failed to load label preference');
    }
  }

  @override
  Future<void> setLabelPreference(String value, Blurs blurs, Severity severity, bool adultOnly, Setting setting) async {
    _logger.d('Saving label preference: $value');
    
    try {
      final preferences = await getPreferences();
      
      // Remove existing content label preferences
      final updatedPreferences = preferences.preferences
          .where((pref) => !pref.isContentLabelPref(pref))
          .toList();
      
      // Add all content label preferences (including the updated one)
      final existingContentPrefs = preferences.contentLabelPrefs ?? [];
      for (final pref in existingContentPrefs) {
        if (pref.label == value) {
          // Update the specific preference
          updatedPreferences.add(Preference.contentLabelPref(
            labelerDid: pref.labelerDid,
            label: value,
            visibility: _settingToVisibility(setting),
          ));
        } else {
          // Keep other preferences as-is
          updatedPreferences.add(Preference.contentLabelPref(
            labelerDid: pref.labelerDid,
            label: pref.label,
            visibility: pref.visibility,
          ));
        }
      }
      
      // If the preference didn't exist before, add it
      if (!existingContentPrefs.any((pref) => pref.label == value)) {
        updatedPreferences.add(Preference.contentLabelPref(
          labelerDid: 'did:plc:pbgyr67hftvpoqtvaurpsctc', // Default to mod.sprk.team
          label: value,
          visibility: _settingToVisibility(setting),
        ));
      }
      
      final newPreferences = Preferences(preferences: updatedPreferences);
      await putPreferences(newPreferences);
      
      _logger.d('Label preference saved successfully: $value');
    } catch (e) {
      _logger.e('Error saving label preference for $value: $e');
      rethrow;
    }
  }

  @override
  Future<bool> getPostToBskyEnabled() async {
    _logger.d('Loading post to Bluesky enabled status');
    
    try {
      final preferences = await getPreferences();
      final postInteractionPref = preferences.preferences.firstWhere(
        (pref) => pref.isPostInteractionSettingsPref(pref),
        orElse: () => const Preference.postInteractionSettingsPref(enabled: false),
      );
      
      final enabled = postInteractionPref.mapOrNull(
        postInteractionSettingsPref: (pref) => pref.enabled,
      ) ?? false;
      
      _logger.d('Post to Bluesky enabled: $enabled');
      return enabled;
    } catch (e) {
      _logger.e('Error loading post to Bluesky enabled status: $e');
      return false;
    }
  }

  @override
  Future<void> setPostToBskyEnabled(bool value) async {
    _logger.d('Setting post to Bluesky enabled: $value');
    
    try {
      final preferences = await getPreferences();
      
      // Remove existing post interaction settings preference
      final updatedPreferences = preferences.preferences
          .where((pref) => !pref.isPostInteractionSettingsPref(pref))
          .toList();
      
      // Add new post interaction settings preference
      updatedPreferences.add(Preference.postInteractionSettingsPref(enabled: value));
      
      final newPreferences = Preferences(preferences: updatedPreferences);
      await putPreferences(newPreferences);
      
      _logger.d('Post to Bluesky enabled status saved successfully');
    } catch (e) {
      _logger.e('Error saving post to Bluesky enabled status: $e');
      rethrow;
    }
  }

  @override
  Future<Preferences> getPreferences() async {
    _logger.d('Getting preferences from server...');
    try {
      final preferences = await _prefRepository.getPreferences();

      await _storageManager.preferences.setObject<Map<String, dynamic>>(
        StorageKeys.preferencesKey,
        preferences.toJson(),
      );

      _logger.d('Preferences fetched from server and saved to memory');
      return preferences;
    } catch (e) {
      _logger.e('Error fetching preferences from server: $e');

      final cachedPreferencesJson = await _storageManager.preferences.getObject<Map<String, dynamic>>(
        StorageKeys.preferencesKey,
      );

      if (cachedPreferencesJson != null) {
        _logger.d('Returning cached preferences from memory');
        return Preferences.fromJson(cachedPreferencesJson);
      }

      _logger.e('No cached preferences found, returning empty preferences');
      return Preferences(preferences: []);
    }
  }

  @override
  Future<void> putPreferences(Preferences preferences) async {
    _logger.d('Putting preferences to server...');
    try {
      await _prefRepository.putPreferences(preferences);

      await _storageManager.preferences.setObject<Map<String, dynamic>>(
        StorageKeys.preferencesKey,
        preferences.toJson(),
      );

      _logger.d('Preferences saved to server and memory');
    } catch (e) {
      _logger.e('Error saving preferences to server: $e');
      rethrow;
    }
  }

  // Helper methods for converting between preference models
  
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
