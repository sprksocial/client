import 'package:atproto/atproto.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

abstract class SettingsRepository {
  Future<bool> getFeedBlurEnabled();
  Future<void> setFeedBlurEnabled(bool value);
  
  Future<bool> getHideAdultContent();
  Future<void> setHideAdultContent(bool value);
  
  Future<List<Feed>> getFeeds();
  Future<void> setFeeds(List<Feed> feeds);
  Future<void> addFeed(Feed feed);
  Future<void> removeFeed(Feed feed);

  Future<Feed> getActiveFeed();
  Future<void> setActiveFeed(Feed feed);

  Future<Map<String, List<LabelValueDefinition, 
}
