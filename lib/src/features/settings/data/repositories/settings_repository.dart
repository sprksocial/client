import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

abstract class SettingsRepository {
  Future<bool> getFeedBlurEnabled();
  Future<void> setFeedBlurEnabled(bool value);
  
  Future<bool> getHideAdultContent();
  Future<void> setHideAdultContent(bool value);
  
  Future<List<Feed>> getFeeds();
  Future<void> setFeeds(List<Feed> feeds);

  /// You need to pass the length of the feeds list to check if the index is valid
  /// (in case the user was in the last feed, deleted it and closed the app)
  Future<int> getSelectedFeedIndex(int length);
  Future<void> setSelectedFeedIndex(int index);
}
