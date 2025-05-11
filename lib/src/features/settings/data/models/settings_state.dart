import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';
part 'settings_state.g.dart';

enum FeedType {
  following(0, 'Following'),
  forYou(1, 'For You'),
  latest(2, 'Latest');

  final int value;
  final String name;

  const FeedType(this.value, this.name);

  static FeedType fromValue(int value) {
    return FeedType.values.firstWhere((feedType) => feedType.value == value, orElse: () => FeedType.forYou);
  }
}

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