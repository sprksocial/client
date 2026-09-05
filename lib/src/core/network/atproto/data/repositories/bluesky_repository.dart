import 'package:bluesky_poptart/app/bsky/actor/profile.dart';
import 'package:sprk_poptart/so/sprk/graph/get_follows/output.dart';

/// Canonical access to the current account's Bluesky data.
abstract class BlueskyRepository {
  /// Returns the profile record stored in the current account's repository.
  Future<ActorProfileRecord?> getProfileRecord();

  /// Returns the resolved avatar URL for the current account.
  Future<String?> getAvatarUrl();

  /// Returns a page of accounts followed by the current account on Bluesky.
  Future<GraphGetFollowsOutput> getFollows({String? cursor});
}
