import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:sparksocial/src/features/settings/ui/pages/profile_settings_page.dart';

abstract class SettingsRepository {
  Future<bool> getFeedBlurEnabled();
  Future<void> setFeedBlurEnabled(bool value);

  Future<bool> getHideAdultContent();
  Future<void> setHideAdultContent(bool value);

  Future<FollowMode> getFollowMode();
  Future<void> setFollowMode(FollowMode followMode);

  /// Sync follow mode with backend and update local storage
  Future<void> syncFollowModeFromServer();

  /// Set follow mode locally and sync with backend
  Future<void> setFollowModeWithSync(FollowMode followMode);

  Future<List<Feed>> getFeeds();
  Future<void> setFeeds(List<Feed> feeds);
  Future<void> addFeed(Feed feed);
  Future<void> removeFeed(Feed feed);

  Future<Feed> getActiveFeed();
  Future<void> setActiveFeed(Feed feed);

  Future<List<String>> getFollowedLabelers();
  Future<void> setFollowedLabelers(List<String> labelers, List<LabelPreference> labelPreferences);

  Future<LabelPreference> getLabelPreference(String value);
  Future<void> setLabelPreference(String value, Blurs blurs, Severity severity, bool adultOnly, Setting setting);
}
