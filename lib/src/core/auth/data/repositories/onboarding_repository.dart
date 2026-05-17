import 'package:bluesky_poptart/app/bsky/actor/profile.dart';
import 'package:sprk_poptart/so/sprk/graph/get_follows/output.dart';

abstract class OnboardingRepository {
  /// Checks if the current user has a Spark profile
  Future<bool> hasSparkProfile();

  /// Retrieves the Bluesky profile for import
  Future<ActorProfileRecord?> getBskyProfile();

  /// Retrieves the resolved Bluesky avatar URL for the current user.
  Future<String?> getBskyAvatarUrl();

  /// Creates a Spark actor profile with custom values
  Future<void> createSparkProfile({
    required String displayName,
    required String description,
    dynamic avatar,
  });

  /// Fetches the list of DIDs that the user follows on Bluesky
  Future<GraphGetFollowsOutput> getBskyFollows({String? cursor});

  /// Creates a follow record in Spark for the given subject DID
  Future<void> createSparkFollow(String subject);
}
