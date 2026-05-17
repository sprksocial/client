import 'package:poptart/poptart.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';
import 'package:sprk_poptart/so/sprk/actor/search_actors/output.dart';
import 'package:sprk_poptart/so/sprk/actor/search_actors_typeahead/output.dart';

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
  Future<ActorSearchActorsOutput> searchActors(String query, {String? cursor});

  /// Search actor suggestions by query prefix.
  ///
  /// [query] The search query prefix.
  /// [limit] Maximum number of suggestions to return.
  Future<ActorSearchActorsTypeaheadOutput> searchActorsTypeahead(
    String query, {
    int limit = 10,
  });

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
