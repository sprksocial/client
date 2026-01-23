import 'package:atproto/core.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';

/// Interface for Actor-related API endpoints
abstract class ActorRepository {
  /// Get a profile by DID
  ///
  /// [did] The DID of the profile to get
  /// [useBluesky] Whether to use Bluesky API instead of Spark (default false)
  Future<ProfileViewDetailed> getProfile(String did, {bool useBluesky = false});

  /// Get multiple profiles by their DIDs
  ///
  /// [dids] A list of DIDs to fetch profiles for
  /// [useBluesky] Whether to use Bluesky API instead of Spark (default false)
  Future<List<ProfileViewDetailed>> getProfiles(
    List<String> dids, {
    bool useBluesky = false,
  });

  /// Search actors by query string.
  ///
  /// [query] The search query.
  Future<SearchActorsResponse> searchActors(String query, {String? cursor});

  /// Update the user's profile
  ///
  /// [displayName] The new display name
  /// [description] The new description
  /// [avatar] The new avatar (optional)
  Future<void> updateProfile({
    required String displayName,
    required String description,
    Blob? avatar,
  });

  /// Check if a user is an early supporter
  ///
  /// [did] The DID of the user to check
  Future<bool> isEarlySupporter(String did);
}
