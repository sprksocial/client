// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bsky_follows.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BskyFollowImpl _$$BskyFollowImplFromJson(Map<String, dynamic> json) =>
    _$BskyFollowImpl(
      did: json['did'] as String,
      handle: json['handle'] as String,
      displayName: json['displayName'] as String?,
      avatar: json['avatar'] as String?,
      description: json['description'] as String?,
      indexedAt: json['indexedAt'] == null
          ? null
          : DateTime.parse(json['indexedAt'] as String),
    );

Map<String, dynamic> _$$BskyFollowImplToJson(_$BskyFollowImpl instance) =>
    <String, dynamic>{
      'did': instance.did,
      'handle': instance.handle,
      'displayName': instance.displayName,
      'avatar': instance.avatar,
      'description': instance.description,
      'indexedAt': instance.indexedAt?.toIso8601String(),
    };

_$BskyFollowsImpl _$$BskyFollowsImplFromJson(Map<String, dynamic> json) =>
    _$BskyFollowsImpl(
      follows: (json['follows'] as List<dynamic>)
          .map((e) => BskyFollow.fromJson(e as Map<String, dynamic>))
          .toList(),
      cursor: json['cursor'] as String?,
    );

Map<String, dynamic> _$$BskyFollowsImplToJson(_$BskyFollowsImpl instance) =>
    <String, dynamic>{
      'follows': instance.follows,
      'cursor': instance.cursor,
    };
