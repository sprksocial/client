import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart';

part 'graph_models.freezed.dart';
part 'graph_models.g.dart';

@freezed
abstract class FollowersResponse with _$FollowersResponse {
  const factory FollowersResponse({required List<ProfileView> followers, String? cursor}) = _FollowersResponse;

  factory FollowersResponse.fromJson(Map<String, dynamic> json) => _$FollowersResponseFromJson(json);
}

@freezed
abstract class FollowsResponse with _$FollowsResponse {
  const factory FollowsResponse({required List<ProfileView> follows, String? cursor}) = _FollowsResponse;

  factory FollowsResponse.fromJson(Map<String, dynamic> json) => _$FollowsResponseFromJson(json);
}

@freezed
abstract class FollowUserResponse with _$FollowUserResponse {
  const factory FollowUserResponse({required String uri, required String cid}) = _FollowUserResponse;

  factory FollowUserResponse.fromJson(Map<String, dynamic> json) => _$FollowUserResponseFromJson(json);
}

@freezed
abstract class BlocksResponse with _$BlocksResponse {
  const factory BlocksResponse({required List<ProfileView> blocks, String? cursor}) = _BlocksResponse;

  factory BlocksResponse.fromJson(Map<String, dynamic> json) => _$BlocksResponseFromJson(json);
}

@freezed
abstract class BlockUserResponse with _$BlockUserResponse {
  const factory BlockUserResponse({required String uri, required String cid}) = _BlockUserResponse;

  factory BlockUserResponse.fromJson(Map<String, dynamic> json) => _$BlockUserResponseFromJson(json);
}
