import 'package:sparksocial/src/features/settings/data/models/label_preference.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/features/settings/data/models/labeler.dart';

abstract class SettingsRepository {
  Future<bool> getFeedBlurEnabled();
  Future<void> setFeedBlurEnabled(bool value);
  
  Future<bool> getHideAdultContent();
  Future<void> setHideAdultContent(bool value);
  
  Future<List<Labeler>> getFollowedLabelers();
  Future<void> setFollowedLabelers(List<Labeler> labelers);
  
  Future<Map<Labeler, Map<Label, String>>> getLabelPreferences();
  // labelerDid: {label: preference}
  Future<void> saveLabelPreferences(Map<String, Map<Label, String>> preferences);
  
  Future<LabelPreference?> getLabelPreference(Label label);
  Future<void> setLabelPreference(
    Label label, 
    LabelPreference preference
  );
  
  Future<void> removeLabelPreference(Label label);
  Future<void> clearLabelerPreferences(Labeler labeler);
  
  Future<List<Feed>> getFeeds();
  Future<void> setFeeds(List<Feed> feeds);
}
