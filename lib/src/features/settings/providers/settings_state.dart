import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';

part 'settings_state.freezed.dart';

// Settings currently loaded
@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    required Feed activeFeed,
    @Default([]) List<Feed> feeds,
    @Default([]) List<Feed> likedFeeds,
  }) = _SettingsState;
}
