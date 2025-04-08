import 'dart:convert';

import 'package:atproto/core.dart';
import 'package:bluesky/bluesky.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/profile.dart';
import 'auth_service.dart';

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
        final viewer = sprkProfile['viewer'] as Map<String, dynamic>?;
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
        final profile = Profile.fromBlueskyActor(bskyProfile);
        final counts = bskyProfile.toJson();
        return profile.withCounts({
          'followersCount': counts['followersCount'] as int? ?? 0,
          'followingCount': counts['followsCount'] as int? ?? 0,
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
      final profileRes = await _authService.atproto!.get(
        NSID.parse('so.sprk.actor.getProfile'),
        parameters: {'actor': did},
        headers: {'atproto-proxy': 'did:web:api.sprk.so#sprk_appview'},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
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

      final pdsUrl = _authService.atproto?.service;
      if (pdsUrl == null) {
        return null;
      }

      final url = '${AppConfig.appViewUrl}/actorFeed/$did';
      final response = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer ${_authService.session?.accessJwt}'});

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch profile videos: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      // Add follow status to the response
      if (data is Map<String, dynamic>) {
        data['viewer'] = {'following': existingFollowUri};
      }
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
