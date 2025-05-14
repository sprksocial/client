import 'package:sparksocial/src/features/settings/data/models/label_preference.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

abstract class SettingsRepository {
  Future<bool> getFeedBlurEnabled();
  Future<void> setFeedBlurEnabled(bool value);
  
  Future<bool> getHideAdultContent();
  Future<void> setHideAdultContent(bool value);
  
  Future<List<String>> getFollowedLabelers();
  Future<void> setFollowedLabelers(List<String> labelerDids);
  
  Future<Map<String, Map<String, String>>> getLabelPreferences();
  Future<void> saveLabelPreferences(Map<String, Map<String, String>> preferences);
  
  Future<LabelPreference?> getLabelPreference(String labelerDid, String labelValue);
  Future<void> setLabelPreference(
    String labelerDid, 
    String labelValue, 
    LabelPreference preference
  );
  
  Future<void> removeLabelPreference(String labelerDid, String labelValue);
  Future<void> clearLabelerPreferences(String labelerDid);
  
  // New feed settings methods
  Future<bool> getFollowingFeedEnabled();
  Future<void> setFollowingFeedEnabled(bool value);
  
  Future<bool> getForYouFeedEnabled();
  Future<void> setForYouFeedEnabled(bool value);
  
  Future<bool> getLatestFeedEnabled();
  Future<void> setLatestFeedEnabled(bool value);
  
  Future<FeedType> getSelectedFeedType();
  Future<void> setSelectedFeedType(FeedType value);
}
