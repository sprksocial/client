import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/features/settings/ui/pages/profile_settings_page.dart';

part 'settings_state.freezed.dart';

// Settings currently loaded
@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool feedBlurEnabled,
    @Default(true) bool hideAdultContent,
    @Default(FollowMode.sprk) FollowMode followMode,
    @Default([
      Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.following),
      Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.forYou),
      Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.latestSprk),
    ])
    List<Feed> feeds,
    required Feed activeFeed,
  }) = _SettingsState;
}
