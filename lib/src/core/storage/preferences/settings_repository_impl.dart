import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/storage/preferences/settings_repository.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/storage/storage.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final StorageManager _storageManager;
  late final SQLCache _sqlCache;

  SettingsRepositoryImpl(this._storageManager) {
    _sqlCache = GetIt.instance<SQLCache>();
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
    return await _storageManager.preferences.getObject<List<Feed>>(StorageKeys.feedsKey) ?? [];
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
}
