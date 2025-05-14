import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

part 'settings_state.freezed.dart';
part 'settings_state.g.dart';


// Settings currently loaded
@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool feedBlurEnabled,
    @Default(true) bool hideAdultContent,
    @Default([]) List<String> followedLabelers,
    @Default({}) Map<String, Map<String, String>> labelPreferences,
    @Default(false) bool isLoading,
    @Default(true) bool followingFeedEnabled,
    @Default(true) bool forYouFeedEnabled,
    @Default(true) bool latestFeedEnabled,
    @JsonKey(fromJson: _feedTypeFromJson, toJson: _feedTypeToJson) 
    @Default(FeedType.forYou) FeedType selectedFeedType,
  }) = _SettingsState;

  factory SettingsState.fromJson(Map<String, dynamic> json) => 
      _$SettingsStateFromJson(json);
}

// Helper functions for JSON serialization of FeedType
FeedType _feedTypeFromJson(int value) => FeedType.fromValue(value);
int _feedTypeToJson(FeedType type) => type.value; 