import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:atproto/core.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ProfileService extends ChangeNotifier {
  final AuthService _authService;

  ProfileService(this._authService);

  // Get profile by DID without updating internal state
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

      // Try to resolve the handle using the DID
      try {
        final didDocResponse = await http.get(
          Uri.parse('https://plc.directory/$did'),
        );

        if (didDocResponse.statusCode != 200) {
          throw Exception(
            'Failed to fetch DID document: ${didDocResponse.statusCode}',
          );
        }

        final didDoc = json.decode(didDocResponse.body);

        final handle = (didDoc['alsoKnownAs'] as List<dynamic>)
            .firstWhere((s) => s.startsWith('at://'), orElse: () => '')
            .replaceFirst('at://', '');
        profileData['handle'] = handle;
      } catch (e) {
        // If handle lookup fails, use DID as fallback
        profileData['handle'] = did;
      }

      // Then get the profile record
      final response = await atProto.repo.getRecord(
        uri: AtUri.parse('at://$did/app.bsky.actor.profile/self'),
      );

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

  // Get current user's profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!_authService.isAuthenticated || _authService.session == null) {
      return null;
    }
    return getProfile(_authService.session!.did);
  }
}
