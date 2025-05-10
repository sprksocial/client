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
  
  /// Create a Profile from a Bluesky actor
  factory Profile.fromBlueskyActor(Map<String, dynamic> actor) {
    // Using pattern matching to extract data and check conditions
    final isFollowing = switch (actor) {
      {'viewer': {'following': String _}} => true,
      {'viewer': Map<String, dynamic> viewerData} => viewerData.containsKey('following'),
      _ => false
    };
    
    final followUri = switch (actor) {
      {'viewer': {'following': String uri}} => uri,
      _ => null
    };
    
    return Profile(
      handle: actor['handle'] as String,
      did: actor['did'] as String,
      displayName: actor['displayName'] as String?,
      description: actor['description'] as String?,
      avatar: actor['avatar'] as String?,
      banner: null, // Bluesky doesn't have banner
      isFollowing: isFollowing,
      followUri: followUri,
    );
  }

  /// Create a Profile from a Spark profile
  factory Profile.fromSparkProfile(Map<String, dynamic> profileData) {
    // Using pattern matching to extract and transform the data
    final (actorData, viewerData) = switch (profileData) {
      {'actor': Map<String, dynamic> actor, 'viewer': Map<dynamic, dynamic>? viewer} => (actor, viewer),
      {'actor': Map<String, dynamic> actor} => (actor, null),
      _ => (<String, dynamic>{}, null)
    };
    
    return Profile(
      handle: switch (actorData) {
        {'handle': String handle} => handle,
        _ => ''
      },
      did: switch (actorData) {
        {'did': String did} => did,
        _ => ''
      },
      displayName: actorData['displayName'] as String?,
      description: actorData['description'] as String?,
      avatar: actorData['avatar'] as String?,
      banner: actorData['banner'] as String?,
      followersCount: switch (actorData) {
        {'followersCount': int count} => count,
        _ => 0
      },
      followingCount: switch (actorData) {
        {'followingCount': int count} => count,
        _ => 0
      },
      postsCount: switch (actorData) {
        {'postsCount': int count} => count,
        _ => 0
      },
      isSprk: true,
      isFollowing: viewerData?['following'] != null,
      followUri: viewerData?['following'] as String?,
    );
  }

  /// Create a Profile from any profile data (either Bluesky or Spark)
  factory Profile.fromAny(dynamic profileData) {
    return switch (profileData) {
      Map<String, dynamic> data => Profile.fromSparkProfile(data),
      Map<dynamic, dynamic> data => Profile.fromBlueskyActor(
        Map<String, dynamic>.from(data)
      ),
      _ => throw ArgumentError('Unsupported profile data format')
    };
  }
} 