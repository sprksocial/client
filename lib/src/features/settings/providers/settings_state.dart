import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';

part 'settings_state.freezed.dart';

// Settings currently loaded
@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    required Feed activeFeed,
    @Default(false) bool feedBlurEnabled,
    @Default(true) bool hideAdultContent,
    @Default([
      Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.following),
      Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.forYou),
      Feed.hardCoded(hardCodedFeed: HardCodedFeedEnum.latestSprk),
    ])
    List<Feed> feeds,
    @Default(false) bool postToBskyEnabled,
  }) = _SettingsState;
}
