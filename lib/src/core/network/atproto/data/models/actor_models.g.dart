// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actor_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileResponseImpl _$$ProfileResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ProfileResponseImpl(
      did: json['did'] as String,
      handle: json['handle'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
      banner: json['banner'] as String?,
      followsYou: json['followsYou'] as bool? ?? false,
      youFollow: json['youFollow'] as bool? ?? false,
      viewer: json['viewer'] as Map<String, dynamic>?,
      labels: json['labels'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ProfileResponseImplToJson(
        _$ProfileResponseImpl instance) =>
    <String, dynamic>{
      'did': instance.did,
      'handle': instance.handle,
      'displayName': instance.displayName,
      'description': instance.description,
      'avatar': instance.avatar,
      'banner': instance.banner,
      'followsYou': instance.followsYou,
      'youFollow': instance.youFollow,
      'viewer': instance.viewer,
      'labels': instance.labels,
    };

_$ActorSearchResponseImpl _$$ActorSearchResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ActorSearchResponseImpl(
      actors: (json['actors'] as List<dynamic>)
          .map((e) => Actor.fromJson(e as Map<String, dynamic>))
          .toList(),
      cursor: json['cursor'] as String?,
    );

Map<String, dynamic> _$$ActorSearchResponseImplToJson(
        _$ActorSearchResponseImpl instance) =>
    <String, dynamic>{
      'actors': instance.actors,
      'cursor': instance.cursor,
    };

_$ActorImpl _$$ActorImplFromJson(Map<String, dynamic> json) => _$ActorImpl(
      did: json['did'] as String,
      handle: json['handle'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
      followsYou: json['followsYou'] as bool? ?? false,
      youFollow: json['youFollow'] as bool? ?? false,
      viewer: json['viewer'] as Map<String, dynamic>?,
      labels: json['labels'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ActorImplToJson(_$ActorImpl instance) =>
    <String, dynamic>{
      'did': instance.did,
      'handle': instance.handle,
      'displayName': instance.displayName,
      'description': instance.description,
      'avatar': instance.avatar,
      'followsYou': instance.followsYou,
      'youFollow': instance.youFollow,
      'viewer': instance.viewer,
      'labels': instance.labels,
    };

_$ProfileImpl _$$ProfileImplFromJson(Map<String, dynamic> json) =>
    _$ProfileImpl(
      did: json['did'] as String,
      handle: json['handle'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
      banner: json['banner'] as String?,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
      isSprk: json['isSprk'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
      followUri: json['followUri'] as String?,
    );

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'did': instance.did,
      'handle': instance.handle,
      'displayName': instance.displayName,
      'description': instance.description,
      'avatar': instance.avatar,
      'banner': instance.banner,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'postsCount': instance.postsCount,
      'isSprk': instance.isSprk,
      'isFollowing': instance.isFollowing,
      'followUri': instance.followUri,
    };
