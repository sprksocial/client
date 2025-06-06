import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/actor_models.dart';

part 'graph_models.freezed.dart';
part 'graph_models.g.dart';

@freezed
class FollowersResponse with _$FollowersResponse {
  const factory FollowersResponse({required List<ProfileView> followers, String? cursor}) = _FollowersResponse;

  factory FollowersResponse.fromJson(Map<String, dynamic> json) => _$FollowersResponseFromJson(json);
}

@freezed
class FollowsResponse with _$FollowsResponse {
  const factory FollowsResponse({required List<ProfileView> follows, String? cursor}) = _FollowsResponse;

  factory FollowsResponse.fromJson(Map<String, dynamic> json) => _$FollowsResponseFromJson(json);
}

@freezed
class FollowUserResponse with _$FollowUserResponse {
  const factory FollowUserResponse({required String uri, required String cid}) = _FollowUserResponse;

  factory FollowUserResponse.fromJson(Map<String, dynamic> json) => _$FollowUserResponseFromJson(json);
}
