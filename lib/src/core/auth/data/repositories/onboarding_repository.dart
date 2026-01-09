import 'package:bluesky/app_bsky_actor_profile.dart';
import 'package:spark/src/core/network/atproto/data/models/graph_models.dart';

abstract class OnboardingRepository {
  /// Checks if the current user has a Spark profile
  Future<bool> hasSparkProfile();

  /// Retrieves the Bluesky profile for import
  Future<ActorProfileRecord?> getBskyProfile();

  /// Creates a Spark actor profile with custom values
  Future<void> createSparkProfile({
    required String displayName,
    required String description,
    dynamic avatar,
  });

  /// Fetches the list of DIDs that the user follows on Bluesky
  Future<FollowsResponse> getBskyFollows({String? cursor});

  /// Creates a follow record in Spark for the given subject DID
  Future<void> createSparkFollow(String subject);
}
