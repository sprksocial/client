// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityDataImpl _$$ActivityDataImplFromJson(Map<String, dynamic> json) =>
    _$ActivityDataImpl(
      id: json['id'] as String,
      username: json['username'] as String,
      type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
      timeString: json['timeString'] as String,
      additionalInfo: json['additionalInfo'] as String?,
      targetContentId: json['targetContentId'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$$ActivityDataImplToJson(_$ActivityDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'timeString': instance.timeString,
      'additionalInfo': instance.additionalInfo,
      'targetContentId': instance.targetContentId,
      'avatarUrl': instance.avatarUrl,
    };

const _$ActivityTypeEnumMap = {
  ActivityType.like: 'like',
  ActivityType.comment: 'comment',
  ActivityType.follow: 'follow',
};
