import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _SettingsState;

  factory SettingsState.fromJson(Map<String, dynamic> json) => 
      _$SettingsStateFromJson(json);
} 