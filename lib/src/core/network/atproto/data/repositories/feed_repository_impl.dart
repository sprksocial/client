import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart_lex/com/atproto/label/query_labels.dart'
    as label_query_labels;
import 'package:bluesky_poptart/app/bsky/feed/get_author_feed.dart'
    as bsky_feed_get_author_feed;
import 'package:bluesky_poptart/app/bsky/feed/get_feed.dart'
    as bsky_feed_get_feed;
import 'package:bluesky_poptart/app/bsky/feed/get_feed_generator.dart'
    as bsky_feed_get_feed_generator;
import 'package:bluesky_poptart/app/bsky/feed/get_feed_generators.dart'
    as bsky_feed_get_feed_generators;
import 'package:bluesky_poptart/app/bsky/feed/get_posts.dart'
    as bsky_feed_get_posts;
import 'package:bluesky_poptart/app/bsky/feed/get_post_thread.dart'
    as bsky_feed_get_post_thread;
import 'package:bluesky_poptart/app/bsky/feed/get_suggested_feeds.dart'
    as bsky_feed_get_suggested_feeds;
import 'package:bluesky_poptart/app/bsky/feed/like.dart' as bsky_like;
import 'package:bluesky_poptart/app/bsky/feed/repost.dart' as bsky_repost;
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:poptart_lex/com/atproto/repo/upload_blob.dart'
    as repo_upload_blob;
import 'package:poptart/poptart.dart';
import 'package:bluesky_poptart/app/bsky/richtext/facet.dart';

import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:spark/src/core/network/atproto/data/adapters/bsky/feed_adapter.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/models/record_write_adapters.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/network/atproto/data/services/video_upload_service.dart';
import 'package:spark/src/core/utils/bluesky_crosspost_text.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/core/utils/share_urls.dart';
import 'package:sprk_poptart/so/sprk/feed/like.dart' as sprk_like;
import 'package:sprk_poptart/so/sprk/feed/get_author_feed.dart'
    as sprk_get_author_feed;
import 'package:sprk_poptart/so/sprk/feed/get_actor_likes.dart'
    as sprk_get_actor_likes;
import 'package:sprk_poptart/so/sprk/feed/get_actor_reposts.dart'
    as sprk_get_actor_reposts;
import 'package:sprk_poptart/so/sprk/feed/get_crosspost_thread.dart'
    as sprk_get_crosspost_thread;
import 'package:sprk_poptart/so/sprk/feed/get_feed.dart' as sprk_get_feed;
import 'package:sprk_poptart/so/sprk/feed/get_feed_generator.dart'
    as sprk_get_feed_generator;
import 'package:sprk_poptart/so/sprk/feed/get_feed_generators.dart'
    as sprk_get_feed_generators;
import 'package:sprk_poptart/so/sprk/feed/get_likes.dart' as sprk_get_likes;
import 'package:sprk_poptart/so/sprk/feed/get_posts.dart' as sprk_get_posts;
import 'package:sprk_poptart/so/sprk/feed/get_post_thread.dart'
    as sprk_get_post_thread;
import 'package:sprk_poptart/so/sprk/feed/get_suggested_feeds.dart'
    as sprk_get_suggested_feeds;
import 'package:sprk_poptart/so/sprk/feed/get_timeline.dart'
    as sprk_get_timeline;
import 'package:sprk_poptart/so/sprk/feed/repost.dart' as sprk_repost;
import 'package:sprk_poptart/so/sprk/feed/search_posts.dart'
    as sprk_search_posts;

/// Implementation of Feed-related API endpoints
class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(
    this._client, {
    SparkLogger? logger,
    DateTime Function()? now,
    VideoUploadService? videoUploadService,
  }) : _logger =
           logger ?? GetIt.instance<LogService>().getLogger('FeedRepository'),
       _now = now ?? DateTime.now {
    _videoUploadService =
        videoUploadService ??
        VideoUploadClient(_client.authRepository, logger: _logger, now: _now);
    _logger.v('FeedRepository initialized');
  }
  final SprkRepository _client;
  final SparkLogger _logger;
  final DateTime Function() _now;
  late final VideoUploadService _videoUploadService;

  /// Formats labeler DIDs into the atproto-accept-labelers header format
  /// Format: "did1,did2,did3" (comma-separated list)
  String _formatLabelerHeader(List<String> labelerDids) {
    return labelerDids.join(',');
  }

  bool _postViewHasMedia(PostView post) => post.hasSupportedMedia;

  bool _feedViewPostHasMedia(FeedViewPost feedViewPost) {
    return feedViewPost.localPost.hasSupportedMedia;
  }

  AtUri _getPostViewUri(PostView post) => post.uri;

  AtUri _getFeedViewPostUri(FeedViewPost feedViewPost) => feedViewPost.uri;

  List<T> _parseAndFilterPosts<T>({
    required List<dynamic> rawPosts,
    required T Function(Map<String, dynamic>) fromJson,
    required bool Function(T) hasMedia,
    required AtUri Function(T) getUri,
    required String source,
  }) {
    final posts = <T>[];

    for (final rawPost in rawPosts) {
      try {
        final Map<String, dynamic> postData;
        if (rawPost is Map<String, dynamic>) {
          postData = rawPost;
        } else {
          final json = rawPost.toJson();
          if (json is! Map<String, dynamic>) {
            _logger.w(
              'Unexpected post data type: ${json.runtimeType}, skipping',
            );
            continue;
          }
          postData = json;
        }

        // Fix missing $type field for FeedViewPost union type
        if ((postData[r'$type'] as String?) == null) {
          if (postData.containsKey('post') == true) {
            postData[r'$type'] = 'so.sprk.feed.defs#feedPostView';
          } else if (postData.containsKey('reply') == true) {
            postData[r'$type'] = 'so.sprk.feed.defs#feedReplyView';
          }
        }

        final parsedPost = fromJson(postData);

        if (hasMedia(parsedPost)) {
          posts.add(parsedPost);
        }
      } catch (e) {
        _logger.w('Failed to parse $source post, skipping: $e');
      }
    }

    return posts;
  }

  @override
  Future<FeedView> getFeed(
    Feed feed, {
    int limit = 20,
    String? cursor,
    List<String>? labelerDids,
  }) async {
    _logger.d(
      'Getting feed skeleton for feed: $feed, limit: $limit, cursor: $cursor',
    );
    if (feed.view == null) {
      if (feed.type == 'timeline') {
        return getTimeline(
          limit: limit,
          cursor: cursor,
          labelerDids: labelerDids,
        );
      }
      // For custom feeds, fetch the feed generator view first
      final feedUri = AtUri(feed.config.value);
      final view = await getFeedGenerator(feedUri);
      // Update the feed with the view and continue
      final feedWithView = Feed(
        type: feed.type,
        config: feed.config,
        view: view,
      );
      return _client.executeWithRetry(() async {
        final result = await getFeedView(
          feedWithView.view!.uri,
          limit: limit,
          cursor: cursor,
          labelerDids: labelerDids,
        );
        _logger.d('Feed skeleton retrieved successfully');
        return result;
      });
    }
    return _client.executeWithRetry(() async {
      final result = await getFeedView(
        feed.view!.uri,
        limit: limit,
        cursor: cursor,
        labelerDids: labelerDids,
      );
      _logger.d('Feed skeleton retrieved successfully');
      return result;
    });
  }

  @override
  Future<List<PostView>> getPosts(
    List<AtUri> uris, {
    bool bluesky = false,
    bool filter = true,
  }) async {
    _logger.d('Getting posts for URIs: ${uris.length} URIs');
    if (bluesky) {
      _logger.d('Getting posts on bluesky API for: ${uris.length} URIs');
      final oauthSession = _client.authRepository.atproto?.oAuthSession;
      if (oauthSession == null) {
        throw Exception('No OAuth session available');
      }
      final blueskyClient = PoptartClient.fromOAuthSession(oauthSession);
      final posts = await blueskyClient.call(
        bsky_feed_get_posts.appBskyFeedGetPosts,
        parameters: bsky_feed_get_posts.FeedGetPostsInput(uris: uris),
      );

      // Use adapter to process Bluesky posts
      return bskyFeedAdapter.processBskyPosts(
        rawPosts: posts.data.posts,
        filterByMedia: filter,
      );
    }
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final headers = <String, String>{'atproto-proxy': _client.sprkDid};
      // Note: labeler header could be added here if needed for getPosts

      final result = await atproto.call(
        sprk_get_posts.soSprkFeedGetPosts,
        parameters: sprk_get_posts.FeedGetPostsInput(uris: uris),
        headers: headers,
      );
      final posts = result.data.toJson()['posts']! as List<dynamic>;
      _logger.d(
        'Raw API response for first post: '
        '${posts.isNotEmpty ? posts[0] : "empty"}',
      );
      final parsedPosts = _parseAndFilterPosts<PostView>(
        rawPosts: posts,
        fromJson: PostView.fromJson,
        hasMedia: _postViewHasMedia,
        getUri: _getPostViewUri,
        source: 'sprk',
      );
      _logger.d('Posts retrieved successfully: ${parsedPosts.length} posts');
      if (parsedPosts.isNotEmpty) {
        _logger.d(
          'First post replyCount: ${parsedPosts.first.replyCount}, '
          'likeCount: ${parsedPosts.first.likeCount}',
        );
      }

      return parsedPosts;
    });
  }

  @override
  Future<({List<FeedViewPost> posts, String? cursor})> getAuthorFeed(
    AtUri actorUri, {
    int limit = 20,
    String? cursor,
    bool videosOnly = false,
    bool bluesky = false,
  }) async {
    _logger.d(
      'Getting author feed for actor: $actorUri, limit: $limit, '
      'cursor: $cursor, bluesky: $bluesky',
    );

    if (bluesky) {
      return _getAuthorFeedFromBluesky(
        actorUri,
        limit: limit,
        cursor: cursor,
        videosOnly: videosOnly,
      );
    }

    return _getAuthorFeedFromSpark(
      actorUri,
      limit: limit,
      cursor: cursor,
      videosOnly: videosOnly,
    );
  }

  /// Get author feed from Spark API with fallback to Bluesky
  Future<({List<FeedViewPost> posts, String? cursor})> _getAuthorFeedFromSpark(
    AtUri actorUri, {
    required int limit,
    required String? cursor,
    required bool videosOnly,
  }) async {
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      try {
        final result = await atproto.call(
          sprk_get_author_feed.soSprkFeedGetAuthorFeed,
          parameters: sprk_get_author_feed.FeedGetAuthorFeedInput(
            actor: actorUri.hostname,
            limit: limit,
            cursor: cursor,
            filter: videosOnly
                ? sprk_get_author_feed.FeedGetAuthorFeedFilter.valueOf(
                    'posts_with_video',
                  )
                : null,
          ),
          headers: {'atproto-proxy': _client.sprkDid},
        );
        final output = result.data;
        final outputJson = output.toJson();
        final rawFeed = outputJson['feed']! as List<dynamic>;
        final feedPosts = _parseAndFilterPosts<FeedViewPost>(
          rawPosts: rawFeed,
          fromJson: FeedViewPost.fromJson,
          hasMedia: _feedViewPostHasMedia,
          getUri: _getFeedViewPostUri,
          source: 'sprk author feed',
        );
        _logger.d('Author feed retrieved successfully from Sprk');
        return (posts: feedPosts, cursor: output.cursor);
      } catch (e) {
        _logger.e(
          'Error getting author feed from Sprk. Trying Bsky...',
          error: e,
        );
        return _getAuthorFeedFromBluesky(
          actorUri,
          limit: limit,
          cursor: cursor,
          videosOnly: videosOnly,
        );
      }
    });
  }

  /// Get author feed directly from Bluesky API
  Future<({List<FeedViewPost> posts, String? cursor})>
  _getAuthorFeedFromBluesky(
    AtUri actorUri, {
    required int limit,
    required String? cursor,
    required bool videosOnly,
  }) async {
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      try {
        final oauthSession = _client.authRepository.atproto?.oAuthSession;
        if (oauthSession == null) {
          throw Exception('No OAuth session available');
        }
        final resultBsky = await PoptartClient.fromOAuthSession(oauthSession)
            .call(
              bsky_feed_get_author_feed.appBskyFeedGetAuthorFeed,
              parameters: bsky_feed_get_author_feed.FeedGetAuthorFeedInput(
                actor: actorUri.hostname,
                limit: limit,
                cursor: cursor,
                filter:
                    bsky_feed_get_author_feed.FeedGetAuthorFeedFilter.valueOf(
                      videosOnly ? 'posts_with_video' : 'posts_with_media',
                    ),
              ),
            );

        // Use adapter to process Bluesky author feed
        return bskyFeedAdapter.processBskyAuthorFeed(
          rawFeed: resultBsky.data.feed,
          cursor: resultBsky.data.cursor,
          onError: _logger.e,
        );
      } catch (e) {
        _logger.e('Error getting author feed from Bsky', error: e);
        rethrow;
      }
    });
  }

  @override
  Future<FeedView> getTimeline({
    int limit = 20,
    String? cursor,
    List<String>? labelerDids,
  }) async {
    _logger.d('Getting timeline feed, limit: $limit, cursor: $cursor');
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final headers = <String, String>{'atproto-proxy': _client.sprkDid};
      if (labelerDids != null && labelerDids.isNotEmpty) {
        headers['atproto-accept-labelers'] = _formatLabelerHeader(labelerDids);
      }

      final result = await atproto.call(
        sprk_get_timeline.soSprkFeedGetTimeline,
        parameters: sprk_get_timeline.FeedGetTimelineInput(
          limit: limit,
          cursor: cursor,
        ),
        headers: headers,
      );
      final output = result.data;
      final feedData = output.toJson()['feed'] as List<dynamic>;

      final feedPosts = <FeedViewPost>[];
      for (final item in feedData) {
        try {
          final itemMap = item as Map<String, dynamic>;

          // Response has 'post' object containing fully hydrated post view
          final postMap = itemMap['post'] as Map<String, dynamic>?;
          if (postMap == null) {
            continue;
          }
          final postView = PostView.fromJson(postMap);

          final feedViewPost = feedViewPostFromPost(postView);
          feedPosts.add(feedViewPost);
        } catch (e, stackTrace) {
          _logger.w(
            'Failed to parse timeline feed item, skipping: $e',
            stackTrace: stackTrace,
          );
        }
      }

      final feedView = FeedView(feed: feedPosts, cursor: output.cursor);

      _logger.d(
        'Timeline feed retrieved successfully: '
        '${feedView.feed.length} posts',
      );
      return feedView;
    });
  }

  @override
  Future<FeedView> getFeedView(
    AtUri feedUri, {
    int limit = 20,
    String? cursor,
    List<String>? labelerDids,
  }) async {
    _logger.d('Getting feed for URI: $feedUri, limit: $limit, cursor: $cursor');
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final isBskyFeed =
          feedUri.collection == NSID.parse('app.bsky.feed.generator');

      final headers = <String, String>{
        'atproto-proxy': isBskyFeed ? _client.bskyDid : _client.sprkDid,
      };
      if (!isBskyFeed && labelerDids != null && labelerDids.isNotEmpty) {
        headers['atproto-accept-labelers'] = _formatLabelerHeader(labelerDids);
      }

      final FeedView feedView;
      if (isBskyFeed) {
        final result = await atproto.call(
          bsky_feed_get_feed.appBskyFeedGetFeed,
          parameters: bsky_feed_get_feed.FeedGetFeedInput(
            feed: feedUri,
            limit: limit,
            cursor: cursor,
          ),
          headers: headers,
        );
        final processedFeed = bskyFeedAdapter.processBskyAuthorFeed(
          rawFeed: result.data.feed,
          cursor: result.data.cursor,
          onError: (message, {error, stackTrace}) => _logger.w(
            error == null ? message : '$message: $error',
            stackTrace: stackTrace,
          ),
        );
        feedView = FeedView(
          feed: processedFeed.posts,
          cursor: processedFeed.cursor,
        );
      } else {
        final result = await atproto.call(
          sprk_get_feed.soSprkFeedGetFeed,
          parameters: sprk_get_feed.FeedGetFeedInput(
            feed: feedUri,
            limit: limit,
            cursor: cursor,
          ),
          headers: headers,
        );
        final output = result.data;
        final feedData = output.feed;
        final feedPosts = <FeedViewPost>[];
        for (final item in feedData) {
          try {
            final feedViewPost = feedViewPostFromPost(item.post);
            feedPosts.add(feedViewPost);
          } catch (e, stackTrace) {
            _logger.w(
              'Failed to parse feed item, skipping: $e',
              stackTrace: stackTrace,
            );
          }
        }

        feedView = FeedView(feed: feedPosts, cursor: output.cursor);
      }

      _logger.d('Feed retrieved successfully: ${feedView.feed.length} posts');
      return feedView;
    });
  }

  @override
  Future<GeneratorView> getFeedGenerator(AtUri feed) async {
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }
      final isBskyFeed =
          feed.collection == NSID.parse('app.bsky.feed.generator');

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final headers = isBskyFeed
          ? {'atproto-proxy': _client.bskyDid}
          : {'atproto-proxy': _client.sprkDid};
      if (isBskyFeed) {
        final response = await atproto.call(
          bsky_feed_get_feed_generator.appBskyFeedGetFeedGenerator,
          parameters: bsky_feed_get_feed_generator.FeedGetFeedGeneratorInput(
            feed: feed,
          ),
          headers: headers,
        );
        final jsonMap = response.data.toJson();
        final generatorData = jsonMap.containsKey('view')
            ? jsonMap['view']! as Map<String, dynamic>
            : jsonMap;
        return GeneratorView.fromJson(generatorData);
      }

      final response = await atproto.call(
        sprk_get_feed_generator.soSprkFeedGetFeedGenerator,
        parameters: sprk_get_feed_generator.FeedGetFeedGeneratorInput(
          feed: feed,
        ),
        headers: headers,
      );
      return GeneratorView.fromJson(response.data.view.toJson());
    });
  }

  @override
  Future<List<GeneratorView>> getFeedGenerators(
    List<AtUri> feeds, {
    bool bluesky = false,
  }) async {
    _logger.d(
      'Getting feed generators for ${feeds.length} feeds, bluesky: $bluesky',
    );
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final headers = bluesky
          ? {'atproto-proxy': _client.bskyDid}
          : {'atproto-proxy': _client.sprkDid};
      final List<dynamic> feedsData;
      if (bluesky) {
        final response = await atproto.call(
          bsky_feed_get_feed_generators.appBskyFeedGetFeedGenerators,
          parameters: bsky_feed_get_feed_generators.FeedGetFeedGeneratorsInput(
            feeds: feeds,
          ),
          headers: headers,
        );
        feedsData = response.data.toJson()['feeds']! as List<dynamic>;
      } else {
        final response = await atproto.call(
          sprk_get_feed_generators.soSprkFeedGetFeedGenerators,
          parameters: sprk_get_feed_generators.FeedGetFeedGeneratorsInput(
            feeds: feeds,
          ),
          headers: headers,
        );
        feedsData = response.data.toJson()['feeds']! as List<dynamic>;
      }
      final generators = feedsData
          .map((feedData) {
            try {
              final feedMap = feedData as Map<String, dynamic>;
              return GeneratorView.fromJson(feedMap);
            } catch (e) {
              _logger.w('Failed to parse feed generator, skipping: $e');
              return null;
            }
          })
          .whereType<GeneratorView>()
          .toList();
      _logger.d(
        'Feed generators retrieved successfully: '
        '${generators.length} generators',
      );
      return generators;
    });
  }

  @override
  Future<List<GeneratorView>> getSuggestedFeeds({bool bluesky = false}) async {
    _logger.d('Getting suggested feeds, bluesky: $bluesky');
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final headers = bluesky
          ? {'atproto-proxy': _client.bskyDid}
          : {'atproto-proxy': _client.sprkDid};
      final List<dynamic> feedsData;
      if (bluesky) {
        final response = await atproto.call(
          bsky_feed_get_suggested_feeds.appBskyFeedGetSuggestedFeeds,
          headers: headers,
        );
        feedsData = response.data.toJson()['feeds'] as List<dynamic>? ?? [];
      } else {
        final response = await atproto.call(
          sprk_get_suggested_feeds.soSprkFeedGetSuggestedFeeds,
          headers: headers,
        );
        feedsData = response.data.toJson()['feeds'] as List<dynamic>? ?? [];
      }
      final suggestedFeeds = feedsData
          .map((feedData) {
            try {
              final feedMap = feedData as Map<String, dynamic>;
              return GeneratorView.fromJson(feedMap);
            } catch (e) {
              _logger.w(
                'Failed to parse suggested feed generator, skipping: $e',
              );
              return null;
            }
          })
          .whereType<GeneratorView>()
          .toList();
      _logger.d(
        'Suggested feeds retrieved successfully: '
        '${suggestedFeeds.length} generators',
      );
      return suggestedFeeds;
    });
  }

  @override
  Future<Feed> getFeedFromSavedFeed(SavedFeed savedFeed) async {
    return _client.executeWithRetry(() async {
      if (savedFeed.typeValue == 'timeline') {
        return Feed(type: 'timeline', config: savedFeed);
      }
      final feedUri = AtUri(savedFeed.value);
      final view = await getFeedGenerator(feedUri);
      return Feed(type: 'feed', config: savedFeed, view: view);
    });
  }

  @override
  Future<List<Feed>> getFeedsFromSavedFeeds(List<SavedFeed> savedFeeds) async {
    return _client.executeWithRetry(() async {
      if (savedFeeds.isEmpty) {
        return [];
      }

      final bskyUris = <AtUri>[];
      final sprkUris = <AtUri>[];

      for (final savedFeed in savedFeeds) {
        if (savedFeed.typeValue == 'timeline') {
          // Timeline feeds don't need generator views
          continue;
        }
        final feedUri = AtUri(savedFeed.value);
        final isBskyFeed =
            feedUri.collection == NSID.parse('app.bsky.feed.generator');
        if (isBskyFeed) {
          bskyUris.add(feedUri);
        } else {
          sprkUris.add(feedUri);
        }
      }

      // Batch fetch all generator views
      final bskyViewsFuture = bskyUris.isNotEmpty
          ? getFeedGenerators(bskyUris, bluesky: true)
          : Future.value(<GeneratorView>[]);
      final sprkViewsFuture = sprkUris.isNotEmpty
          ? getFeedGenerators(sprkUris)
          : Future.value(<GeneratorView>[]);

      final bskyViews = await bskyViewsFuture;
      final sprkViews = await sprkViewsFuture;

      // Create view maps for quick lookup
      final bskyViewMap = {for (final view in bskyViews) view.uri: view};
      final sprkViewMap = {for (final view in sprkViews) view.uri: view};

      // Build feeds list preserving the original order from savedFeeds
      final feeds = <Feed>[];
      for (final savedFeed in savedFeeds) {
        if (savedFeed.typeValue == 'timeline') {
          feeds.add(Feed(type: 'timeline', config: savedFeed));
        } else {
          final feedUri = AtUri(savedFeed.value);
          final isBskyFeed =
              feedUri.collection == NSID.parse('app.bsky.feed.generator');
          final viewMap = isBskyFeed ? bskyViewMap : sprkViewMap;
          final view = viewMap[feedUri];
          if (view != null) {
            feeds.add(Feed(type: 'feed', config: savedFeed, view: view));
          } else {
            _logger.w(
              'Feed generator view not found for '
              '${isBskyFeed ? 'Bluesky' : 'Spark'} feed: $feedUri',
            );
            // Fallback: create feed without view
            feeds.add(Feed(type: 'feed', config: savedFeed));
          }
        }
      }

      return feeds;
    });
  }

  @override
  Future<RepoStrongRef> likePost(String postCid, AtUri postUri) async {
    _logger.d('Liking post with String: $postCid, URI: $postUri');

    return _client.executeWithRetry(() async {
      // Determine if this is a Bluesky post or Spark post
      final isBskyPost = postUri.collection.toString().startsWith(
        'app.bsky.feed.post',
      );
      final likeType = isBskyPost ? 'app.bsky.feed.like' : 'so.sprk.feed.like';

      _logger.d(
        'Post type: ${isBskyPost ? 'Bluesky' : 'Spark'}, using collection: '
        '$likeType',
      );

      final subject = RepoStrongRef(uri: postUri, cid: postCid);
      final createdAt = _now().toUtc();
      final likeRecord = isBskyPost
          ? bsky_like.FeedLikeRecord(
              subject: subject,
              createdAt: createdAt,
            ).toJson()
          : sprk_like.FeedLikeRecord(
              subject: subject,
              createdAt: createdAt,
            ).toJson();

      final result = await _client.repo.createRecord(
        collection: likeType,
        record: likeRecord,
      );
      _logger.i('Post liked successfully: ${result.uri}');

      return result;
    });
  }

  @override
  Future<void> unlikePost(AtUri likeUri) async {
    _logger.d('Unliking post with like URI: $likeUri');
    return _client.executeWithRetry(() async {
      await _client.repo.deleteRecord(
        uri: likeUri,
        skipBskyCrosspostCleanup: true,
      );
      _logger.i('Post unliked successfully');
    });
  }

  @override
  Future<RepoStrongRef> repostPost(String postCid, AtUri postUri) async {
    _logger.d('Reposting post with CID: $postCid, URI: $postUri');

    return _client.executeWithRetry(() async {
      // Determine if this is a Bluesky post or Spark post
      final isBskyPost = postUri.collection.toString().startsWith(
        'app.bsky.feed.post',
      );
      final repostType = isBskyPost
          ? 'app.bsky.feed.repost'
          : 'so.sprk.feed.repost';

      _logger.d(
        'Post type: ${isBskyPost ? 'Bluesky' : 'Spark'}, using collection: '
        '$repostType',
      );

      final subject = RepoStrongRef(uri: postUri, cid: postCid);
      final createdAt = _now().toUtc();
      final repostRecord = isBskyPost
          ? bsky_repost.FeedRepostRecord(
              subject: subject,
              createdAt: createdAt,
            ).toJson()
          : sprk_repost.FeedRepostRecord(
              subject: subject,
              createdAt: createdAt,
            ).toJson();

      final result = await _client.repo.createRecord(
        collection: repostType,
        record: repostRecord,
      );
      _logger.i('Post reposted successfully: ${result.uri}');

      return result;
    });
  }

  @override
  Future<void> unrepostPost(AtUri repostUri) async {
    _logger.d('Unreposting post with repost URI: $repostUri');
    return _client.executeWithRetry(() async {
      await _client.repo.deleteRecord(
        uri: repostUri,
        skipBskyCrosspostCleanup: true,
      );
      _logger.i('Post unreposted successfully');
    });
  }

  @override
  Future<RepoStrongRef> postComment(
    String text,
    String parentCid,
    AtUri parentUri, {
    String? rootCid,
    AtUri? rootUri,
    List<XFile>? imageFiles,
    Map<String, String>? altTexts,
    List<Facet> facets = const [],
  }) async {
    _logger.d('Posting comment to parent: $parentUri');

    if (!_client.authRepository.isAuthenticated) {
      _logger.w('Not authenticated');
      throw Exception('Not authenticated');
    }

    if (_client.authRepository.atproto == null) {
      _logger.e('AtProto not initialized');
      throw Exception('AtProto not initialized');
    }

    // Use parent as root if not provided
    final effectiveRootCid = rootCid ?? parentCid;
    final effectiveRootUri = rootUri ?? parentUri;

    // Upload image if provided (replies only support single image)
    Map<String, dynamic>? mediaJson;
    if (imageFiles case final List<XFile> files when files.isNotEmpty) {
      if (files.length > 1) {
        _logger.w('Replies only support single image, using first image only');
      }
      final uploadedImageMaps = await uploadImages(
        imageFiles: [files.first],
        altTexts: altTexts,
      );
      final firstImage = uploadedImageMaps.first;
      mediaJson = Media.image(
        image: firstImage.image,
        alt: firstImage.alt,
      ).toJson();
    }

    // Create the correct record JSON depending on the target platform.
    final isSprk = parentUri.collection == NSID.parse('so.sprk.feed.post');

    final Map<String, dynamic> recordJson;
    final NSID collection;

    if (isSprk) {
      // Sprk comment
      final media = mediaJson != null ? Media.fromJson(mediaJson) : null;

      // Validate that videos are not allowed in replies
      if (media != null && (media is MediaVideo || media is MediaBskyVideo)) {
        throw Exception('Videos are not allowed in replies');
      }

      final sprkRecord = ReplyRecord(
        caption: CaptionRef(text: text, facets: facets),
        reply: RecordReplyRef(
          root: RepoStrongRef(uri: effectiveRootUri, cid: effectiveRootCid),
          parent: RepoStrongRef(uri: parentUri, cid: parentCid),
        ),
        createdAt: _now().toUtc(),
        media: media,
      );
      recordJson = sprkReplyRecordFromLocal(sprkRecord).toJson();
      collection = NSID.parse('so.sprk.feed.reply');
    } else {
      // Bluesky comment - use adapter to create Bluesky-specific models
      // Validate that videos are not allowed in replies before conversion
      if (mediaJson != null) {
        final media = Media.fromJson(mediaJson);
        if (media is MediaVideo || media is MediaBskyVideo) {
          _logger.e('Videos are not allowed in replies');
          throw Exception('Videos are not allowed in replies');
        }
      }

      final bskyMedia = mediaJson != null
          ? bskyFeedAdapter.convertJsonToBskyEmbed(mediaJson)
          : null;

      // Convert Spark mention facets to Bluesky mention facets
      final bskyFacets = <RichtextFacet>[];
      for (final facet in facets) {
        for (final feature in facet.features) {
          feature.map(
            mention: (m) {
              bskyFacets.add(
                bskyFeedAdapter.createMentionFacet(
                  did: m.did,
                  byteStart: facet.index.byteStart,
                  byteEnd: facet.index.byteEnd,
                ),
              );
            },
            link: (_) {},
            tag: (_) {},
            bskyMention: (_) {},
            bskyLink: (_) {},
            bskyTag: (_) {},
          );
        }
      }

      final bskyRecord = bskyFeedAdapter.createCommentRecord(
        text: text,
        createdAt: _now().toUtc(),
        reply: RecordReplyRef(
          root: RepoStrongRef(uri: effectiveRootUri, cid: effectiveRootCid),
          parent: RepoStrongRef(uri: parentUri, cid: parentCid),
        ),
        embed: bskyMedia,
        facets: bskyFacets.isNotEmpty ? bskyFacets : null,
      );
      recordJson = bskyRecord.toJson();
      collection = NSID.parse('app.bsky.feed.post');
    }

    final result = await _client.repo.createRecord(
      collection: collection.toString(),
      record: recordJson,
    );

    _logger.i('Comment posted successfully: ${result.uri}');

    return result;
  }

  @override
  Future<RepoStrongRef> postImages(
    String text,
    List<XFile> imageFiles,
    Map<String, String> altTexts, {
    bool crosspostToBsky = false,
    List<Facet> facets = const [],
    RepoStrongRef? soundRef,
  }) async {
    if (imageFiles.isEmpty) {
      _logger.e('No images provided for image post');
      throw ArgumentError('At least one image is required for an image post.');
    }

    if (!_client.authRepository.isAuthenticated) {
      _logger.w('Not authenticated');
      throw Exception('Not authenticated');
    }

    if (_client.authRepository.atproto == null) {
      _logger.e('AtProto not initialized');
      throw Exception('AtProto not initialized');
    }

    final uploadedImageMaps = await uploadImages(
      imageFiles: imageFiles,
      altTexts: altTexts,
    );

    // Create Sprk post
    final record = PostRecord(
      caption: CaptionRef(text: text, facets: facets),
      media: Media.images(images: uploadedImageMaps),
      createdAt: _now().toUtc(),
      sound: soundRef,
    );

    final result = await _client.repo.createRecord(
      collection: 'so.sprk.feed.post',
      record: sprkPostRecordFromLocal(record).toJson(),
    );

    _logger.i('Image post created successfully: ${result.uri}');

    var finalResult = result;

    // Crosspost to Bluesky if enabled
    if (crosspostToBsky) {
      try {
        final bskyResult = await _crosspostToBlueSky(
          text,
          uploadedImageMaps,
          result,
          altTexts,
          facets,
        );
        finalResult = await _client.repo.editRecordJson(
          uri: result.uri,
          record: sprkPostRecordFromLocal(
            record.copyWith(crossposts: [bskyResult]),
          ).toJson(),
        );
      } catch (e) {
        _logger.w('Failed to crosspost to Bluesky: $e');
        // Don't fail the entire operation if Bluesky crossposting fails
      }
    }

    return finalResult;
  }

  @override
  Future<List<Image>> uploadImages({
    required List<XFile> imageFiles,
    Map<String, String>? altTexts,
  }) async {
    _logger.d('Processing ${imageFiles.length} images for upload');

    final uploadedImageMaps = <Image>[];
    for (final imageFile in imageFiles) {
      try {
        _logger.d('Processing image: ${imageFile.name}');

        final originalBytes = await imageFile.readAsBytes();

        final processedBytes = await _prepareImageBytesForUpload(
          originalBytes,
          imageName: imageFile.name,
        );

        // Upload the processed image
        switch (_client.authRepository.atproto) {
          case null:
            _logger.e('AtProto not initialized');
            throw Exception('AtProto not initialized');
          case final atproto:
            final response = await atproto.call(
              repo_upload_blob.comAtprotoRepoUploadBlob,
              input: processedBytes,
            );

            switch (response.status.code) {
              case 200:
                // Add the uploaded image to our result list
                uploadedImageMaps.add(
                  Image(
                    alt: altTexts?[imageFile.path] ?? '',
                    image: response.data.blob,
                  ),
                );
              default:
                _logger.e(
                  'Failed to upload image blob: ${response.status.code}',
                );
                throw Exception(
                  'Blob upload failed for ${imageFile.name}: '
                  '${response.status.code}',
                );
            }
        }
      } catch (e) {
        _logger.e(
          'Error processing/uploading image ${imageFile.name}',
          error: e,
        );
        rethrow;
      }
    }

    _logger.d(
      'Successfully processed and uploaded ${uploadedImageMaps.length} images',
    );
    return uploadedImageMaps;
  }

  Future<Uint8List> _prepareImageBytesForUpload(
    Uint8List originalBytes, {
    required String imageName,
  }) async {
    img.Image? decodedImage;
    try {
      decodedImage = img.decodeImage(originalBytes);
      if (decodedImage == null) {
        _logger.w('Failed to decode image $imageName with package:image');
      } else {
        return Uint8List.fromList(img.encodeJpg(decodedImage, quality: 85));
      }
    } catch (e, stackTrace) {
      _logger.w(
        'Error decoding image $imageName with package:image',
        error: e,
        stackTrace: stackTrace,
      );
    }

    final uiProcessedBytes = await _reencodeWithUiCodec(
      originalBytes,
      imageName: imageName,
    );
    if (uiProcessedBytes != null) {
      return uiProcessedBytes;
    }

    throw Exception('Failed to process image $imageName');
  }

  Future<Uint8List?> _reencodeWithUiCodec(
    Uint8List originalBytes, {
    required String imageName,
  }) async {
    ui.Codec? codec;
    ui.Image? image;
    try {
      codec = await ui.instantiateImageCodec(originalBytes);
      final frame = await codec.getNextFrame();
      image = frame.image;

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _logger.w('Failed to encode image $imageName with dart:ui codec');
        return null;
      }
      return byteData.buffer.asUint8List();
    } catch (e, stackTrace) {
      _logger.w(
        'Error processing image $imageName with dart:ui codec',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    } finally {
      image?.dispose();
      codec?.dispose();
    }
  }

  @override
  Future<VideoUploadResult> uploadVideo(
    String videoPath, {
    void Function(double progress)? onUploadProgress,
  }) {
    return _client.executeWithRetry(
      () => _videoUploadService.uploadVideo(
        videoPath,
        onUploadProgress: onUploadProgress,
      ),
    );
  }

  /// Crosspost images to Bluesky using adapter to handle Bluesky-specific model
  Future<RepoStrongRef> _crosspostToBlueSky(
    String text,
    List<Image> sparkImages,
    RepoStrongRef sparkPostData,
    Map<String, String> altTexts,
    List<Facet> sparkFacets,
  ) async {
    _logger.d('Crossposting to Bluesky with ${sparkImages.length} images');

    const maxBskyImages = 4;

    final bskyImages = bskyFeedAdapter.convertImages(
      sparkImages.take(maxBskyImages).toList(),
    );

    final bskyFacets = <RichtextFacet>[];
    final linkUrl = buildSparkShareUrl(sparkPostData.uri.toString());
    final crosspostText = buildBlueskyCrosspostText(
      text: text,
      linkUrl: linkUrl,
    );

    // Convert Spark mention facets to Bluesky mention facets
    for (final facet in sparkFacets) {
      if (facet.index.byteEnd > crosspostText.facetTextByteEnd) {
        continue;
      }

      for (final feature in facet.features) {
        feature.map(
          mention: (m) {
            bskyFacets.add(
              bskyFeedAdapter.createMentionFacet(
                did: m.did,
                byteStart: facet.index.byteStart,
                byteEnd: facet.index.byteEnd,
              ),
            );
          },
          link: (_) {},
          tag: (_) {},
          bskyMention: (_) {},
          bskyLink: (_) {},
          bskyTag: (_) {},
        );
      }
    }

    bskyFacets.add(
      bskyFeedAdapter.createLinkFacet(
        linkUrl: linkUrl,
        byteStart: crosspostText.linkByteStart,
      ),
    );

    final bskyPost = bskyFeedAdapter.createPostRecord(
      text: crosspostText.text,
      createdAt: _now().toUtc(),
      images: bskyImages,
      facets: bskyFacets.isNotEmpty ? bskyFacets : null,
    );

    final bskyResult = await _client.repo.createRecord(
      collection: 'app.bsky.feed.post',
      record: bskyPost.toJson(),
      rkey: sparkPostData.uri.rkey,
    );

    _logger.i('Successfully crossposted to Bluesky: ${bskyResult.uri}');
    return bskyResult;
  }

  @override
  Future<bool> deletePost(AtUri postUri) async {
    _logger.d('Deleting post with URI: $postUri');

    try {
      await _client.repo.deleteRecord(uri: postUri);
      _logger.i('Post deleted successfully: $postUri');
      return true;
    } catch (e) {
      _logger.e('Error deleting post', error: e);
      return false;
    }
  }

  @override
  Future<RepoStrongRef> postVideo(
    Blob blob, {
    String text = '',
    String alt = '',
    List<String>? tags,
    List<String>? langs,
    List<SelfLabel>? selfLabels,
    List<Facet> facets = const [],
    MediaAspectRatio? aspectRatio,
  }) async {
    _logger.d('Posting video with description: $text');

    final record = PostRecord(
      caption: CaptionRef(text: text, facets: facets),
      media: Media.video(video: blob, alt: alt, aspectRatio: aspectRatio),
      createdAt: _now().toUtc(),
      langs: langs,
      selfLabels: selfLabels,
      tags: tags,
    );

    final result = await _client.repo.createRecord(
      collection: 'so.sprk.feed.post',
      record: sprkPostRecordFromLocal(record).toJson(),
    );

    _logger.i('Video posted successfully: ${result.uri}');
    return result;
  }

  @override
  Future<Thread> getThread(
    AtUri uri, {
    int depth = 2,
    int parentHeight = 0,
    bool bluesky = false,
  }) async {
    _logger.d('Getting thread for post: $uri');

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      // Get the post thread
      if (bluesky) {
        final oauthSession = atproto.oAuthSession;
        if (oauthSession == null) {
          throw Exception('No OAuth session available');
        }
        final bluesky = PoptartClient.fromOAuthSession(oauthSession);
        final response = await bluesky.call(
          bsky_feed_get_post_thread.appBskyFeedGetPostThread,
          parameters: bsky_feed_get_post_thread.FeedGetPostThreadInput(
            uri: uri,
            depth: depth,
            parentHeight: parentHeight,
          ),
        );
        // Use adapter to convert Bluesky thread to Spark thread
        return bskyFeedAdapter.convertBskyThreadToSparkThread(
          thread: response.data.thread,
          uri: uri,
        );
      }
      final response = await atproto.call(
        sprk_get_post_thread.soSprkFeedGetPostThread,
        parameters: sprk_get_post_thread.FeedGetPostThreadInput(
          anchor: uri,
          depth: depth,
          parentHeight: parentHeight,
        ),
        headers: {'atproto-proxy': _client.sprkDid},
      );
      final threadItems = response.data.toJson()['thread']! as List<dynamic>;
      return Thread.fromSparkFlatList(threadItems: threadItems);
    });
  }

  @override
  Future<Thread> getCrosspostThread(
    AtUri anchor, {
    int depth = 1,
    int parentHeight = 0,
    String sort = 'newest',
  }) async {
    _logger.d('Getting crosspost thread for anchor: $anchor');

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final threadItems = <dynamic>[];
      String? cursor;

      bool isAnchorItem(dynamic item) {
        if (item is! Map<String, dynamic>) return false;
        return item['depth'] == 0 && item['uri'] == anchor.toString();
      }

      do {
        final response = await atproto.call(
          sprk_get_crosspost_thread.soSprkFeedGetCrosspostThread,
          parameters: sprk_get_crosspost_thread.FeedGetCrosspostThreadInput(
            anchor: anchor,
            depth: depth,
            parentHeight: parentHeight,
            sort: sprk_get_crosspost_thread.FeedGetCrosspostThreadSort.valueOf(
              sort,
            ),
            limit: 100,
            cursor: cursor,
          ),
          headers: {'atproto-proxy': _client.sprkDid},
        );

        final pageItems =
            response.data.toJson()['thread'] as List<dynamic>? ??
            const <dynamic>[];

        var itemsToAppend = pageItems;
        while (threadItems.isNotEmpty &&
            itemsToAppend.isNotEmpty &&
            isAnchorItem(itemsToAppend.first)) {
          itemsToAppend = itemsToAppend.sublist(1);
        }

        threadItems.addAll(itemsToAppend);
        cursor = response.data.cursor;
      } while (cursor != null && cursor.isNotEmpty);

      return Thread.fromSparkFlatList(
        threadItems: threadItems,
        isCrosspostThread: true,
      );
    });
  }

  @override
  Future<({List<Label> labels, String? cursor})> getLabels(
    List<AtUri> uris, {
    List<String>? sources,
    int? limit,
    String? cursor,
  }) async {
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final labels = <Label>[];

      // Use modDid from repository as fallback if no sources provided
      final defaultLabelerDid = _client.modDid.split('#').first;
      final labelers = sources?.isNotEmpty ?? true
          ? sources!
          : [defaultLabelerDid];

      final parameters = label_query_labels.LabelQueryLabelsInput(
        uriPatterns: uris.map((uri) => uri.toString()).toList(),
        sources: labelers,
        limit: limit ?? 50,
        cursor: cursor,
      );

      final response = await atproto.call(
        label_query_labels.comAtprotoLabelQueryLabels,
        headers: {'atproto-proxy': _client.modDid},
        parameters: parameters,
      );
      final responseJson = response.data.toJson();
      _logger
        ..d('parameters: ${parameters.toJson()}')
        ..d('Labels retrieved: $responseJson');

      for (final label in responseJson['labels']! as List<dynamic>) {
        final cleanLabel = label as Map<String, Object?>
          ..remove('sig')
          ..putIfAbsent(
            'src',
            () => defaultLabelerDid,
          ); // Use default labeler DID if src is missing from response
        labels.add(Label.fromJson(cleanLabel));
      }

      return (labels: labels, cursor: responseJson['cursor'] as String?);
    });
  }

  @override
  Future<({List<PostView> posts, String? cursor})> searchPosts(
    String query, {
    int limit = 20,
    String sort = 'latest',
    String? cursor,
  }) async {
    _logger.d(
      'Searching posts with query: $query, limit: $limit, sort: $sort, '
      'cursor: $cursor',
    );

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final response = await atproto.call(
        sprk_search_posts.soSprkFeedSearchPosts,
        parameters: sprk_search_posts.FeedSearchPostsInput(
          q: query,
          limit: limit,
          sort: sprk_search_posts.FeedSearchPostsSort.valueOf(sort),
          cursor: cursor,
        ),
        headers: {'atproto-proxy': _client.sprkDid},
      );

      final output = response.data;
      final outputJson = output.toJson();
      final posts = (outputJson['posts']! as List<dynamic>)
          .map((post) => post as Map<String, dynamic>)
          .map(PostView.fromJson)
          .toList();

      return (posts: posts, cursor: output.cursor);
    });
  }

  @override
  Future<({List<PostLike> likes, String? cursor})> getLikes(
    AtUri uri, {
    String? cid,
    int limit = 50,
    String? cursor,
  }) async {
    _logger.d(
      'Getting likes for post: $uri, cid: $cid, limit: $limit, '
      'cursor: $cursor',
    );

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.call(
        sprk_get_likes.soSprkFeedGetLikes,
        parameters: sprk_get_likes.FeedGetLikesInput(
          uri: uri,
          cid: cid,
          limit: limit,
          cursor: cursor,
        ),
        headers: {'atproto-proxy': _client.sprkDid},
      );
      final output = result.data;
      _logger.d('Likes retrieved successfully: ${output.likes.length} actors');
      return (likes: output.likes.toList(), cursor: output.cursor);
    });
  }

  @override
  Future<({List<FeedViewPost> posts, String? cursor})> getActorReposts(
    String actor, {
    int limit = 50,
    String? cursor,
    bool bluesky = false,
  }) async {
    _logger.d(
      'Getting actor reposts for actor: $actor, limit: $limit, '
      'cursor: $cursor, bluesky: $bluesky',
    );

    if (bluesky) {
      return _getActorRepostsFromBluesky(actor, limit: limit, cursor: cursor);
    }

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.call(
        sprk_get_actor_reposts.soSprkFeedGetActorReposts,
        parameters: sprk_get_actor_reposts.FeedGetActorRepostsInput(
          actor: actor,
          limit: limit,
          cursor: cursor,
        ),
        headers: {'atproto-proxy': _client.sprkDid},
      );
      final output = result.data;
      final rawFeed = output.toJson()['feed']! as List<dynamic>;
      final feedPosts = _parseAndFilterPosts<FeedViewPost>(
        rawPosts: rawFeed,
        fromJson: FeedViewPost.fromJson,
        hasMedia: _feedViewPostHasMedia,
        getUri: _getFeedViewPostUri,
        source: 'sprk actor reposts',
      );
      _logger.d(
        'Actor reposts retrieved successfully: '
        '${feedPosts.length} posts',
      );
      return (posts: feedPosts, cursor: output.cursor);
    });
  }

  /// Get actor reposts from Bluesky API
  /// Note: Bluesky doesn't have a direct getActorReposts endpoint,
  /// so we return an empty result in Bluesky mode.
  Future<({List<FeedViewPost> posts, String? cursor})>
  _getActorRepostsFromBluesky(
    String actor, {
    required int limit,
    required String? cursor,
  }) async {
    _logger.w(
      'getActorReposts is not available for Bluesky API, returning empty',
    );
    return (posts: <FeedViewPost>[], cursor: null);
  }

  @override
  Future<({List<FeedViewPost> posts, String? cursor})> getActorLikes(
    String actor, {
    int limit = 50,
    String? cursor,
    bool bluesky = false,
  }) async {
    _logger.d(
      'Getting actor likes for actor: $actor, limit: $limit, '
      'cursor: $cursor, bluesky: $bluesky',
    );

    if (bluesky) {
      return _getActorLikesFromBluesky(actor, limit: limit, cursor: cursor);
    }

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.call(
        sprk_get_actor_likes.soSprkFeedGetActorLikes,
        parameters: sprk_get_actor_likes.FeedGetActorLikesInput(
          actor: actor,
          limit: limit,
          cursor: cursor,
        ),
        headers: {'atproto-proxy': _client.sprkDid},
      );
      final output = result.data;
      final rawFeed = output.toJson()['feed']! as List<dynamic>;
      final feedPosts = _parseAndFilterPosts<FeedViewPost>(
        rawPosts: rawFeed,
        fromJson: FeedViewPost.fromJson,
        hasMedia: _feedViewPostHasMedia,
        getUri: _getFeedViewPostUri,
        source: 'sprk actor likes',
      );
      _logger.d(
        'Actor likes retrieved successfully: '
        '${feedPosts.length} posts',
      );
      return (posts: feedPosts, cursor: output.cursor);
    });
  }

  /// Get actor likes from Bluesky API
  /// Note: Bluesky doesn't have a direct getActorLikes endpoint,
  /// so we return an empty result in Bluesky mode.
  Future<({List<FeedViewPost> posts, String? cursor})>
  _getActorLikesFromBluesky(
    String actor, {
    required int limit,
    required String? cursor,
  }) async {
    _logger.w(
      'getActorLikes is not available for Bluesky API, returning empty',
    );
    return (posts: <FeedViewPost>[], cursor: null);
  }
}
