import 'package:freezed_annotation/freezed_annotation.dart';

part 'actor_models.freezed.dart';
part 'actor_models.g.dart';

@freezed
class ProfileResponse with _$ProfileResponse {
  const factory ProfileResponse({
    required String did,
    required String handle,
    String? displayName,
    String? description,
    String? avatar,
    String? banner,
    @Default(false) bool followsYou,
    @Default(false) bool youFollow,
    Map<String, dynamic>? viewer,
    Map<String, dynamic>? labels,
  }) = _ProfileResponse;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) => _$ProfileResponseFromJson(json);
}

@freezed
class ActorSearchResponse with _$ActorSearchResponse {
  const factory ActorSearchResponse({
    required List<Actor> actors,
    String? cursor,
  }) = _ActorSearchResponse;

  factory ActorSearchResponse.fromJson(Map<String, dynamic> json) => _$ActorSearchResponseFromJson(json);
}

@freezed
class Actor with _$Actor {
  const factory Actor({
    required String did,
    required String handle,
    String? displayName,
    String? description,
    String? avatar,
    @Default(false) bool followsYou,
    @Default(false) bool youFollow,
    Map<String, dynamic>? viewer,
    Map<String, dynamic>? labels,
  }) = _Actor;

  factory Actor.fromJson(Map<String, dynamic> json) => _$ActorFromJson(json);
}

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String did,
    required String handle,
    String? displayName,
    String? description,
    String? avatar,
    String? banner,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    @Default(0) int postsCount,
    @Default(false) bool isSprk,
    @Default(false) bool isFollowing,
    String? followUri,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}

// Extension methods for Profile for factory methods
extension ProfileFactory on Profile {
  /// Create a Profile from a Bluesky actor
  static Profile fromBlueskyActor(Map<String, dynamic> actor) {
    return Profile(
      handle: actor['handle'] as String,
      did: actor['did'] as String,
      displayName: actor['displayName'] as String?,
      description: actor['description'] as String?,
      avatar: actor['avatar'] as String?,
      banner: null, // Bluesky doesn't have banner
      isFollowing: actor['viewer'] != null && 
                  (actor['viewer'] as Map<String, dynamic>).containsKey('following'),
      followUri: actor['viewer'] != null && 
                (actor['viewer'] as Map<String, dynamic>).containsKey('following') ?
                (actor['viewer'] as Map<String, dynamic>)['following'] as String? : null,
    );
  }

  /// Create a Profile from a Spark profile
  static Profile fromSparkProfile(Map<String, dynamic> profileData) {
    final actor = profileData['actor'] as Map<String, dynamic>;
    final viewer = profileData['viewer'] as Map<dynamic, dynamic>?;

    return Profile(
      handle: actor['handle'] as String? ?? '',
      did: actor['did'] as String? ?? '',
      displayName: actor['displayName'] as String?,
      description: actor['description'] as String?,
      avatar: actor['avatar'] as String?,
      banner: actor['banner'] as String?,
      followersCount: actor['followersCount'] as int? ?? 0,
      followingCount: actor['followingCount'] as int? ?? 0,
      postsCount: actor['postsCount'] as int? ?? 0,
      isSprk: true,
      isFollowing: viewer?['following'] != null,
      followUri: viewer?['following'] as String?,
    );
  }

  /// Create a Profile from any profile data (either Bluesky or Spark)
  static Profile fromAny(dynamic profileData) {
    if (profileData is Map<String, dynamic>) {
      return fromSparkProfile(profileData);
    } else {
      // Convert non-map object to map first
      final jsonData = Map<String, dynamic>.from(
          profileData as Map<dynamic, dynamic>);
      return fromBlueskyActor(jsonData);
    }
  }
} 