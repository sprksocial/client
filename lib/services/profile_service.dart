import 'dart:convert';

import 'package:bluesky/bluesky.dart';
import 'package:flutter/foundation.dart';
import 'package:atproto/core.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/app_config.dart';

class ProfileService extends ChangeNotifier {
  final AuthService _authService;

  ProfileService(this._authService);

  Future<Map<String, dynamic>?> getProfile(String did) async {
    if (!_authService.isAuthenticated) {
      return null;
    }

    try {
      final atProto = _authService.atproto;
      if (atProto == null) {
        return null;
      }

      final profileData = {
        'did': did,
        'handle': '',
        'displayName': '',
        'description': '',
        'avatar': '',
        'followersCount': 0,
        'followingCount': 0,
        'postsCount': 0,
      };

      try {
        final didDocResponse = await http.get(Uri.parse('https://plc.directory/$did'));

        if (didDocResponse.statusCode != 200) {
          throw Exception('Failed to fetch DID document: ${didDocResponse.statusCode}');
        }

        final didDoc = json.decode(didDocResponse.body);

        final handle = (didDoc['alsoKnownAs'] as List<dynamic>)
            .firstWhere((s) => s.startsWith('at://'), orElse: () => '')
            .replaceFirst('at://', '');
        profileData['handle'] = handle;
      } catch (e) {
        profileData['handle'] = did;
      }

      final response = await atProto.repo.getRecord(uri: AtUri.parse('at://$did/app.bsky.actor.profile/self'));

      final recordData = response.data.toJson();

      if (recordData.containsKey('value')) {
        final value = recordData['value'] as Map<String, dynamic>;
        profileData['displayName'] = value['displayName'] ?? profileData['handle'];
        profileData['description'] = value['description'] ?? '';
        profileData['followersCount'] = value['followersCount'] ?? 0;
        profileData['followingCount'] = value['followingCount'] ?? 0;
        profileData['postsCount'] = value['postsCount'] ?? 0;

        final avatarRef = value['avatar']?['ref']?['\$link'];
        if (avatarRef != null) {
          profileData['avatar'] = 'https://cdn.bsky.app/img/feed_fullsize/plain/$did/$avatarRef@jpeg';
        }
      }
      return profileData;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
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
