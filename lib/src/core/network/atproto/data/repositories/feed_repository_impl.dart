import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:atproto/com_atproto_label_defs.dart';
import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto/core.dart';
import 'package:bluesky/app_bsky_feed_getauthorfeed.dart';
import 'package:bluesky/app_bsky_richtext_facet.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:sparksocial/src/core/config/app_config.dart';
import 'package:sparksocial/src/core/network/atproto/data/adapters/bsky/feed_adapter.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/utils/json_utils.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';

/// Implementation of Feed-related API endpoints
class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._client) {
    _logger.v('FeedRepository initialized');
  }
  final SprkRepository _client;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger('FeedRepository');

  bool _postViewHasMedia(PostView post) => post.hasSupportedMedia;

  bool _feedViewPostHasMedia(FeedViewPost feedViewPost) {
    return feedViewPost.map(
      post: (p) => p.post.hasSupportedMedia,
      reply: (r) => r.reply.media != null,
    );
  }

  bool _feedViewPostIsReply(FeedViewPost feedViewPost) {
    return feedViewPost.map(
      post: (p) => p.reply != null, // If post has reply field, it's a reply
      reply: (r) => true, // Reply variant is always a reply
    );
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
        final postData = rawPost is Map<String, dynamic> ? rawPost : rawPost.toJson();

        // Fix missing $type field for FeedViewPost union type
        if ((postData[r'$type'] as String?) == null) {
          if (postData.containsKey('post') == true) {
            postData[r'$type'] = 'so.sprk.feed.defs#feedPostView';
          } else if (postData.containsKey('reply') == true) {
            postData[r'$type'] = 'so.sprk.feed.defs#feedReplyView';
          }
        }

        final parsedPost = fromJson(postData as Map<String, dynamic>);

        if (hasMedia(parsedPost)) {
          posts.add(parsedPost);
        } else {}
      } catch (e) {
        _logger.w('Failed to parse $source post, skipping: $e');
      }
    }

    return posts;
  }

  @override
  Future<FeedView> getFeed(Feed feed, {int limit = 20, String? cursor}) async {
    _logger.d('Getting feed skeleton for feed: $feed, limit: $limit, cursor: $cursor');
    if (feed.view == null) {
      if (feed.type == 'timeline') {
        return getTimeline(limit: limit, cursor: cursor);
      }
      // For custom feeds, fetch the feed generator view first
      final feedUri = AtUri(feed.config.value);
      final view = await getFeedGenerator(feedUri);
      // Update the feed with the view and continue
      final feedWithView = Feed(type: feed.type, config: feed.config, view: view);
      return _client.executeWithRetry(() async {
        final result = await getFeedView(feedWithView.view!.uri, limit: limit, cursor: cursor);
        _logger.d('Feed skeleton retrieved successfully');
        return result;
      });
    }
    return _client.executeWithRetry(() async {
      final result = await getFeedView(feed.view!.uri, limit: limit, cursor: cursor);
      _logger.d('Feed skeleton retrieved successfully');
      return result;
    });
  }

  @override
  Future<List<PostView>> getPosts(List<AtUri> uris, {bool bluesky = false, bool filter = true}) async {
    _logger.d('Getting posts for URIs: ${uris.length} URIs');
    if (bluesky) {
      _logger.d('Getting posts on bluesky API for: ${uris.length} URIs');
      final blueskyClient = bsky.Bluesky.fromSession(_client.authRepository.session!);
      final posts = await blueskyClient.feed.getPosts(uris: uris);

      // Convert Bluesky posts using adapter
      // Create mutable copies to avoid "Cannot modify unmodifiable map" errors
      final rawPosts = posts.data.posts.map((post) {
        final json = post.toJson();
        return deepCopyJson(json);
      }).toList();

      rawPosts.forEach(bskyFeedAdapter.convertPostViewJson);

      final parsedPosts = rawPosts.map(PostView.fromJson).toList();
      final sparkPosts = parsedPosts.map((post) => post.toSparkPostView()).toList();
      final filteredPosts = filter ? sparkPosts.where(_postViewHasMedia).toList() : sparkPosts;
      return filteredPosts;
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

      final result = await atproto.get(
        NSID.parse('so.sprk.feed.getPosts'),
        parameters: {'uris': uris},
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) {
          final posts = jsonMap['posts']! as List<dynamic>;
          _logger.d('Raw API response for first post: ${posts.isNotEmpty ? posts[0] : "empty"}');
          return _parseAndFilterPosts<PostView>(
            rawPosts: posts,
            fromJson: PostView.fromJson,
            hasMedia: _postViewHasMedia,
            getUri: _getPostViewUri,
            source: 'sprk',
          );
        },
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
      );
      _logger.d('Posts retrieved successfully: ${result.data.length} posts');
      if (result.data.isNotEmpty) {
        _logger.d('First post replyCount: ${result.data.first.replyCount}, likeCount: ${result.data.first.likeCount}');
      }

      return result.data;
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
    _logger.d('Getting author feed for actor: $actorUri, limit: $limit, cursor: $cursor, bluesky: $bluesky');

    if (bluesky) {
      return _getAuthorFeedFromBluesky(actorUri, limit: limit, cursor: cursor, videosOnly: videosOnly);
    }

    return _getAuthorFeedFromSpark(actorUri, limit: limit, cursor: cursor, videosOnly: videosOnly);
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

      final parameters = <String, dynamic>{'actor': actorUri.hostname, 'limit': limit};

      if (videosOnly) {
        parameters['filter'] = 'posts_with_video';
      }

      if (cursor != null) {
        parameters['cursor'] = cursor;
      }

      try {
        final result = await atproto.get(
          NSID.parse('so.sprk.feed.getAuthorFeed'),
          parameters: parameters,
          headers: {'atproto-proxy': _client.sprkDid},
          to: (jsonMap) {
            final rawFeed = jsonMap['feed']! as List<dynamic>;
            final feedPosts = _parseAndFilterPosts<FeedViewPost>(
              rawPosts: rawFeed,
              fromJson: FeedViewPost.fromJson,
              hasMedia: _feedViewPostHasMedia,
              getUri: _getFeedViewPostUri,
              source: 'sprk author feed',
            );
            return (posts: feedPosts, cursor: jsonMap['cursor'] as String?);
          },
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
        );
        _logger.d('Author feed retrieved successfully from Sprk');
        return result.data;
      } catch (e) {
        _logger.e('Error getting author feed from Sprk. Trying Bsky...', error: e);
        return _getAuthorFeedFromBluesky(actorUri, limit: limit, cursor: cursor, videosOnly: videosOnly);
      }
    });
  }

  /// Get author feed directly from Bluesky API
  Future<({List<FeedViewPost> posts, String? cursor})> _getAuthorFeedFromBluesky(
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
        final resultBsky = await bsky.Bluesky.fromSession(_client.authRepository.session!).feed.getAuthorFeed(
          actor: actorUri.hostname,
          limit: limit,
          cursor: cursor,
          filter: FeedGetAuthorFeedFilter.valueOf(videosOnly ? 'posts_with_video' : 'posts_with_media'),
        );

        // Create mutable copies of the JSON maps since toJson() returns unmodifiable maps
        final rawFeed = resultBsky.data.feed.map((feedView) {
          final json = feedView.toJson();
          // Deep copy to make it mutable
          return deepCopyJson(json);
        }).toList();

        // Use adapter to convert Bluesky JSON to Spark structure
        final feedPosts = <FeedViewPost>[];
        for (var i = 0; i < rawFeed.length; i++) {
          try {
            final rawPost = rawFeed[i];
            bskyFeedAdapter.convertFeedViewPostJson(rawPost);

            if (!rawPost.containsKey(r'$type')) {
              continue;
            }

            final parsedPost = FeedViewPost.fromJson(rawPost);
            feedPosts.add(parsedPost);
          } catch (e, stackTrace) {
            _logger.e('Failed to parse bsky feed view #$i', error: e, stackTrace: stackTrace);
          }
        }
        final convertedPosts = feedPosts.map((post) => post.toSparkFeedViewPost()).toList();
        // Filter out replies for Bluesky feeds (Spark posts can't be replies)
        final filteredPosts = convertedPosts.where((post) => !_feedViewPostIsReply(post)).where(_feedViewPostHasMedia).toList();
        return (posts: filteredPosts, cursor: resultBsky.data.cursor);
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

      final parameters = <String, dynamic>{'limit': limit};
      if (cursor != null) {
        parameters['cursor'] = cursor;
      }

      final result = await atproto.get(
        NSID.parse('so.sprk.feed.getTimeline'),
        parameters: parameters,
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) {
          if (!jsonMap.containsKey('feed')) {
            return const FeedView(feed: []);
          }

          final feedData = jsonMap['feed'] as List<dynamic>?;
          if (feedData == null) {
            return const FeedView(feed: []);
          }

          final feedPosts = <FeedViewPost>[];
          for (final item in feedData) {
            try {
              final itemMap = item as Map<String, dynamic>;

              // The response has a 'post' object containing the fully hydrated post view
              final postMap = itemMap['post'] as Map<String, dynamic>?;
              if (postMap == null) {
                continue;
              }

              // Parse the post view
              final postView = PostView.fromJson(postMap);

              // Create a FeedViewPost.post variant (not a reply)
              final feedViewPost = FeedViewPost.post(post: postView);
              feedPosts.add(feedViewPost);
            } catch (e, stackTrace) {
              _logger.w('Failed to parse timeline feed item, skipping: $e', stackTrace: stackTrace);
            }
          }

          return FeedView(
            feed: feedPosts,
            cursor: jsonMap['cursor'] as String?,
          );
        },
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
      );

      _logger.d('Timeline feed retrieved successfully: ${result.data.feed.length} posts');
      return result.data;
    });
  }

  @override
  Future<FeedView> getFeedView(
    AtUri feedUri, {
    int limit = 20,
    String? cursor,
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

      final isBskyFeed = feedUri.collection == NSID.parse('app.bsky.feed.generator');

      final parameters = <String, dynamic>{
        'feed': feedUri.toString(),
        'limit': limit,
      };
      if (cursor != null) {
        parameters['cursor'] = cursor;
      }

      final result = await atproto.get(
        isBskyFeed ? NSID.parse('app.bsky.feed.getFeed') : NSID.parse('so.sprk.feed.getFeed'),
        parameters: parameters,
        headers: {'atproto-proxy': isBskyFeed ? _client.bskyDid : _client.sprkDid},
        to: (jsonMap) {
          if (!jsonMap.containsKey('feed')) {
            return const FeedView(feed: []);
          }

          final feedData = jsonMap['feed'] as List<dynamic>?;
          if (feedData == null) {
            return const FeedView(feed: []);
          }

          final feedPosts = <FeedViewPost>[];
          for (final item in feedData) {
            try {
              final itemMap = item as Map<String, dynamic>;

              // For Bluesky feeds, convert the JSON to Spark format using adapter
              if (isBskyFeed) {
                bskyFeedAdapter.convertFeedViewPostJson(itemMap);

                // Ensure $type is set for FeedViewPost union type
                if (!itemMap.containsKey(r'$type')) {
                  if (itemMap.containsKey('post')) {
                    itemMap[r'$type'] = 'so.sprk.feed.defs#feedPostView';
                  } else if (itemMap.containsKey('reply')) {
                    itemMap[r'$type'] = 'so.sprk.feed.defs#feedReplyView';
                  }
                }

                // Parse the FeedViewPost
                final feedViewPost = FeedViewPost.fromJson(itemMap);
                final convertedPost = feedViewPost.toSparkFeedViewPost();
                feedPosts.add(convertedPost);
              } else {
                // Spark feeds: The response has a 'post' object containing the fully hydrated post view
                final postMap = itemMap['post'] as Map<String, dynamic>?;
                if (postMap == null) {
                  continue;
                }

                // Parse the post view
                final postView = PostView.fromJson(postMap);

                // Create a FeedViewPost.post variant (not a reply)
                final feedViewPost = FeedViewPost.post(post: postView);
                feedPosts.add(feedViewPost);
              }
            } catch (e, stackTrace) {
              _logger.w('Failed to parse feed item, skipping: $e', stackTrace: stackTrace);
            }
          }

          // Filter out replies for Bluesky feeds (Spark posts can't be replies)
          final filteredPosts = isBskyFeed
              ? feedPosts.where((post) => !_feedViewPostIsReply(post)).where(_feedViewPostHasMedia).toList()
              : feedPosts;

          return FeedView(
            feed: filteredPosts,
            cursor: jsonMap['cursor'] as String?,
          );
        },
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
      );

      _logger.d('Feed retrieved successfully: ${result.data.feed.length} posts');
      return result.data;
    });
  }

  @override
  Future<GeneratorView> getFeedGenerator(AtUri feed) async {
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }
      final isBskyFeed = feed.collection == NSID.parse('app.bsky.feed.generator');

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final headers = isBskyFeed ? {'atproto-proxy': _client.bskyDid} : {'atproto-proxy': _client.sprkDid};
      final response = await atproto.get(
        isBskyFeed ? NSID.parse('app.bsky.feed.getFeedGenerator') : NSID.parse('so.sprk.feed.getFeedGenerator'),
        parameters: {'feed': feed.toString()},
        headers: headers,
        to: (jsonMap) {
          // Both Bluesky and Spark APIs return the generator view nested in a 'view' key
          final generatorData = jsonMap.containsKey('view') ? jsonMap['view']! as Map<String, dynamic> : jsonMap;
          return GeneratorView.fromJson(generatorData);
        },
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
      );
      return response.data;
    });
  }

  @override
  Future<List<GeneratorView>> getFeedGenerators(List<AtUri> feeds, {bool bluesky = false}) async {
    _logger.d('Getting feed generators for ${feeds.length} feeds, bluesky: $bluesky');
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

      final headers = bluesky ? {'atproto-proxy': _client.bskyDid} : {'atproto-proxy': _client.sprkDid};
      final feedStrings = feeds.map((feed) => feed.toString()).toList();
      final response = await atproto.get(
        bluesky ? NSID.parse('app.bsky.feed.getFeedGenerators') : NSID.parse('so.sprk.feed.getFeedGenerators'),
        parameters: {'feeds': feedStrings},
        headers: headers,
        to: (jsonMap) {
          final feedsData = jsonMap['feeds']! as List<dynamic>;
          return feedsData
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
        },
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
      );
      _logger.d('Feed generators retrieved successfully: ${response.data.length} generators');
      return response.data;
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

      final headers = bluesky ? {'atproto-proxy': _client.bskyDid} : {'atproto-proxy': _client.sprkDid};
      final response = await atproto.get(
        bluesky ? NSID.parse('app.bsky.feed.getSuggestedFeeds') : NSID.parse('so.sprk.feed.getSuggestedFeeds'),
        headers: headers,
        to: (jsonMap) {
          final feedsData = (jsonMap['feeds'] as List<dynamic>?) ?? [];
          return feedsData
              .map((feedData) {
                try {
                  final feedMap = feedData as Map<String, dynamic>;
                  return GeneratorView.fromJson(feedMap);
                } catch (e) {
                  _logger.w('Failed to parse suggested feed generator, skipping: $e');
                  return null;
                }
              })
              .whereType<GeneratorView>()
              .toList();
        },
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
      );
      _logger.d('Suggested feeds retrieved successfully: ${response.data.length} generators');
      return response.data;
    });
  }

  @override
  Future<Feed> getFeedFromSavedFeed(SavedFeed savedFeed) async {
    return _client.executeWithRetry(() async {
      if (savedFeed.type == 'timeline') {
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

      // Separate timeline feeds from custom feeds
      final timelineFeeds = <SavedFeed>[];
      final customFeeds = <SavedFeed>[];
      for (final savedFeed in savedFeeds) {
        if (savedFeed.type == 'timeline') {
          timelineFeeds.add(savedFeed);
        } else {
          customFeeds.add(savedFeed);
        }
      }

      final feeds = <Feed>[];

      // Add timeline feeds directly (they don't need generator views)
      for (final savedFeed in timelineFeeds) {
        feeds.add(Feed(type: 'timeline', config: savedFeed));
      }

      if (customFeeds.isEmpty) {
        return feeds;
      }

      // Group custom feeds by type (Bluesky vs Spark)
      final bskyFeeds = <SavedFeed>[];
      final sprkFeeds = <SavedFeed>[];
      for (final savedFeed in customFeeds) {
        final feedUri = AtUri(savedFeed.value);
        final isBskyFeed = feedUri.collection == NSID.parse('app.bsky.feed.generator');
        if (isBskyFeed) {
          bskyFeeds.add(savedFeed);
        } else {
          sprkFeeds.add(savedFeed);
        }
      }

      // Fetch all Bluesky feed generators at once
      if (bskyFeeds.isNotEmpty) {
        final bskyUris = bskyFeeds.map((savedFeed) => AtUri(savedFeed.value)).toList();
        final bskyViews = await getFeedGenerators(bskyUris, bluesky: true);
        final viewMap = {for (final view in bskyViews) view.uri: view};
        for (final savedFeed in bskyFeeds) {
          final feedUri = AtUri(savedFeed.value);
          final view = viewMap[feedUri];
          if (view != null) {
            feeds.add(Feed(type: 'feed', config: savedFeed, view: view));
          } else {
            _logger.w('Feed generator view not found for Bluesky feed: $feedUri');
            // Fallback: create feed without view
            feeds.add(Feed(type: 'feed', config: savedFeed));
          }
        }
      }

      // Fetch all Spark feed generators at once
      if (sprkFeeds.isNotEmpty) {
        final sprkUris = sprkFeeds.map((savedFeed) => AtUri(savedFeed.value)).toList();
        final sprkViews = await getFeedGenerators(sprkUris);
        final viewMap = {for (final view in sprkViews) view.uri: view};
        for (final savedFeed in sprkFeeds) {
          final feedUri = AtUri(savedFeed.value);
          final view = viewMap[feedUri];
          if (view != null) {
            feeds.add(Feed(type: 'feed', config: savedFeed, view: view));
          } else {
            _logger.w('Feed generator view not found for Spark feed: $feedUri');
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

    // Determine if this is a Bluesky post or Spark post
    final isBskyPost = postUri.collection.toString().startsWith('app.bsky.feed.post');
    final likeType = isBskyPost ? 'app.bsky.feed.like' : 'so.sprk.feed.like';

    _logger.d('Post type: ${isBskyPost ? 'Bluesky' : 'Spark'}, using collection: $likeType');

    final likeRecord = {
      r'$type': likeType,
      'subject': {'cid': postCid, 'uri': postUri.toString()},
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };

    final result = await _client.repo.createRecord(collection: likeType, record: likeRecord);
    _logger.i('Post liked successfully: ${result.uri}');

    return result;
  }

  @override
  Future<void> unlikePost(AtUri likeUri) async {
    _logger.d('Unliking post with like URI: $likeUri');
    await _client.repo.deleteRecord(uri: likeUri, skipBskyCrosspostCleanup: true);
    _logger.i('Post unliked successfully');
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
      final uploadedImageMaps = await uploadImages(imageFiles: [files.first], altTexts: altTexts);
      final firstImage = uploadedImageMaps.first;
      mediaJson = Media.image(image: firstImage.image, alt: firstImage.alt).toJson();
    }

    // Create the correct record JSON depending on the target platform.
    final isSprk = parentUri.toString().contains('sprk');

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
        caption: CaptionRef(text: text, facets: []),
        reply: RecordReplyRef(
          root: RepoStrongRef(uri: effectiveRootUri, cid: effectiveRootCid),
          parent: RepoStrongRef(uri: parentUri, cid: parentCid),
        ),
        createdAt: DateTime.now().toUtc(),
        media: media,
      );
      recordJson = sprkRecord.toJson();
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

      final bskyMedia = mediaJson != null ? bskyFeedAdapter.convertJsonToBskyEmbed(mediaJson) : null;

      final bskyRecord = bskyFeedAdapter.createCommentRecord(
        text: text,
        createdAt: DateTime.now().toUtc(),
        reply: RecordReplyRef(
          root: RepoStrongRef(uri: effectiveRootUri, cid: effectiveRootCid),
          parent: RepoStrongRef(uri: parentUri, cid: parentCid),
        ),
        embed: bskyMedia,
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

    final uploadedImageMaps = await uploadImages(imageFiles: imageFiles, altTexts: altTexts);

    // Create Sprk post
    final record = PostRecord(
      caption: CaptionRef(text: text, facets: []),
      media: Media.images(images: uploadedImageMaps),
      createdAt: DateTime.now().toUtc(),
    );

    final result = await _client.repo.createRecord(
      collection: 'so.sprk.feed.post',
      record: record.toJson(),
    );

    _logger.i('Image post created successfully: ${result.uri}');

    // Crosspost to Bluesky if enabled
    if (crosspostToBsky) {
      try {
        await _crosspostToBlueSky(text, uploadedImageMaps, result, altTexts);
      } catch (e) {
        _logger.w('Failed to crosspost to Bluesky: $e');
        // Don't fail the entire operation if Bluesky crossposting fails
      }
    }

    return result;
  }

  /// Helper to upload multiple images, stripping EXIF, and return a list of JSON maps for embedding
  @override
  Future<List<Image>> uploadImages({required List<XFile> imageFiles, Map<String, String>? altTexts}) async {
    _logger.d('Processing ${imageFiles.length} images for upload');

    final uploadedImageMaps = <Image>[];
    for (final imageFile in imageFiles) {
      try {
        _logger.d('Processing image: ${imageFile.name}');

        final originalBytes = await imageFile.readAsBytes();

        // Decode and process the image to strip EXIF data
        switch (img.decodeImage(originalBytes)) {
          case null:
            _logger.e('Failed to decode image ${imageFile.name}');
            throw Exception('Failed to decode image ${imageFile.name}');
          case final img.Image decodedImage:
            // Re-encode the image with reduced quality to optimize size
            final processedBytes = Uint8List.fromList(img.encodeJpg(decodedImage, quality: 85));

            // Upload the processed image
            switch (_client.authRepository.atproto) {
              case null:
                _logger.e('AtProto not initialized');
                throw Exception('AtProto not initialized');
              case final atproto:
                final response = await atproto.repo.uploadBlob(bytes: processedBytes);

                switch (response.status.code) {
                  case 200:
                    // Add the uploaded image to our result list
                    uploadedImageMaps.add(Image(alt: altTexts?[imageFile.path] ?? '', image: response.data.blob));
                  default:
                    _logger.e('Failed to upload image blob: ${response.status.code}');
                    throw Exception('Blob upload failed for ${imageFile.name}: ${response.status.code}');
                }
            }
        }
      } catch (e) {
        _logger.e('Error processing/uploading image ${imageFile.name}', error: e);
        rethrow;
      }
    }

    _logger.d('Successfully processed and uploaded ${uploadedImageMaps.length} images');
    return uploadedImageMaps;
  }

  @override
  Future<VideoUploadResult> uploadVideo(String videoPath) async {
    _logger.d('Uploading video from path: $videoPath');

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }
      final authAtProto = _client.authRepository.atproto;
      if (authAtProto == null || authAtProto.session == null) {
        throw Exception('AtProto not initialized');
      }

      // Handle file:// URL scheme
      var cleanVideoPath = videoPath;
      if (videoPath.startsWith('file://')) {
        cleanVideoPath = videoPath.replaceFirst('file://', '');
      }

      // Validate the video file
      final file = File(cleanVideoPath);
      if (!file.existsSync()) {
        throw Exception('Video file not found: $cleanVideoPath');
      }

      // Check if the video is in a compatible format
      final videoBytes = await file.readAsBytes();
      if (videoBytes.isEmpty) {
        throw Exception('Video file is empty');
      }

      _logger.i('Video file size: ${videoBytes.length} bytes');

      final pdsService = authAtProto.service;
      final serviceTokenRes = await authAtProto.server.getServiceAuth(
        aud: 'did:web:$pdsService',
        lxm: 'com.atproto.repo.uploadBlob',
        exp: DateTime.now().toUtc().add(const Duration(minutes: 5)).millisecondsSinceEpoch ~/ 1000,
      );

      final serviceToken = serviceTokenRes.data.token;
      var response = await http.post(
        Uri.parse('${AppConfig.videoServiceUrl}/xrpc/so.sprk.video.uploadVideo'),
        headers: {'Authorization': 'Bearer $serviceToken', 'Content-Type': _getContentType(cleanVideoPath)},
        body: videoBytes,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to upload video: ${response.statusCode} ${response.body}');
      }

      // Parse the response
      dynamic responseData = jsonDecode(response.body);
      _logger.d('Video upload response: $responseData');

      // Poll job status until it finishes (handles both QUEUED and PROCESSING)
      var jobState = responseData['jobStatus']?['state'] as String?;
      var attempts = 0;
      const maxAttempts = 120; // ~4 minutes at 2s interval
      while (jobState == 'JOB_STATE_QUEUED' || jobState == 'JOB_STATE_PROCESSING') {
        _logger.d('Video upload in progress, status: $jobState');
        // Small backoff to avoid hammering the service
        await Future.delayed(const Duration(seconds: 2));
        attempts++;
        if (attempts > maxAttempts) {
          throw Exception('Timed out waiting for video processing to finish');
        }

        response = await http.get(
          Uri.parse('${AppConfig.videoServiceUrl}/xrpc/so.sprk.video.getJobStatus').replace(
            queryParameters: {
              'jobId': responseData['jobStatus']?['jobId'],
            },
          ),
          headers: {'Authorization': 'Bearer $serviceToken', 'Content-Type': _getContentType(cleanVideoPath)},
        );
        if (response.statusCode != 200) {
          throw Exception('Failed to check video upload status: ${response.statusCode} ${response.body}');
        }
        responseData = jsonDecode(response.body);
        _logger.d('Video upload status response: $responseData');
        jobState = responseData['jobStatus']?['state'] as String?;
      }

      if (responseData['jobStatus']?['state'] == 'JOB_STATE_FAILED') {
        throw Exception('Video upload failed: ${responseData['jobStatus']?['status']}');
      }

      // Parse video blob
      Map<String, dynamic> videoBlobData;
      if (responseData case {'jobStatus': {'blob': final blobData}}) {
        videoBlobData = blobData as Map<String, dynamic>;
      } else if (responseData case {'blobRef': final blobRef}) {
        videoBlobData = blobRef as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response format: $responseData');
      }
      final videoBlob = Blob.fromJson(videoBlobData);

      // Parse audio blob if present
      Blob? audioBlob;
      AudioDetails? audioDetails;
      if (responseData case {'jobStatus': {'audio': final audioData}}) {
        final audio = audioData as Map<String, dynamic>;
        if (audio['blob'] != null) {
          audioBlob = Blob.fromJson(audio['blob'] as Map<String, dynamic>);
          _logger.d('Extracted audio blob: ${audioBlob.size} bytes');
        }
        if (audio['details'] != null) {
          audioDetails = AudioDetails.fromJson(audio['details'] as Map<String, dynamic>);
        }
      }

      return VideoUploadResult(
        videoBlob: videoBlob,
        audioBlob: audioBlob,
        audioDetails: audioDetails,
      );
    });
  }

  /// Crosspost images to Bluesky using adapter to handle Bluesky-specific model logic
  Future<void> _crosspostToBlueSky(
    String text,
    List<Image> sparkImages,
    RepoStrongRef sparkPostData,
    Map<String, String> altTexts,
  ) async {
    _logger.d('Crossposting to Bluesky with ${sparkImages.length} images');

    const maxBskyImages = 4;

    // Use adapter to convert Spark images to Bluesky images
    final allBskyImages = bskyFeedAdapter.convertImages(sparkImages);
    final bskyImages = allBskyImages.take(maxBskyImages).toList();

    // Determine if we need to add a link to the Spark post
    String? linkUrl;
    List<RichtextFacet>? facets;

    if (sparkImages.length > maxBskyImages) {
      final sparkRkey = sparkPostData.uri.rkey;
      final uriDid = sparkPostData.uri.hostname;
      linkUrl = 'https://watch.sprk.so/?uri=$uriDid/$sparkRkey';
    }

    // Prepare text and facets for Bluesky post
    final finalText = _prepareTextWithLink(text: text, linkUrl: linkUrl);

    if (linkUrl != null) {
      final linkStart = text.isEmpty ? 0 : text.length;
      facets = [
        bskyFeedAdapter.createLinkFacet(
          linkUrl: linkUrl,
          byteStart: linkStart,
        ),
      ];
    }

    final bskyPost = bskyFeedAdapter.createPostRecord(
      text: finalText,
      createdAt: DateTime.now().toUtc(),
      images: bskyImages,
      facets: facets,
    );

    final bskyResult = await _client.repo.createRecord(
      collection: 'app.bsky.feed.post',
      record: bskyPost.toJson(),
      rkey: sparkPostData.uri.rkey,
    );

    _logger.i('Successfully crossposted to Bluesky: ${bskyResult.uri}');
  }

  /// Prepare text for Bluesky post, handling link addition and truncation
  String _prepareTextWithLink({
    required String text,
    String? linkUrl,
  }) {
    if (linkUrl == null) {
      return text;
    }

    if (text.isEmpty) {
      return linkUrl;
    }

    final linkWithNewlines = '\n\n$linkUrl';
    const maxTextLength = 300;
    final availableTextLength = maxTextLength - linkWithNewlines.length;

    if (text.length <= availableTextLength) {
      return '$text$linkWithNewlines';
    } else {
      const ellipsis = '...';
      final croppedTextLength = availableTextLength - ellipsis.length;
      final croppedText = text.substring(0, croppedTextLength);
      return '$croppedText$ellipsis$linkWithNewlines';
    }
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
  }) async {
    _logger.d('Posting video with description: $text');

    final record = PostRecord(
      caption: CaptionRef(text: text, facets: []),
      media: Media.video(video: blob, alt: alt),
      createdAt: DateTime.now().toUtc(),
      langs: langs,
      selfLabels: selfLabels,
      tags: tags,
    );

    final result = await _client.repo.createRecord(
      collection: 'so.sprk.feed.post',
      record: record.toJson(),
    );

    _logger.i('Video posted successfully: ${result.uri}');
    return result;
  }

  @override
  Future<Thread> getThread(AtUri uri, {int depth = 2, int parentHeight = 0, bool bluesky = false}) async {
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
        final bluesky = bsky.Bluesky.fromSession(_client.authRepository.session!);
        final response = await bluesky.feed.getPostThread(uri: uri, depth: depth, parentHeight: parentHeight);
        // Use adapter to convert Bluesky thread to Spark thread
        return bskyFeedAdapter.convertBskyThreadToSparkThread(thread: response.data.thread, uri: uri);
      }
      const source = 'so.sprk.feed.getPostThread';
      final response = await atproto.get(
        NSID.parse(source),
        parameters: {'anchor': uri.toString(), 'depth': depth, 'parentHeight': parentHeight},
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) {
          final threadItems = jsonMap['thread']! as List<dynamic>;
          return Thread.fromSparkFlatList(threadItems: threadItems);
        },
      );

      return response.data;
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

      final labelers = sources?.isNotEmpty ?? true ? sources! : ['did:plc:pbgyr67hftvpoqtvaurpsctc'];

      final parameters = {'uriPatterns': uris, 'sources': labelers, 'limit': limit, 'cursor': cursor};

      final response = await atproto.get(
        NSID.parse('com.atproto.label.queryLabels'),
        headers: {'atproto-proxy': 'did:plc:pbgyr67hftvpoqtvaurpsctc#atproto_labeler'},
        parameters: parameters,
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
      );
      _logger
        ..d('parameters: $parameters')
        ..d('Labels retrieved: ${response.data}');

      for (final label in response.data['labels']! as List<dynamic>) {
        final cleanLabel = label as Map<String, Object?>
          ..remove('sig') // i am NOT going to convert that sig string into a UInt8List i am going to PASS OUT and DIE
          ..putIfAbsent(
            'src',
            () => 'did:plc:pbgyr67hftvpoqtvaurpsctc',
          ); // fix this when there's multiple labelers support. for now idgaf. src is null for some reason in the response
        labels.add(Label.fromJson(cleanLabel));
      }

      return (labels: labels, cursor: response.data['cursor'] as String?);
    });
  }

  @override
  Future<({List<PostView> posts, String? cursor})> searchPosts(
    String query, {
    int limit = 20,
    String sort = 'latest',
    String? cursor,
  }) async {
    _logger.d('Searching posts with query: $query, limit: $limit, sort: $sort, cursor: $cursor');

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

      final parameters = <String, dynamic>{
        'q': query,
        'limit': limit,
        'sort': sort,
        'cursor': cursor,
      };

      final response = await atproto.get(
        NSID.parse('so.sprk.feed.searchPosts'),
        parameters: parameters,
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
      );

      final posts = (response.data['posts']! as List<dynamic>)
          .map((post) => post as Map<String, dynamic>)
          .map(PostView.fromJson)
          .toList();

      final newCursor = response.data['cursor'] as String?;

      return (posts: posts, cursor: newCursor);
    });
  }

  /// Helper method to determine content type based on file extension
  String _getContentType(String videoPath) {
    final extension = path.extension(videoPath).toLowerCase();

    switch (extension) {
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.avi':
        return 'video/x-msvideo';
      case '.webm':
        return 'video/webm';
      default:
        return 'video/mp4'; // Default to mp4
    }
  }
}
