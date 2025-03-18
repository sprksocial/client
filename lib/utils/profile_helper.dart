import '../services/auth_service.dart';

class ProfileHelper {
  static bool isCurrentUser(AuthService authService, Map<String, dynamic>? profileData) {
    if (profileData == null) return false;
    return authService.isAuthenticated && authService.session?.did == profileData['did'];
  }

  static Map<String, dynamic> extractProfileData(Map<String, dynamic> profileData) {
    return {
      'displayName': profileData['displayName'] ?? '',
      'handle': profileData['handle'] ?? '',
      'description': profileData['description'] ?? '',
      'avatar': profileData['avatar'],
      'postsCount': profileData['postsCount'] ?? profileData['posts_count'] ?? profileData['postCount'] ?? 0,
      'followersCount': profileData['followersCount'] ?? profileData['followers_count'] ?? profileData['followerCount'] ?? 0,
      'followingCount': profileData['followingCount'] ?? profileData['following_count'] ?? profileData['followsCount'] ?? 0,
    };
  }
}
