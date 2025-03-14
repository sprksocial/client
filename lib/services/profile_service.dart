import 'package:flutter/foundation.dart';
import 'package:atproto/core.dart';
import 'auth_service.dart';

class ProfileService extends ChangeNotifier {
  final AuthService _authService;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _profile;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get profile => _profile;

  ProfileService(this._authService);

  // Get profile by DID
  Future<Map<String, dynamic>?> getProfile(String did) async {
    if (!_authService.isAuthenticated) {
      return null;
    }

    _isLoading = true;
    _error = null;
    _profile = null;
    notifyListeners();

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
      };

      // Try to resolve the handle using the DID
      try {
        final handleResponse = await atProto.identity.resolveHandle(
          handle: did,
        );
        if (handleResponse.data != null && handleResponse.data.did == did) {
          profileData['handle'] = did;
        }
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
        final value = recordData['value'];
        if (value is Map<String, dynamic>) {
          profileData['displayName'] = value['displayName'] ?? '';
          profileData['description'] = value['description'] ?? '';

          if (value['avatar'] != null &&
              value['avatar']['ref'] != null &&
              value['avatar']['ref']['\$link'] != null) {
            final avatarLink = value['avatar']['ref']['\$link'];
            profileData['avatar'] =
                'https://cdn.bsky.app/img/feed_fullsize/plain/$did/$avatarLink@jpeg';
          }
        }
      }

      _profile = profileData;
      _isLoading = false;
      notifyListeners();
      return profileData;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Get current user's profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!_authService.isAuthenticated || _authService.session == null) {
      return null;
    }
    return getProfile(_authService.session!.did);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
