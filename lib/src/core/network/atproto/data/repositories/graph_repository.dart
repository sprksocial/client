import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:sprk_poptart/so/sprk/graph/get_blocks/output.dart';
import 'package:sprk_poptart/so/sprk/graph/get_followers/output.dart';
import 'package:sprk_poptart/so/sprk/graph/get_follows/output.dart';
import 'package:sprk_poptart/so/sprk/graph/get_known_followers/output.dart';

/// Interface for Graph-related API endpoints
abstract class GraphRepository {
  /// Get followers for a DID
  ///
  /// [did] The DID to get followers for
  /// [cursor] Optional cursor for pagination
  Future<GraphGetFollowersOutput> getFollowers(String did, {String? cursor});

  /// Get followers for a DID who are followed by the viewer
  ///
  /// [did] The DID to get known followers for
  /// [cursor] Optional cursor for pagination
  Future<GraphGetKnownFollowersOutput> getKnownFollowers(
    String did, {
    String? cursor,
  });

  /// Get follows for a DID
  ///
  /// [did] The DID to get follows for
  /// [cursor] Optional cursor for pagination
  Future<GraphGetFollowsOutput> getFollows(String did, {String? cursor});

  /// Follow a user
  ///
  /// [did] The DID of the user to follow
  /// [bsky] Whether to use Bluesky follow records instead of Spark
  Future<RepoStrongRef> followUser(String did, {bool bsky = false});

  /// Unfollow a user
  ///
  /// [followUri] The URI of the follow record to delete
  Future<void> unfollowUser(AtUri followUri);

  /// Get blocks for a DID
  ///
  /// [did] The DID to get blocks for
  /// [cursor] Optional cursor for pagination
  Future<GraphGetBlocksOutput> getBlocks(String did, {String? cursor});

  /// Block a user
  ///
  /// [did] The DID of the user to block
  Future<RepoStrongRef> blockUser(String did);

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
