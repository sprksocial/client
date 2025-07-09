import 'package:atproto_core/atproto_core.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/graph_models.dart';

/// Interface for Graph-related API endpoints
abstract class GraphRepository {
  /// Get followers for a DID
  ///
  /// [did] The DID to get followers for
  /// [cursor] Optional cursor for pagination
  Future<FollowersResponse> getFollowers(String did, {String? cursor});

  /// Get follows for a DID
  ///
  /// [did] The DID to get follows for
  /// [cursor] Optional cursor for pagination
  Future<FollowsResponse> getFollows(String did, {String? cursor});

  /// Follow a user
  ///
  /// [did] The DID of the user to follow
  Future<FollowUserResponse> followUser(String did);

  /// Unfollow a user
  ///
  /// [followUri] The URI of the follow record to delete
  Future<void> unfollowUser(AtUri followUri);

  /// Toggle follow status for a user
  ///
  /// [did] The DID of the user to toggle follow for
  /// [currentFollowUri] The current follow URI if following, null if not following
  /// Returns the follow URI if now following, null if unfollowed
  Future<String?> toggleFollow(String did, AtUri? currentFollowUri);
}
