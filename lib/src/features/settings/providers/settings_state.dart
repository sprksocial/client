import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

part 'settings_state.freezed.dart';

// Settings currently loaded
@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool feedBlurEnabled,
    @Default(true) bool hideAdultContent,
    @Default([
      Feed.hardCoded(hardCodedFeed: HardCodedFeed.following),
      Feed.hardCoded(hardCodedFeed: HardCodedFeed.forYou),
      Feed.hardCoded(hardCodedFeed: HardCodedFeed.latestSprk),
    ])
    List<Feed> feeds,
    required Feed activeFeed,
  }) = _SettingsState;
}
