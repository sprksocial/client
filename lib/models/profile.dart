import 'package:bluesky/bluesky.dart';

/// A unified model for handling profiles from different sources
class Profile {
  final String username;
  final String did;
  final String? displayName;
  final String? description;
  final String? avatarUrl;
  final String? bannerUrl;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isSprk; // Whether the profile is from Spark
  final bool isFollowing; // Whether the current user is following this profile
  final String? followUri; // URI of the follow record if following
  final List<Map<String, dynamic>>? stories; // Hydrated stories data

  Profile({
    required this.username,
    required this.did,
    this.displayName,
    this.description,
    this.avatarUrl,
    this.bannerUrl,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.isSprk = false,
    this.isFollowing = false,
    this.followUri,
    this.stories,
  });

  /// Create a Profile from a Bluesky actor
  static Profile fromBlueskyActor(ActorProfile actor) {
    return Profile(
      username: actor.handle,
      did: actor.did,
      displayName: actor.displayName,
      description: actor.description,
      avatarUrl: actor.avatar,
      bannerUrl: null, // Bluesky doesn't have banner
      followersCount: actor.followersCount,
      followingCount: actor.followsCount,
      postsCount: actor.postsCount,
      isSprk: false,
      isFollowing: actor.viewer.following != null,
      followUri: actor.viewer.following?.toString(),
      stories: null,
    );
  }

  /// Create a Profile from a Spark profile
  static Profile fromSparkProfile(Map<String, dynamic> profileData) {
    final actor = profileData['actor'] as Map<String, dynamic>;
    final viewer = profileData['viewer'] as Map<dynamic, dynamic>?;

    return Profile(
      username: actor['handle'] as String? ?? '',
      did: actor['did'] as String? ?? '',
      displayName: actor['displayName'] as String?,
      description: actor['description'] as String?,
      avatarUrl: actor['avatar'] as String?,
      bannerUrl: actor['banner'] as String?,
      followersCount: actor['followersCount'] as int? ?? 0,
      followingCount: actor['followsCount'] as int? ?? 0,
      postsCount: actor['postsCount'] as int? ?? 0,
      isSprk: true,
      isFollowing: viewer?['following'] != null,
      followUri: viewer?['following'] as String?,
      stories: null,
    );
  }

  /// Create a Profile from any profile data (either Bluesky or Spark)
  static Profile fromAny(dynamic profileData) {
    if (profileData is Map<String, dynamic>) {
      return fromSparkProfile(profileData);
    } else {
      return fromBlueskyActor(profileData);
    }
  }

  /// Create a new Profile with updated counts from profile data
  Profile withCounts(Map<String, dynamic> profileData) {
    return Profile(
      username: username,
      did: did,
      displayName: displayName,
      description: description,
      avatarUrl: avatarUrl,
      bannerUrl: bannerUrl,
      followersCount: profileData['followersCount'] as int? ?? followersCount,
      followingCount: profileData['followingCount'] as int? ?? followingCount,
      postsCount: profileData['postsCount'] as int? ?? postsCount,
      isSprk: isSprk,
      isFollowing: profileData['isFollowing'] as bool? ?? isFollowing,
      followUri: profileData['followUri'] as String? ?? followUri,
      stories: stories,
    );
  }

  /// Create a new Profile with updated stories
  Profile withStories(List<Map<String, dynamic>>? newStories) {
    return Profile(
      username: username,
      did: did,
      displayName: displayName,
      description: description,
      avatarUrl: avatarUrl,
      bannerUrl: bannerUrl,
      followersCount: followersCount,
      followingCount: followingCount,
      postsCount: postsCount,
      isSprk: isSprk,
      isFollowing: isFollowing,
      followUri: followUri,
      stories: newStories,
    );
  }

  /// Convert profile to a map for use in UI
  Map<String, dynamic> toJson() {
    return {
      'did': did,
      'handle': username,
      'displayName': displayName,
      'description': description,
      'avatar': avatarUrl,
      'banner': bannerUrl,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'source': isSprk ? 'spark' : 'bluesky',
      'followUri': followUri,
    };
  }
}
