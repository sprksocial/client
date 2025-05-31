import 'dart:convert';
import 'dart:developer' as developer;

import 'package:atproto/core.dart';
import 'package:bluesky/bluesky.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../models/profile.dart';
import 'auth_service.dart';
import 'sprk_client.dart';

class ProfileService extends ChangeNotifier {
  final AuthService _authService;
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  static const Duration cacheDuration = Duration(minutes: 10);

  ProfileService(this._authService);

  String _getBskyCacheKey(String did) => 'bsky_profile_$did';

  String _getSprkCacheKey(String did) => 'sprk_profile_$did';

  Future<Profile?> getProfile(String did, {bool forceRefresh = false}) async {
    if (!_authService.isAuthenticated) return null;

    String? existingFollowUri = await _getExistingFollowUri(did);

    // Try Spark profile first
    try {
      final sprkProfile = await getProfileFullSprk(did, forceRefresh: forceRefresh);
      if (sprkProfile != null) {
        final profile = Profile.fromSparkProfile({
          'actor': sprkProfile,
          'viewer': sprkProfile['viewer'] as Map<dynamic, dynamic>? ?? {},
          'source': 'spark',
        });

        // Hydrate stories if present
        if (sprkProfile.containsKey('stories') && sprkProfile['stories'] is List) {
          final storyUris = (sprkProfile['stories'] as List).map((story) => story['uri'] as String).toList();

          if (storyUris.isNotEmpty) {
            try {
              final client = SprkClient(_authService);
              final storiesResponse = await client.feed.getStories(storyUris);

              developer.log('storiesResponse: ${storiesResponse.data}');
              final hydratedStories = storiesResponse.data['stories'] as List<dynamic>?;

              if (hydratedStories != null) {
                final stories = hydratedStories.cast<Map<String, dynamic>>();
                return profile.withStories(stories);
              }
            } catch (e) {
              debugPrint('Error hydrating stories: $e');
              // Return profile without stories if hydration fails
            }
          }
        }

        return profile;
      }
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
      final bskyProfile = await getProfileFullBsky(did, forceRefresh: forceRefresh);
      if (bskyProfile != null) {
        final profile = Profile.fromBlueskyActor(bskyProfile);
        final counts = bskyProfile.toJson();

        final followersCount = counts['followersCount'] as int? ?? 0;
        final followingCount = counts['followsCount'] as int? ?? 0;

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

  // Helper method to get existing follow URI
  Future<String?> _getExistingFollowUri(String did) async {
    try {
      final existingFollows = await _authService.atproto!.repo.listRecords(
        repo: _authService.session!.did,
        collection: NSID.parse('so.sprk.graph.follow'),
      );

      // Find the follow record for this DID if it exists
      for (final record in existingFollows.data.records) {
        if (record.value['subject'] == did) {
          return record.uri.toString();
        }
      }
    } catch (e) {
      debugPrint('Error checking existing follows: $e');
    }
    return null;
  }

  Future<ActorProfile?> getProfileFullBsky(String did, {bool forceRefresh = false}) async {
    if (!_authService.isAuthenticated) return null;

    final cacheKey = _getBskyCacheKey(did);

    // First check cache if not forcing refresh
    if (!forceRefresh) {
      try {
        final cacheFile = await _cacheManager.getFileFromCache(cacheKey);
        if (cacheFile != null) {
          final jsonString = await cacheFile.file.readAsString();
          final profileData = json.decode(jsonString);
          return ActorProfile.fromJson(profileData);
        }
      } catch (e) {
        debugPrint('Error reading from cache: $e');
        // Continue to fetch from network
      }
    }

    // Fetch from network
    try {
      final bsky = Bluesky.fromSession(_authService.session!);
      final response = await bsky.actor.getProfile(actor: did);

      // Cache the response
      final profileJson = response.data.toJson();
      final jsonString = json.encode(profileJson);
      await _cacheManager.putFile(cacheKey, Uint8List.fromList(utf8.encode(jsonString)), key: cacheKey, maxAge: cacheDuration);

      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getProfileFullSprk(String did, {bool forceRefresh = false}) async {
    if (!_authService.isAuthenticated) return null;

    final cacheKey = _getSprkCacheKey(did);

    // First check cache if not forcing refresh
    if (!forceRefresh) {
      try {
        final cacheFile = await _cacheManager.getFileFromCache(cacheKey);
        if (cacheFile != null) {
          final jsonString = await cacheFile.file.readAsString();
          return json.decode(jsonString);
        }
      } catch (e) {
        debugPrint('Error reading from cache: $e');
        // Continue to fetch from network
      }
    }

    // Fetch from network
    try {
      final client = SprkClient(_authService);
      final profileRes = await client.actor.getProfile(did);

      final profile = profileRes.data as Map<String, dynamic>?;
      if (profile == null) return null;

      // Ensure we have the viewer information
      if (!profile.containsKey('viewer')) {
        profile['viewer'] = {};
      }

      // Cache the response
      final jsonString = json.encode(profile);
      await _cacheManager.putFile(cacheKey, Uint8List.fromList(utf8.encode(jsonString)), key: cacheKey, maxAge: cacheDuration);

      return profile;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  // Clear all profile caches for a specific DID
  Future<void> clearProfileCache(String did) async {
    await _cacheManager.removeFile(_getBskyCacheKey(did));
    await _cacheManager.removeFile(_getSprkCacheKey(did));
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

  /// Updates existing Spark actor profile
  Future<void> updateProfile({required String displayName, required String description, dynamic avatar}) async {
    if (!_authService.isAuthenticated) {
      throw Exception('Not authenticated');
    }
    final client = SprkClient(_authService);
    final record = <String, dynamic>{
      '\$type': 'so.sprk.actor.profile',
      'displayName': displayName,
      'description': description,
      if (avatar != null) 'avatar': avatar,
    };
    final response = await client.repo.editRecord(
      uri: AtUri.parse('at://${_authService.session!.did}/so.sprk.actor.profile/self'),
      record: record,
    );
    if (response.status.code != 200) {
      throw Exception('Failed to update Spark profile: \\${response.status.code} \\${response.data}');
    }
    notifyListeners();
  }
}
