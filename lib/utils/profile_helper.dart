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
  
  // Handle username tap by resolving the handle
  static Future<void> handleUsernameTap(String username) async {
    try {
      // Remove @ from username if present
      final cleanUsername = username.startsWith('@') ? username.substring(1) : username;
      
      // TODO: Use at.resolveHandle from atproto package to resolve the handle to a DID
      // Example: final did = await atprotoService.resolveHandle(cleanUsername);
      
      // For now, just log the click for testing
      print('Would resolve handle and navigate to profile for: $cleanUsername');
      
      // TODO: Navigate to profile with the resolved DID
      // Example: Navigator.push(context, CupertinoPageRoute(builder: (context) => ProfileScreen(did: did)));
    } catch (e) {
      print('Error resolving handle: $e');
    }
  }
} 