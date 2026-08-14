import 'package:bluesky_poptart/app/bsky/feed/defs.dart' as bsky_feed_defs;
import 'package:bluesky_poptart/app/bsky/feed/search_posts.dart'
    as bsky_feed_search_posts;
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

typedef PostSearchPage = ({List<PostView> posts, String? cursor});
typedef InitialPostSearchResult = ({PostSearchPage sprk, PostSearchPage bsky});

abstract interface class PostSearchRepository {
  Future<InitialPostSearchResult> search(String query);

  Future<PostSearchPage> searchSprk(String query, {required String cursor});

  Future<PostSearchPage> searchBsky(String query, {required String cursor});
}

class PostSearchRepositoryImpl implements PostSearchRepository {
  PostSearchRepositoryImpl(
    this._feedRepository,
    this._sprkRepository,
    this._logger,
  );

  final FeedRepository _feedRepository;
  final SprkRepository _sprkRepository;
  final SparkLogger _logger;

  @override
  Future<InitialPostSearchResult> search(String query) async {
    final sprkFuture = _feedRepository.searchPosts(query);
    final bskyFuture = _searchBsky(query, sort: 'top');
    final pages = await Future.wait<PostSearchPage>([sprkFuture, bskyFuture]);
    return (sprk: pages[0], bsky: pages[1]);
  }

  @override
  Future<PostSearchPage> searchSprk(String query, {required String cursor}) {
    return _feedRepository.searchPosts(query, cursor: cursor);
  }

  @override
  Future<PostSearchPage> searchBsky(String query, {required String cursor}) {
    return _searchBsky(query, cursor: cursor, sort: 'latest');
  }

  Future<PostSearchPage> _searchBsky(
    String query, {
    String? cursor,
    required String sort,
  }) async {
    return _sprkRepository.executeWithRetry(() async {
      final atproto = _sprkRepository.authRepository.atproto;
      if (!_sprkRepository.authRepository.isAuthenticated || atproto == null) {
        throw StateError('Post search requires an authenticated session');
      }
      final response = await atproto.call(
        bsky_feed_search_posts.appBskyFeedSearchPosts,
        parameters: bsky_feed_search_posts.FeedSearchPostsInput(
          q: query,
          sort: bsky_feed_search_posts.FeedSearchPostsSort.unknown(data: sort),
          cursor: cursor,
        ),
        headers: _sprkRepository.appViewHeaders(_sprkRepository.bskyDid),
      );
      return (
        posts: _convertBskyPosts(response.data.posts),
        cursor: response.data.cursor,
      );
    });
  }

  List<PostView> _convertBskyPosts(List<bsky_feed_defs.PostView> posts) {
    return posts
        .asMap()
        .entries
        .map((entry) {
          final post = entry.value;
          try {
            final postJson = post.toJson();
            if (postJson['record']['reply'] != null || post.embed == null) {
              return null;
            }
            return PostView.fromJson(postJson);
          } catch (error, stackTrace) {
            _logger.e(
              'Failed to convert bsky post ${entry.key + 1}/${posts.length}',
              error: error,
              stackTrace: stackTrace,
            );
            return null;
          }
        })
        .whereType<PostView>()
        .where((post) => post.hasSupportedMedia)
        .toList();
  }
}
