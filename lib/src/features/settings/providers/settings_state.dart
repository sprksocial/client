import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/features/settings/data/models/labeler.dart';
import 'package:sparksocial/src/features/settings/data/models/label_preference.dart';

part 'settings_state.freezed.dart';

// Settings currently loaded
@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool feedBlurEnabled,
    @Default(true) bool hideAdultContent,
    @Default({}) Map<Labeler, Map<Label, LabelPreference>> labelPreferences,
    @Default([
      Feed.hardCoded(hardCodedFeed: HardCodedFeed.following),
      Feed.hardCoded(hardCodedFeed: HardCodedFeed.forYou),
      Feed.hardCoded(hardCodedFeed: HardCodedFeed.latestSprk),
    ])
    List<Feed> feeds,
  }) = _SettingsState;
}
