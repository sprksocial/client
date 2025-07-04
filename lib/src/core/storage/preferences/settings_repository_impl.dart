import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/storage/preferences/settings_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/storage/storage.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/settings/ui/pages/profile_settings_page.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  late final SQLCacheInterface _sqlCache;
  late final StorageManager _storageManager;
  late final SparkLogger _logger;
  late final SprkRepository _sprkRepository;

  SettingsRepositoryImpl() {
    _sqlCache = GetIt.instance<SQLCacheInterface>();
    _storageManager = GetIt.instance<StorageManager>();
    _logger = GetIt.instance<LogService>().getLogger('SettingsRepository');
    _sprkRepository = GetIt.instance<SprkRepository>();
    _setupDefaultLabelPreferences();
  }

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
  Future<bool> getFeedBlurEnabled() async {
    return await _storageManager.preferences.getBool(StorageKeys.feedBlurKey) ?? false;
  }

  @override
  Future<void> setFeedBlurEnabled(bool value) async {
    await _storageManager.preferences.setBool(StorageKeys.feedBlurKey, value);
  }

  @override
  Future<bool> getHideAdultContent() async {
    return await _storageManager.preferences.getBool(StorageKeys.hideAdultContentKey) ?? true;
  }

  @override
  Future<void> setHideAdultContent(bool value) async {
    await _storageManager.preferences.setBool(StorageKeys.hideAdultContentKey, value);
  }

  @override
  Future<FollowMode> getFollowMode() async {
    final followModeString = await _storageManager.preferences.getString(StorageKeys.followModeKey);
    return FollowMode.values.firstWhere((mode) => mode.name == followModeString, orElse: () => FollowMode.sprk);
  }

  @override
  Future<void> setFollowMode(FollowMode followMode) async {
    await _storageManager.preferences.setString(StorageKeys.followModeKey, followMode.name);
  }

  @override
  Future<void> setFeeds(List<Feed> feeds) async {
    _logger.d('Saving feeds: ${feeds.map((f) => f.name).join(', ')}');
    // Manually serialize feeds to JSON
    final feedsJson = feeds.map((feed) => feed.toJson()).toList();
    await _storageManager.preferences.setObject<List<Map<String, dynamic>>>(StorageKeys.feedsKey, feedsJson);
    _logger.d('Feeds saved successfully');
  }

  @override
  Future<List<Feed>> getFeeds() async {
    _logger.d('Loading feeds from storage...');
    final feedsJson = await _storageManager.preferences.getObject<List<dynamic>>(StorageKeys.feedsKey);
    if (feedsJson == null) {
      _logger.d('No feeds found in storage, using defaults');
      final defaultFeeds = [
        Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.following),
        Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.forYou),
        Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.latestSprk),
      ];
      await setFeeds(defaultFeeds);
      return defaultFeeds;
    }

    try {
      // Convert the JSON objects back to Feed objects
      final feeds = feedsJson.map((json) => Feed.fromJson(json as Map<String, dynamic>)).toList();
      _logger.d('Loaded feeds from storage: ${feeds.map((f) => f.name).join(', ')}');
      return feeds;
    } catch (e) {
      _logger.e('Error deserializing feeds: $e');
      // If deserialization fails, return defaults
      final defaultFeeds = [
        Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.following),
        Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.forYou),
        Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.latestSprk),
      ];
      await setFeeds(defaultFeeds);
      return defaultFeeds;
    }
  }

  @override
  Future<Feed> getActiveFeed() async {
    _logger.d('Loading active feed from storage...');
    final activeFeedJson = await _storageManager.preferences.getObject<Map<String, dynamic>>(StorageKeys.activeFeedKey);
    if (activeFeedJson == null) {
      _logger.d('No active feed found in storage, using default (Latest)');
      return Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.latestSprk);
    }

    try {
      final activeFeed = Feed.fromJson(activeFeedJson);
      _logger.d('Loaded active feed from storage: ${activeFeed.name}');
      return activeFeed;
    } catch (e) {
      _logger.e('Error deserializing active feed: $e');
      // If deserialization fails, return default
      return Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.latestSprk);
    }
  }

  @override
  Future<void> setActiveFeed(Feed feed) async {
    _logger.d('Saving active feed: ${feed.name}');
    // Manually serialize feed to JSON
    await _storageManager.preferences.setObject<Map<String, dynamic>>(StorageKeys.activeFeedKey, feed.toJson());
    _logger.d('Active feed saved successfully');
  }

  @override
  Future<void> addFeed(Feed feed) async {
    final feeds = await getFeeds();
    await setFeeds([...feeds, feed]);
    await _sqlCache.cacheFeed(feed);
  }

  @override
  Future<void> removeFeed(Feed feed) async {
    final feeds = await getFeeds();
    await setFeeds(feeds.where((f) => f.identifier != feed.identifier).toList());
    await _sqlCache.deleteFeed(feed);
  }

  @override
  Future<List<String>> getFollowedLabelers() async {
    final labelers = await _storageManager.preferences.getObject<List<String>>(StorageKeys.followedLabelers) ?? [];
    if (!labelers.contains('did:plc:pbgyr67hftvpoqtvaurpsctc')) {
      // mod.sprk.team
      labelers.add('did:plc:pbgyr67hftvpoqtvaurpsctc');
    }
    return labelers;
  }

  @override
  Future<void> setFollowedLabelers(List<String> labelers, List<LabelPreference> labelPreferences) async {
    if (!labelers.contains('did:plc:pbgyr67hftvpoqtvaurpsctc')) {
      // mod.sprk.team
      labelers.add('did:plc:pbgyr67hftvpoqtvaurpsctc');
    }
    await _storageManager.preferences.setObject<List<String>>(StorageKeys.followedLabelers, labelers);
    for (var labelPreference in labelPreferences) {
      await _storageManager.preferences.setObject<Map<String, dynamic>>(
        '${StorageKeys.labelPreferenceKey}_${labelPreference.value}',
        labelPreference.toJson(),
      );
    }
  }

  @override
  Future<LabelPreference> getLabelPreference(String value) async {
    final rawJson = await _storageManager.preferences.getObject<Map<String, dynamic>>(
      '${StorageKeys.labelPreferenceKey}_$value',
    );
    if (rawJson == null) {
      throw Exception('Label preference not found');
    }
    
    try {
      return LabelPreference.fromJson(rawJson);
    } catch (e) {
      _logger.e('Error deserializing label preference for $value: $e');
      throw Exception('Failed to deserialize label preference');
    }
  }



  @override
  Future<void> setLabelPreference(String value, Blurs blurs, Severity severity, bool adultOnly, Setting setting) async {
    // Check if a preference already exists
    final existingRawJson = await _storageManager.preferences.getObject<Map<String, dynamic>>(
      '${StorageKeys.labelPreferenceKey}_$value',
    );
    
    if (existingRawJson != null) {
      try {
        // Update existing preference
        final existingPreference = LabelPreference.fromJson(existingRawJson);
        final newLabelPreference = existingPreference.copyWith(
          blurs: blurs,
          severity: severity,
          adultOnly: adultOnly,
          setting: setting,
        );
        await _storageManager.preferences.setObject<Map<String, dynamic>>(
          '${StorageKeys.labelPreferenceKey}_$value',
          newLabelPreference.toJson(),
        );
        _logger.d('Label preference updated: $value');
      } catch (e) {
        _logger.e('Error updating existing label preference for $value: $e');
        // If we can't deserialize existing, create new
        final newLabelPreference = LabelPreference(
          value: value,
          blurs: blurs,
          severity: severity,
          defaultSetting: setting,
          setting: setting,
          adultOnly: adultOnly,
        );
        await _storageManager.preferences.setObject<Map<String, dynamic>>(
          '${StorageKeys.labelPreferenceKey}_$value',
          newLabelPreference.toJson(),
        );
        _logger.d('Label preference created (after error): $value');
      }
    } else {
      // Create new preference
      final newLabelPreference = LabelPreference(
        value: value,
        blurs: blurs,
        severity: severity,
        defaultSetting: setting,
        setting: setting,
        adultOnly: adultOnly,
      );
      await _storageManager.preferences.setObject<Map<String, dynamic>>(
        '${StorageKeys.labelPreferenceKey}_$value',
        newLabelPreference.toJson(),
      );
      _logger.d('Label preference created: $value');
    }
  }

  @override
  Future<void> syncFollowModeFromServer() async {
    try {
      _logger.d('Syncing follow mode from server...');

      if (!_sprkRepository.authRepository.isAuthenticated) {
        _logger.w('Not authenticated, skipping server sync');
        return;
      }

      final preferences = await _sprkRepository.actor.getPreferences();
      final serverFollowMode = FollowMode.values.firstWhere(
        (mode) => mode.name == preferences.followMode,
        orElse: () => FollowMode.sprk,
      );

      // Get current local value to check if it changed
      final currentFollowMode = await getFollowMode();

      if (currentFollowMode != serverFollowMode) {
        _logger.d('Follow mode changed from server: $currentFollowMode -> $serverFollowMode');
        await setFollowMode(serverFollowMode);
      } else {
        _logger.d('Follow mode is in sync with server: $serverFollowMode');
      }
    } catch (e) {
      _logger.w('Failed to sync follow mode from server', error: e);
    }
  }

  @override
  Future<void> setFollowModeWithSync(FollowMode followMode) async {
    try {
      _logger.d('Setting follow mode with sync: $followMode');

      // Set locally first
      await setFollowMode(followMode);

      // Sync with backend if authenticated
      if (_sprkRepository.authRepository.isAuthenticated) {
        final preferences = UserPreferences(followMode: followMode.name);
        await _sprkRepository.actor.putPreferences(preferences);
        _logger.d('Follow mode synced with server successfully');
      } else {
        _logger.w('Not authenticated, follow mode saved locally only');
      }
    } catch (e) {
      _logger.e('Failed to sync follow mode with server', error: e);
      // Keep the local change even if sync fails
      rethrow;
    }
  }

  @override
  Future<bool> getPostToBskyEnabled() async {
    return await _storageManager.preferences.getBool(StorageKeys.postToBskyKey) ?? false;
  }

  @override
  Future<void> setPostToBskyEnabled(bool value) async {
    await _storageManager.preferences.setBool(StorageKeys.postToBskyKey, value);
  }
}
