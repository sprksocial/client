import 'package:sparksocial/src/features/settings/data/repositories/settings_repository.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/storage/storage.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final StorageManager _storageManager;

  SettingsRepositoryImpl(this._storageManager);

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
  Future<int> getSelectedFeedIndex(int length) async {
    final selectedFeedIndex = await _storageManager.preferences.getInt(StorageKeys.selectedFeedIndexKey);
    if (selectedFeedIndex == null || selectedFeedIndex >= length) {
      return 0;
    }
    return selectedFeedIndex;
  }

  @override
  Future<void> setSelectedFeedIndex(int index) async {
    await _storageManager.preferences.setInt(StorageKeys.selectedFeedIndexKey, index);
  }
} 