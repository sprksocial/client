import 'package:atproto_core/atproto_core.dart';

/// Callback type for deleting a record
typedef DeleteRecordCallback =
    Future<void> Function({
      required String repo,
      required String collection,
      required String rkey,
    });

/// Adapter for Bluesky repository operations
///
/// Handles Bluesky-specific repository operations like cross-post management
/// and URI conversions between Spark and Bluesky namespaces.
class BskyRepoAdapter {
  const BskyRepoAdapter();

  // ============================================================================
  // Bluesky Cross-Post Handling
  // ============================================================================

  /// Build a Bluesky counterpart URI from a Spark post URI
  ///
  /// Converts `at://did/so.sprk.feed.post/rkey` to `at://did/app.bsky.feed.post/rkey`
  AtUri buildBlueskyCounterpartUri(AtUri sparkUri) {
    final did = sparkUri.hostname;
    final rkey = sparkUri.rkey;
    return AtUri.parse('at://$did/app.bsky.feed.post/$rkey');
  }

  /// Delete the Bluesky counterpart of a Spark post
  ///
  /// This is a best-effort operation - errors are caught and returned as false.
  /// Returns true if deletion was successful, false otherwise.
  ///
  /// [deleteRecord] is a callback that performs the actual deletion (typically atproto.repo.deleteRecord)
  Future<bool> deleteBlueskyCounterpart(
    DeleteRecordCallback deleteRecord,
    AtUri sparkUri,
  ) async {
    try {
      final blueskyUri = buildBlueskyCounterpartUri(sparkUri);
      await deleteRecord(
        repo: blueskyUri.hostname,
        collection: blueskyUri.collection.toString(),
        rkey: blueskyUri.rkey,
      );
      return true;
    } catch (e) {
      // Ignore errors like 404 – it simply means the counterpart does not exist.
      return false;
    }
  }

  /// Check if a URI is a Bluesky feed post
  bool isBlueskyFeedPost(AtUri uri) {
    return uri.collection.toString() == 'app.bsky.feed.post';
  }

  /// Check if a URI is a Spark feed post
  bool isSparkFeedPost(AtUri uri) {
    return uri.collection.toString() == 'so.sprk.feed.post';
  }
}

/// Singleton instance of the Bluesky repo adapter
///
/// Use this instance for all Bluesky repository operations:
/// ```dart
/// final blueskyUri = bskyRepoAdapter.buildBlueskyCounterpartUri(sparkUri);
/// await bskyRepoAdapter.deleteBlueskyCounterpart(repoService, sparkUri);
/// ```
const bskyRepoAdapter = BskyRepoAdapter();
