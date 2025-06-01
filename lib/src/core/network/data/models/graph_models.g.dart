// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graph_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FollowersResponseImpl _$$FollowersResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$FollowersResponseImpl(
      followers: (json['followers'] as List<dynamic>)
          .map((e) => ProfileView.fromJson(e as Map<String, dynamic>))
          .toList(),
      cursor: json['cursor'] as String?,
    );

Map<String, dynamic> _$$FollowersResponseImplToJson(
        _$FollowersResponseImpl instance) =>
    <String, dynamic>{
      'followers': instance.followers,
      'cursor': instance.cursor,
    };

_$FollowsResponseImpl _$$FollowsResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$FollowsResponseImpl(
      follows: (json['follows'] as List<dynamic>)
          .map((e) => ProfileView.fromJson(e as Map<String, dynamic>))
          .toList(),
      cursor: json['cursor'] as String?,
    );

Map<String, dynamic> _$$FollowsResponseImplToJson(
        _$FollowsResponseImpl instance) =>
    <String, dynamic>{
      'follows': instance.follows,
      'cursor': instance.cursor,
    };

_$FollowUserResponseImpl _$$FollowUserResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$FollowUserResponseImpl(
      uri: json['uri'] as String,
      cid: CID.fromJson(json['cid'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$FollowUserResponseImplToJson(
        _$FollowUserResponseImpl instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'cid': instance.cid,
    };
