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
}
