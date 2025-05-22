import 'package:sparksocial/src/core/network/data/models/graph_models.dart';

/// Interface for Graph-related API endpoints
abstract class GraphRepository {
  /// Get followers for a DID
  ///
  /// [did] The DID to get followers for
  Future<FollowersResponse> getFollowers(String did);

  /// Get follows for a DID
  ///
  /// [did] The DID to get follows for
  Future<FollowsResponse> getFollows(String did);

  /// Follow a user
  ///
  /// [did] The DID of the user to follow
  Future<FollowUserResponse> followUser(String did);

  /// Unfollow a user
  ///
  /// [followUri] The URI of the follow record to delete
  Future<void> unfollowUser(String followUri);
}
