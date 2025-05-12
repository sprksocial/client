import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_setting.freezed.dart';
part 'feed_setting.g.dart';

@freezed
class FeedSetting with _$FeedSetting {
  const factory FeedSetting({
    required String feedName,
    required String settingType,
    required bool isEnabled,
    String? description,
  }) = _FeedSetting;

  factory FeedSetting.fromJson(Map<String, dynamic> json) => 
      _$FeedSettingFromJson(json);
}
