import 'package:atproto_core/atproto_core.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';

abstract class SoundRepository {
  /// Get a list of posts that use a given audio (by AT-URI).
  ///
  /// [uri] Audio AT-URI to find referencing posts for.
  /// [limit] The number of items to return (default 50, max 100).
  /// [cursor] Pagination cursor for the next set of results.
  Future<AudioPostsResponse> getAudioPosts(
    AtUri uri, {
    int limit = 50,
    String? cursor,
  });
}
