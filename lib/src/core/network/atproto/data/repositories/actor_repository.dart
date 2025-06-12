import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart';

/// Interface for Actor-related API endpoints
abstract class ActorRepository {
  /// Get a profile by DID
  ///
  /// [did] The DID of the profile to get
  Future<ProfileViewDetailed> getProfile(String did);

  /// Search actors by query string.
  ///
  /// [query] The search query.
  Future<SearchActorsResponse> searchActors(String query, {String? cursor});

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

  /// Get user preferences from the backend
  Future<UserPreferences> getPreferences();

  /// Update user preferences on the backend
  ///
  /// [preferences] The preferences to update
  Future<void> putPreferences(UserPreferences preferences);
}
