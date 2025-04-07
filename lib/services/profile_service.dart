import 'dart:convert';

import 'package:atproto/core.dart';
import 'package:bluesky/bluesky.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'auth_service.dart';

class ProfileService extends ChangeNotifier {
  final AuthService _authService;

  ProfileService(this._authService);

  Future<Map<String, dynamic>?> getProfile(String did) async {
    if (!_authService.isAuthenticated) {
      return null;
    }

    // Try Spark profile first
    try {
      final sprkProfile = await getProfileFullSprk(did);
      if (sprkProfile != null) {
        return {...sprkProfile, 'source': 'spark'};
      }
      return null;
    } catch (e) {
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
        return {...bskyProfile, 'source': 'bluesky'};
      }
    } catch (e) {
      // Both failed, return null
      return null;
    }

    // Both Spark and Bluesky failed, return null
    return null;
  }

  Future<Map<String, dynamic>?> getProfileFullBsky(String did) async {
    if (!_authService.isAuthenticated) {
      return null;
    }

    try {
      final bsky = Bluesky.fromSession(_authService.session!);
      final response = await bsky.actor.getProfile(actor: did);
      final profile = response.data;

      return {
        'did': profile.did,
        'handle': profile.handle,
        'displayName': profile.displayName ?? profile.handle,
        'description': profile.description ?? '',
        'avatar': profile.avatar ?? '',
        'followersCount': profile.followersCount,
        'followingCount': profile.followsCount,
        'postsCount': profile.postsCount,
      };
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getProfileFullSprk(String did) async {
    if (!_authService.isAuthenticated) {
      return null;
    }

    try {
      final profileRes = await _authService.atproto!.get(
        NSID.parse('so.sprk.actor.getProfile'),
        parameters: {'actor': did},
        headers: {'atproto-proxy': 'did:web:api.sprk.so#sprk_appview'},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );

      final profile = profileRes.data as Map<String, dynamic>?;

      if (profile == null) {
        return null;
      }

      return {
        'did': profile['did'],
        'handle': profile['handle'],
        'displayName': profile['displayName'],
        'description': profile['description'],
        'avatar': profile['avatar'],
        'followersCount': profile['followersCount'],
        'followingCount': profile['followingCount'],
        'postsCount': profile['postsCount'],
      };
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getProfileVideosSprk(String did) async {
    if (!_authService.isAuthenticated) {
      return null;
    }

    try {
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
      final bsky = Bluesky.fromSession(_authService.session!);
      final response = await bsky.feed.getAuthorFeed(actor: did, filter: FeedFilter.postsWithVideo);
      final feed = response.data.toJson();
      return feed;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }
}
