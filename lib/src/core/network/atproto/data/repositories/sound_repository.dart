import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';

abstract class SoundRepository {
  /// Create a new sound record.
  ///
  /// [sound] The audio blob to create the sound from.
  /// [title] The title of the sound.
  /// [details] Optional audio details (artist, title metadata).
  /// Returns a [StrongRef] to the created sound record.
  Future<StrongRef> createSound({
    required Blob sound,
    required String title,
    AudioDetails? details,
  });

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

  /// Get a list of trending audios.
  ///
  /// [limit] The number of items to return (default 50, max 100).
  /// [cursor] Pagination cursor for the next set of results.
  Future<TrendingAudiosResponse> getTrendingAudios({
    int limit = 50,
    String? cursor,
  });
}
