// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageDataImpl _$$MessageDataImplFromJson(Map<String, dynamic> json) =>
    _$MessageDataImpl(
      id: json['id'] as String,
      username: json['username'] as String,
      messagePreview: json['messagePreview'] as String,
      timeString: json['timeString'] as String,
      unreadCount: (json['unreadCount'] as num?)?.toInt(),
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$$MessageDataImplToJson(_$MessageDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'messagePreview': instance.messagePreview,
      'timeString': instance.timeString,
      'unreadCount': instance.unreadCount,
      'avatarUrl': instance.avatarUrl,
    };
