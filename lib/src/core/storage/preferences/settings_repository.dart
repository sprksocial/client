import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/pref_models.dart';

abstract class SettingsRepository {
  Future<List<Feed>> getFeeds();
  Future<void> setFeeds(List<Feed> feeds);
  Future<void> addFeed(Feed feed);
  Future<void> removeFeed(Feed feed);

  Future<Feed> getActiveFeed();
  Future<void> setActiveFeed(Feed feed);

  Future<List<String>> getLabelers();
  Future<void> setLabelers(List<String> labelers, List<LabelPreference> labelPreferences);

  Future<LabelPreference> getLabelPreference(String value);
  Future<void> setLabelPreference(String value, Blurs blurs, Severity severity, bool adultOnly, Setting setting);

  Future<bool> getPostToBskyEnabled();
  Future<void> setPostToBskyEnabled(bool value);

  Future<Preferences> getPreferences();
  Future<void> putPreferences(Preferences preferences);
}
