import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/models/labeler_models.dart';
import 'package:sparksocial/src/core/storage/cache/sql_cache_interface.dart';
import 'package:sparksocial/src/core/storage/preferences/settings_repository.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/storage/storage.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  late final SQLCacheInterface _sqlCache;
  late final StorageManager _storageManager;

  SettingsRepositoryImpl() {
    _sqlCache = GetIt.instance<SQLCacheInterface>();
    _storageManager = GetIt.instance<StorageManager>();
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
      await _storageManager.preferences.setObject<LabelPreference>(
        '${StorageKeys.labelPreferenceKey}_!hide',
        LabelPreference(
          value: '!hide',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.hide,
          setting: Setting.hide,
          adultOnly: false,
        ),
      );
      await _storageManager.preferences.setObject<LabelPreference>(
        '${StorageKeys.labelPreferenceKey}_!no-promote',
        LabelPreference(
          value: '!no-promote',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.hide,
          setting: Setting.hide,
          adultOnly: false,
        ),
      );
      await _storageManager.preferences.setObject<LabelPreference>(
        '${StorageKeys.labelPreferenceKey}_!warn',
        LabelPreference(
          value: '!warn',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.warn,
          setting: Setting.warn,
          adultOnly: false,
        ),
      );
      await _storageManager.preferences.setObject<LabelPreference>(
        '${StorageKeys.labelPreferenceKey}_!no-unauthenticated',
        LabelPreference(
          value: '!no-unauthenticated',
          blurs: Blurs.none,
          severity: Severity.none,
          defaultSetting: Setting.ignore,
          setting: Setting.ignore,
          adultOnly: false,
        ),
      );
      await _storageManager.preferences.setObject<LabelPreference>(
        '${StorageKeys.labelPreferenceKey}_dmca-violation',
        LabelPreference(
          value: 'dmca-violation',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.hide,
          setting: Setting.hide,
          adultOnly: false,
        ),
      );
      await _storageManager.preferences.setObject<LabelPreference>(
        '${StorageKeys.labelPreferenceKey}_doxxing',
        LabelPreference(
          value: 'doxxing',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.warn,
          setting: Setting.warn,
          adultOnly: false,
        ),
      );
      await _storageManager.preferences.setObject<LabelPreference>(
        '${StorageKeys.labelPreferenceKey}_porn',
        LabelPreference(
          value: 'porn',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.warn,
          setting: Setting.warn,
          adultOnly: true,
        ),
      );
      await _storageManager.preferences.setObject<LabelPreference>(
        '${StorageKeys.labelPreferenceKey}_sexual',
        LabelPreference(
          value: 'sexual',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.warn,
          setting: Setting.warn,
          adultOnly: true,
        ),
      );
      await _storageManager.preferences.setObject<LabelPreference>(
        '${StorageKeys.labelPreferenceKey}_nudity',
        LabelPreference(
          value: 'nudity',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.ignore,
          setting: Setting.ignore,
          adultOnly: false,
        ),
      );
      await _storageManager.preferences.setObject<LabelPreference>(
        '${StorageKeys.labelPreferenceKey}_nsfl',
        LabelPreference(
          value: 'nsfl',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.warn,
          setting: Setting.warn,
          adultOnly: true,
        ),
      );
      await _storageManager.preferences.setObject<LabelPreference>(
        '${StorageKeys.labelPreferenceKey}_!hide',
        LabelPreference(
          value: 'gore',
          blurs: Blurs.content,
          severity: Severity.alert,
          defaultSetting: Setting.warn,
          setting: Setting.warn,
          adultOnly: true,
        ),
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
  Future<void> setFeeds(List<Feed> feeds) async {
    await _storageManager.preferences.setObject<List<Feed>>(StorageKeys.feedsKey, feeds);
  }

  @override
  Future<List<Feed>> getFeeds() async {
    return await _storageManager.preferences.getObject<List<Feed>>(StorageKeys.feedsKey) ??
        [
          Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.following),
          Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.forYou),
          Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.latestSprk),
        ];
  }

  @override
  Future<Feed> getActiveFeed() async {
    return await _storageManager.preferences.getObject<Feed>(StorageKeys.activeFeedKey) ??
        Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.forYou);
  }

  @override
  Future<void> setActiveFeed(Feed feed) async {
    await _storageManager.preferences.setObject<Feed>(StorageKeys.activeFeedKey, feed);
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
      await _storageManager.preferences.setObject<LabelPreference>(
        '${StorageKeys.labelPreferenceKey}_${labelPreference.value}',
        labelPreference,
      );
    }
  }

  @override
  Future<LabelPreference> getLabelPreference(String value) async {
    final labelPreference = await _storageManager.preferences.getObject<LabelPreference>(
      '${StorageKeys.labelPreferenceKey}_$value',
    );
    if (labelPreference == null) {
      throw Exception('Label preference not found');
    }
    return labelPreference;
  }

  Future<void> _setDefaultLabelPreferences(String value, Setting setting) async {
    final labelPreference = await _storageManager.preferences.getObject<LabelPreference>(
      '${StorageKeys.labelPreferenceKey}_$value',
    );
    await _storageManager.preferences.setObject<LabelPreference>(
      '${StorageKeys.labelPreferenceKey}_$value',
      labelPreference!.copyWith(setting: setting),
    );
  }

  @override
  Future<void> setLabelPreference(String value, Blurs blurs, Severity severity, bool adultOnly, Setting setting) async {
    if (defaultLabels.contains(value)) {
      await _setDefaultLabelPreferences(value, setting);
    } else {
      final labelPreference = await _storageManager.preferences.getObject<LabelPreference>(
        '${StorageKeys.labelPreferenceKey}_$value',
      );
      if (labelPreference == null) {
        throw Exception('Label preference not found');
      }
      final newLabelPreference = labelPreference.copyWith(
        blurs: blurs,
        severity: severity,
        adultOnly: adultOnly,
        setting: setting,
      );
      await _storageManager.preferences.setObject<LabelPreference>(
        '${StorageKeys.labelPreferenceKey}_$value',
        newLabelPreference,
      );
    }
  }
}
