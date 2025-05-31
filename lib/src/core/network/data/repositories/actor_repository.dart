import 'package:sparksocial/src/core/network/data/models/actor_models.dart';

/// Interface for Actor-related API endpoints
abstract class ActorRepository {
  /// Get a profile by DID
  ///
  /// [did] The DID of the profile to get
  Future<ProfileViewDetailed> getProfile(String did);

  /// Search actors by query string.
  ///
  /// [query] The search query.
  Future<List<ProfileView>> searchActors(String query);

  /// Update the user's profile
  ///
  /// [displayName] The new display name
  /// [description] The new description
  /// [avatar] The new avatar (optional)
  Future<void> updateProfile({required String displayName, required String description, dynamic avatar});

  /// Check if a user is an early supporter
  ///
  /// [did] The DID of the user to check
  Future<bool> isEarlySupporter(String did);
}
