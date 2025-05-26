// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actor_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ViewerImpl _$$ViewerImplFromJson(Map<String, dynamic> json) => _$ViewerImpl(
      muted: json['muted'] as bool?,
      blockedBy: json['blockedBy'] as bool?,
      blocking: _$JsonConverterFromJson<String, AtUri>(
          json['blocking'], const AtUriConverter().fromJson),
      following: _$JsonConverterFromJson<String, AtUri>(
          json['following'], const AtUriConverter().fromJson),
      followedBy: _$JsonConverterFromJson<String, AtUri>(
          json['followedBy'], const AtUriConverter().fromJson),
      followers: json['followers'] == null
          ? null
          : KnownFollowers.fromJson(json['followers'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ViewerImplToJson(_$ViewerImpl instance) =>
    <String, dynamic>{
      'muted': instance.muted,
      'blockedBy': instance.blockedBy,
      'blocking': _$JsonConverterToJson<String, AtUri>(
          instance.blocking, const AtUriConverter().toJson),
      'following': _$JsonConverterToJson<String, AtUri>(
          instance.following, const AtUriConverter().toJson),
      'followedBy': _$JsonConverterToJson<String, AtUri>(
          instance.followedBy, const AtUriConverter().toJson),
      'followers': instance.followers,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

_$KnownFollowersImpl _$$KnownFollowersImplFromJson(Map<String, dynamic> json) =>
    _$KnownFollowersImpl(
      count: (json['count'] as num).toInt(),
      followersDids: (json['followersDids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$KnownFollowersImplToJson(
        _$KnownFollowersImpl instance) =>
    <String, dynamic>{
      'count': instance.count,
      'followersDids': instance.followersDids,
    };

_$ProfileViewBasicImpl _$$ProfileViewBasicImplFromJson(
        Map<String, dynamic> json) =>
    _$ProfileViewBasicImpl(
      did: json['did'] as String,
      handle: json['handle'] as String,
      displayName: json['displayName'] as String?,
      avatar: _$JsonConverterFromJson<String, AtUri>(
          json['avatar'], const AtUriConverter().fromJson),
      viewer: json['viewer'] == null
          ? null
          : Viewer.fromJson(json['viewer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ProfileViewBasicImplToJson(
        _$ProfileViewBasicImpl instance) =>
    <String, dynamic>{
      'did': instance.did,
      'handle': instance.handle,
      'displayName': instance.displayName,
      'avatar': _$JsonConverterToJson<String, AtUri>(
          instance.avatar, const AtUriConverter().toJson),
      'viewer': instance.viewer,
    };

_$ProfileViewImpl _$$ProfileViewImplFromJson(Map<String, dynamic> json) =>
    _$ProfileViewImpl(
      did: json['did'] as String,
      handle: json['handle'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      avatar: _$JsonConverterFromJson<String, AtUri>(
          json['avatar'], const AtUriConverter().fromJson),
      viewer: json['viewer'] == null
          ? null
          : Viewer.fromJson(json['viewer'] as Map<String, dynamic>),
      labels: (json['labels'] as List<dynamic>?)
          ?.map((e) => Label.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ProfileViewImplToJson(_$ProfileViewImpl instance) =>
    <String, dynamic>{
      'did': instance.did,
      'handle': instance.handle,
      'displayName': instance.displayName,
      'description': instance.description,
      'avatar': _$JsonConverterToJson<String, AtUri>(
          instance.avatar, const AtUriConverter().toJson),
      'viewer': instance.viewer,
      'labels': instance.labels,
    };

_$ProfileViewDetailedImpl _$$ProfileViewDetailedImplFromJson(
        Map<String, dynamic> json) =>
    _$ProfileViewDetailedImpl(
      did: json['did'] as String,
      handle: json['handle'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      avatar: _$JsonConverterFromJson<String, AtUri>(
          json['avatar'], const AtUriConverter().fromJson),
      banner: _$JsonConverterFromJson<String, AtUri>(
          json['banner'], const AtUriConverter().fromJson),
      followersCount: (json['followersCount'] as num?)?.toInt(),
      followingCount: (json['followingCount'] as num?)?.toInt(),
      postsCount: (json['postsCount'] as num?)?.toInt(),
      viewer: json['viewer'] == null
          ? null
          : Viewer.fromJson(json['viewer'] as Map<String, dynamic>),
      labels: (json['labels'] as List<dynamic>?)
          ?.map((e) => Label.fromJson(e as Map<String, dynamic>))
          .toList(),
      pinnedPost: json['pinnedPost'] == null
          ? null
          : StrongRef.fromJson(json['pinnedPost'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ProfileViewDetailedImplToJson(
        _$ProfileViewDetailedImpl instance) =>
    <String, dynamic>{
      'did': instance.did,
      'handle': instance.handle,
      'displayName': instance.displayName,
      'description': instance.description,
      'avatar': _$JsonConverterToJson<String, AtUri>(
          instance.avatar, const AtUriConverter().toJson),
      'banner': _$JsonConverterToJson<String, AtUri>(
          instance.banner, const AtUriConverter().toJson),
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'postsCount': instance.postsCount,
      'viewer': instance.viewer,
      'labels': instance.labels,
      'pinnedPost': instance.pinnedPost,
    };
