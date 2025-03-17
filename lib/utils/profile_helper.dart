import '../services/auth_service.dart';

class ProfileHelper {
  // Check if the profile belongs to the current user
  static bool isCurrentUser(AuthService authService, Map<String, dynamic>? profileData) {
    if (profileData == null) return false;
    return authService.isAuthenticated &&
           authService.session?.did == profileData['did'];
  }

  // Extract profile data with fallbacks for missing fields
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