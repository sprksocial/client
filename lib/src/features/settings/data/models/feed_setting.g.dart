// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeedSettingImpl _$$FeedSettingImplFromJson(Map<String, dynamic> json) =>
    _$FeedSettingImpl(
      feedName: json['feedName'] as String,
      settingType: json['settingType'] as String,
      isEnabled: json['isEnabled'] as bool,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$FeedSettingImplToJson(_$FeedSettingImpl instance) =>
    <String, dynamic>{
      'feedName': instance.feedName,
      'settingType': instance.settingType,
      'isEnabled': instance.isEnabled,
      'description': instance.description,
    };
