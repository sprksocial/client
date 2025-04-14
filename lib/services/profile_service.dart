import 'package:atproto/core.dart';
import 'package:bluesky/bluesky.dart';
import 'package:flutter/foundation.dart';

import '../models/profile.dart';
import 'auth_service.dart';
import 'sprk_client.dart';

class ProfileService extends ChangeNotifier {
  final AuthService _authService;

  ProfileService(this._authService);

  Future<Profile?> getProfile(String did) async {
    debugPrint('getProfile called with did: $did');
    if (!_authService.isAuthenticated) {
      debugPrint('Not authenticated, returning null');
      return null;
    }

    // Check for existing follow first
    String? existingFollowUri;
    try {
      debugPrint('Checking existing follows...');
      final existingFollows = await _authService.atproto!.repo.listRecords(
        repo: _authService.session!.did,
        collection: NSID.parse('so.sprk.graph.follow'),
      );

      // Find the follow record for this DID if it exists
      for (final record in existingFollows.data.records) {
        if (record.value['subject'] == did) {
          existingFollowUri = record.uri.toString();
          break;
        }
      }
      debugPrint('Existing follows check completed');
    } catch (e) {
      debugPrint('Error checking existing follows: $e');
    }

    // Try Spark profile first
    try {
      debugPrint('Attempting to fetch Spark profile...');
      final sprkProfile = await getProfileFullSprk(did);
      debugPrint('Spark profile fetch result: ${sprkProfile != null ? 'success' : 'null'}');
      if (sprkProfile != null) {
        final viewer = sprkProfile['viewer'] as Map<dynamic, dynamic>?;
        return Profile.fromSparkProfile({
          'actor': sprkProfile,
          'viewer': {...?viewer, 'following': existingFollowUri},
          'source': 'spark',
        });
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching Spark profile: $e');
      // Only continue to Bluesky if it's a 404-like error
      final errorMsg = e.toString().toLowerCase();
      if (!errorMsg.contains('404')) {
        throw Exception('Failed to fetch Spark profile: $e');
      }
    }

    // Try Bluesky profile if Spark fails with 404
    try {
      final bskyProfile = await getProfileFullBsky(did);
      if (bskyProfile != null) {
        debugPrint('Bsky profile found, retrieving counts...');
        final profile = Profile.fromBlueskyActor(bskyProfile);
        final counts = bskyProfile.toJson();
        debugPrint('Bsky profile counts: $counts');

        var followersCount = counts['followersCount'] as int? ?? 0;
        var followingCount = counts['followsCount'] as int? ?? 0;

        debugPrint('Initial counts - Followers: $followersCount, Following: $followingCount');

        // Try to enhance with Spark data, but don't fail if these calls fail
        final client = SprkClient(_authService);

        try {
          debugPrint('Fetching Spark followers...');
          final sparkFollowers = await client.graph.getFollowers(did);
          debugPrint('Spark followers response: ${sparkFollowers.data}');

          try {
            final followers = sparkFollowers.data['followers'] as List;
            followersCount += followers.length;
            debugPrint('Added ${followers.length} Spark followers, new total: $followersCount');
          } catch (e) {
            debugPrint('Error processing followers: $e');
          }
        } catch (e) {
          debugPrint('Error fetching Spark followers: $e');
          // Continue anyway
        }

        try {
          debugPrint('Fetching Spark follows...');
          final sparkFollows = await client.graph.getFollows(did);
          debugPrint('Spark follows response: ${sparkFollows.data}');

          try {
            final follows = sparkFollows.data['follows'] as List;
            followingCount += follows.length;
            debugPrint('Added ${follows.length} Spark follows, new total: $followingCount');
          } catch (e) {
            debugPrint('Error processing follows: $e');
          }
        } catch (e) {
          debugPrint('Error fetching Spark follows: $e');
          // Continue anyway
        }

        debugPrint('Final counts - Followers: $followersCount, Following: $followingCount');

        return profile.withCounts({
          'followersCount': followersCount,
          'followingCount': followingCount,
          'postsCount': counts['postsCount'] as int? ?? 0,
          'isFollowing': existingFollowUri != null,
          'followUri': existingFollowUri,
        });
      }
    } catch (e) {
      // Both failed, return null
      return null;
    }

    // Both Spark and Bluesky failed, return null
    return null;
  }

  Future<ActorProfile?> getProfileFullBsky(String did) async {
    if (!_authService.isAuthenticated) {
      return null;
    }

    try {
      final bsky = Bluesky.fromSession(_authService.session!);
      final response = await bsky.actor.getProfile(actor: did);
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getProfileFullSprk(String did) async {
    debugPrint('getProfileFullSprk called with did: $did');
    if (!_authService.isAuthenticated) {
      debugPrint('getProfileFullSprk: Not authenticated, returning null');
      return null;
    }

    try {
      debugPrint('getProfileFullSprk: Making API request...');
      final client = SprkClient(_authService);
      final profileRes = await client.actor.getProfile(did);
      debugPrint('getProfileFullSprk: API request completed');

      final profile = profileRes.data as Map<String, dynamic>?;
      debugPrint('getProfileFullSprk: Profile data: ${profile != null ? 'exists' : 'null'}');
      if (profile == null) return null;

      // Ensure we have the viewer information
      if (!profile.containsKey('viewer')) {
        profile['viewer'] = {};
      }

      return profile;
    } catch (e) {
      debugPrint('getProfileFullSprk: Error occurred: $e');
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getProfileVideosSprk(String did) async {
    if (!_authService.isAuthenticated) {
      return null;
    }

    try {
      // Check for existing follow first
      String? existingFollowUri;
      try {
        final existingFollows = await _authService.atproto!.repo.listRecords(
          repo: _authService.session!.did,
          collection: NSID.parse('so.sprk.graph.follow'),
        );

        // Find the follow record for this DID if it exists
        for (final record in existingFollows.data.records) {
          if (record.value['subject'] == did) {
            existingFollowUri = record.uri.toString();
            break;
          }
        }
      } catch (e) {
        debugPrint('Error checking existing follows: $e');
      }

      final client = SprkClient(_authService);
      final response = await client.feed.getAuthorFeed(did);

      if (response.status.code != 200) {
        throw Exception('Failed to fetch profile videos: ${response.status}');
      }

      final data = response.data;

      data['viewer'] = {'following': existingFollowUri};

      return data;
    } catch (e) {
      throw Exception('Failed to fetch profile videos: $e');
    }
  }

  Future<Map<String, dynamic>?> getProfileVideosBsky(String did) async {
    if (!_authService.isAuthenticated) {
      return null;
    }

    try {
      // Check for existing follow first
      String? existingFollowUri;
      try {
        final existingFollows = await _authService.atproto!.repo.listRecords(
          repo: _authService.session!.did,
          collection: NSID.parse('so.sprk.graph.follow'),
        );

        // Find the follow record for this DID if it exists
        for (final record in existingFollows.data.records) {
          if (record.value['subject'] == did) {
            existingFollowUri = record.uri.toString();
            break;
          }
        }
      } catch (e) {
        debugPrint('Error checking existing follows: $e');
      }

      final bsky = Bluesky.fromSession(_authService.session!);
      final response = await bsky.feed.getAuthorFeed(actor: did, filter: FeedFilter.postsWithVideo);
      final feed = response.data.toJson();
      // Add follow status to the response
      feed['viewer'] = {'following': existingFollowUri};
      return feed;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }
}
