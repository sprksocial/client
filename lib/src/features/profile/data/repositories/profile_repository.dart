import 'package:sparksocial/src/core/network/data/models/actor_models.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

/// Interface for profile-related operations
abstract class ProfileRepository {
  /// Get a profile by DID
  /// 
  /// [did] The DID of the profile to get
  /// [forceRefresh] Whether to force a refresh from the network
  Future<Profile?> getProfile(String did, {bool forceRefresh = false});
  
  /// Get profile videos from Spark
  /// 
  /// [did] The DID of the profile to get videos for
  /// [limit] Maximum number of items to return (default: 50)
  /// [cursor] Pagination cursor for the next page of results
  Future<AuthorFeedResponse> getProfileVideosSprk(String did, {int limit = 50, String? cursor});
  
  /// Get profile videos from Bluesky
  /// 
  /// [did] The DID of the profile to get videos for
  /// [limit] Maximum number of items to return (default: 50)
  /// [cursor] Pagination cursor for the next page of results
  Future<AuthorFeedResponse> getProfileVideosBsky(String did, {int limit = 50, String? cursor});
  
  /// Update the user's profile
  /// 
  /// [displayName] The new display name
  /// [description] The new description
  /// [avatar] The new avatar (optional)
  Future<void> updateProfile({
    required String displayName, 
    required String description, 
    dynamic avatar,
  });
  
  /// Clear the profile cache for a specific DID
  /// 
  /// [did] The DID to clear the cache for
  Future<void> clearProfileCache(String did);

  /// Check if a user is an early supporter
  ///
  /// [did] The DID of the user to check
  Future<bool> isEarlySupporter(String did);
} 