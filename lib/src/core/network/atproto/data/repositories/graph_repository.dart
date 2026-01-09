import 'package:atproto_core/atproto_core.dart';
import 'package:spark/src/core/network/atproto/data/models/graph_models.dart';

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
  /// [currentFollowUri] The follow URI if following, null if not
  /// Returns the follow URI if now following, null if unfollowed
  Future<String?> toggleFollow(String did, AtUri? currentFollowUri);

  /// Get blocks for a DID
  ///
  /// [did] The DID to get blocks for
  /// [cursor] Optional cursor for pagination
  Future<BlocksResponse> getBlocks(String did, {String? cursor});

  /// Block a user
  ///
  /// [did] The DID of the user to block
  Future<BlockUserResponse> blockUser(String did);

  /// Unblock a user
  ///
  /// [blockUri] The URI of the block record to delete
  Future<void> unblockUser(AtUri blockUri);

  /// Toggle block status for a user
  ///
  /// [did] The DID of the user to toggle block for
  /// [currentBlockUri] The current block URI if blocking, null if not blocking
  /// Returns the block URI if now blocking, null if unblocked
  Future<String?> toggleBlock(String did, AtUri? currentBlockUri);
}
