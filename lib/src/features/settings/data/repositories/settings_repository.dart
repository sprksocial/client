import '../models/label_preference.dart';

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
}
