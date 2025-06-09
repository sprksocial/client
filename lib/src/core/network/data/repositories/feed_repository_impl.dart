import 'dart:convert';
import 'dart:typed_data';

import 'package:atproto/core.dart';
import 'package:atproto/atproto.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/feed_algorithms/hardcoded_feed_algorithm.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

/// Implementation of Feed-related API endpoints
class FeedRepositoryImpl implements FeedRepository {
  final SprkRepository _client;
  final _logger = GetIt.instance<LogService>().getLogger('FeedRepository');

  FeedRepositoryImpl(this._client) {
    _logger.v('FeedRepository initialized');
  }

  @override
  Future<FeedSkeleton> getFeedSkeleton(Feed feed, {int? limit, String? cursor}) async {
    _logger.d('Getting feed skeleton for feed: $feed, limit: $limit, cursor: $cursor');
    limit ??= 10;
    switch (feed) {
      case FeedHardCoded(:final hardCodedFeed):
        final skeletonFunction = HardCodedFeedAlgorithm.skeletonFromEnum(hardCodedFeed);
        return skeletonFunction(limit: limit, cursor: cursor);
      case FeedCustom():
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
            NSID.parse('so.sprk.feed.getFeedSkeleton'),
            parameters: {'feed': feed, 'limit': limit, 'cursor': cursor},
            service: 'feeds.sprk.so',
            to: (jsonMap) => FeedSkeleton.fromJson(jsonMap),
            adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
          );
          _logger.d('Feed skeleton retrieved successfully');
          return result.data;
        });
      case _:
        throw ArgumentError('Invalid feed: $feed');
    }
  }

  @override
  Future<List<PostView>> getPosts(List<AtUri> uris, {bool bluesky = false}) async {
    _logger.d('Getting posts for URIs: ${uris.length} URIs');
    if (bluesky) {
      final bluesky = bsky.Bluesky.fromSession(_client.authRepository.session!);
      final posts = await bluesky.feed.getPosts(uris: uris.map((uri) => AtUri.parse(uri.toString())).toList());
      return posts.data.posts.map((post) => PostView.fromJson(post.toJson())).toList();
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
          final posts = jsonMap['posts'] as List<dynamic>;
          final postViews = <PostView>[];
          for (final post in posts) {
            postViews.add(PostView.fromJson(post));
          }
          return postViews;
        },
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Posts retrieved successfully');

      return result.data;
    });
  }

  @override
  Future<({List<FeedViewPost> posts, String? cursor})> getAuthorFeed(
    AtUri actorUri, {
    int limit = 20,
    String? cursor,
    bool videosOnly = false,
  }) async {
    _logger.d('Getting author feed for actor: $actorUri, limit: $limit, cursor: $cursor');
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
      } else {
        parameters['filter'] = 'posts_with_media';
      }

      if (cursor != null) {
        parameters['cursor'] = cursor;
      }
      try {
        final result = await atproto.get(
          NSID.parse('so.sprk.feed.getAuthorFeed'),
          parameters: parameters,
          headers: {'atproto-proxy': _client.sprkDid},
          to:
              (jsonMap) => (
                posts: (jsonMap['feed'] as List<dynamic>).map((post) => FeedViewPost.fromJson(post)).toList(),
                cursor: jsonMap['cursor'] as String?,
              ),
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
        );
        _logger.d('Author feed retrieved successfully');
        return result.data;
      } catch (e) {
        _logger.e('Error getting author feed from spark. Trying bluesky...', error: e);
        final resultBsky = await bsky.Bluesky.fromSession(_client.authRepository.session!).feed.getAuthorFeed(
          actor: actorUri.toString(),
          limit: limit,
          cursor: cursor,
          filter: videosOnly ? bsky.FeedFilter.postsWithVideo : bsky.FeedFilter.postsWithMedia,
        );
        _logger.d('Author feed retrieved successfully');
        final result = resultBsky.data.feed.map((post) => FeedViewPost.fromJson(post.toJson())).toList();
        return (posts: result, cursor: resultBsky.data.cursor);
      }
    });
  }

  @override
  Future<StrongRef> likePost(String postCid, AtUri postUri) async {
    _logger.d('Liking post with String: $postCid, URI: $postUri');
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

      final likeRecord = {
        "\$type": "so.sprk.feed.like",
        "subject": {"cid": postCid, "uri": postUri.toString()},
        "createdAt": DateTime.now().toUtc().toIso8601String(),
      };

      final result = await atproto.repo.createRecord(collection: NSID.parse('so.sprk.feed.like'), record: likeRecord);

      _logger.i('Post liked successfully: ${result.data.uri}');

      return result.data;
    });
  }

  @override
  Future<void> unlikePost(AtUri likeUri) async {
    _logger.d('Unliking post with like URI: $likeUri');
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

      await atproto.repo.deleteRecord(uri: likeUri);
      _logger.i('Post unliked successfully');
    });
  }

  @override
  Future<StrongRef> postComment(
    String text,
    String parentCid,
    AtUri parentUri, {
    String? rootCid,
    AtUri? rootUri,
    List<XFile>? imageFiles,
    Map<String, String>? altTexts,
  }) async {
    _logger.d('Posting comment to parent: $parentUri');

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      switch (_client.authRepository.atproto) {
        case null:
          _logger.e('AtProto not initialized');
          throw Exception('AtProto not initialized');
        case final atproto:
          // Use parent as root if not provided
          final effectiveRootCid = rootCid ?? parentCid;
          final effectiveRootUri = rootUri ?? parentUri;

          // Determine if target is a Spark post or Bluesky post
          final postType = switch (parentUri.toString()) {
            String uri when uri.contains('sprk') => "so.sprk.feed.post",
            _ => "app.bsky.feed.post",
          };

          // Upload images if provided
          Map<String, dynamic>? embedJson;
          if (imageFiles case List<XFile> files when files.isNotEmpty) {
            _logger.d('Uploading ${files.length} images for comment');
            final List<Image> uploadedImageMaps = await _uploadImages(files, altTexts ?? {});
            embedJson = {"\$type": "so.sprk.embed.images", "images": uploadedImageMaps};
          }

          final commentRecord = <String, dynamic>{
            "\$type": postType,
            "text": text,
            "reply": {
              "root": {"cid": effectiveRootCid, "uri": effectiveRootUri.toString()},
              "parent": {"cid": parentCid, "uri": parentUri.toString()},
            },
            "createdAt": DateTime.now().toUtc().toIso8601String(),
          };

          // Add embed JSON if images were uploaded
          if (embedJson != null) {
            commentRecord['embed'] = embedJson;
          }

          final result = await atproto.repo.createRecord(collection: NSID.parse(postType), record: commentRecord);

          _logger.i('Comment posted successfully: ${result.data.uri}');

          return result.data;
      }
    });
  }

  @override
  Future<StrongRef> postImage(String text, List<XFile> imageFiles, Map<String, String> altTexts) async {
    _logger.d('Creating image post with ${imageFiles.length} images');

    switch (imageFiles) {
      case List<XFile> files when files.isEmpty:
        _logger.e('No images provided for image post');
        throw ArgumentError('At least one image is required for an image post.');
      default:
        return _client.executeWithRetry(() async {
          if (!_client.authRepository.isAuthenticated) {
            _logger.w('Not authenticated');
            throw Exception('Not authenticated');
          }

          if (_client.authRepository.atproto case final atproto?) {
            final List<Image> uploadedImageMaps = await _uploadImages(imageFiles, altTexts);
            final embed = {"\$type": "so.sprk.embed.images", 'images': uploadedImageMaps};

            final record = {
              "\$type": "so.sprk.feed.post",
              'text': text,
              'embed': embed,
              'createdAt': DateTime.now().toUtc().toIso8601String(),
            };

            final result = await atproto.repo.createRecord(collection: NSID.parse('so.sprk.feed.post'), record: record);

            _logger.i('Image post created successfully: ${result.data.uri}');

            return result.data;
          } else {
            _logger.e('AtProto not initialized');
            throw Exception('AtProto not initialized');
          }
        });
    }
  }

  /// Helper to upload multiple images, stripping EXIF, and return a list of JSON maps for embedding
  Future<List<Image>> _uploadImages(List<XFile> imageFiles, Map<String, String> altTexts) async {
    _logger.d('Processing ${imageFiles.length} images for upload');

    final List<Image> uploadedImageMaps = [];
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
                final response = await atproto.repo.uploadBlob(processedBytes);

                switch (response.status.code) {
                  case 200:
                    _logger.d('Image uploaded successfully: ${imageFile.name}');

                    // Add the uploaded image to our result list
                    uploadedImageMaps.add(Image(alt: altTexts[imageFile.path] ?? '', image: response.data.blob));
                    break;
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
  Future<bool> deletePost(AtUri postUri) async {
    _logger.d('Deleting post with URI: $postUri');

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
        final response = await atproto.repo.deleteRecord(uri: postUri);

        switch (response.status.code) {
          case 200:
            _logger.i('Post deleted successfully: ${postUri.toString()}');
            return true;
          default:
            _logger.e('Failed to delete post: ${response.status.code}');
            return false;
        }
      } catch (e) {
        _logger.e('Error deleting post', error: e);
        return false;
      }
    });
  }

  @override
  Future<StrongRef> postVideo(
    Blob blob, {
    String text = '',
    String alt = '',
    List<String>? tags,
    List<String>? langs,
    List<SelfLabel>? selfLabels,
  }) async {
    _logger.d('Posting video with description: $text');

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final record = PostRecord(
        text: text,
        embed: Embed.video(video: blob, alt: alt),
        createdAt: DateTime.now(),
        langs: langs,
        selfLabels: selfLabels,
        tags: tags,
        // facets
      );

      // Create the post record
      final response = await _client.authRepository.atproto!.repo.createRecord(
        collection: NSID.parse('so.sprk.feed.post'),
        record: record.toJson(),
      );

      switch (response.status) {
        case HttpStatus.ok:
          _logger.i('Video posted successfully: ${response.data.uri}');
          return response.data;
        default:
          _logger.e('Failed to post video: ${response.status} ${response.data}');
          throw Exception('Failed to post video: ${response.status} ${response.data}');
      }
    });
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

      try {
        // Get the post thread
        final source = bluesky ? 'app.bsky.feed.getPostThread' : 'so.sprk.feed.getPostThread';
        final response = await atproto.get(
          NSID.parse(source),
          parameters: {'uri': uri.toString(), 'depth': depth, 'parentHeight': parentHeight},
          headers: {'atproto-proxy': _client.sprkDid},
          to: (jsonMap) {
            return Thread.fromJson(jsonMap['thread'] as Map<String, dynamic>);
          },
        );

        return response.data;
      } catch (e) {
        _logger.e('Failed to load Bluesky comments', error: e);
        throw Exception('Failed to load comments: ${e.toString()}');
      }
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

      List<Label> labels = [];

      final response = await atproto.get(
        NSID.parse('com.atproto.label.queryLabels'),
        parameters: {'uriPatterns': uris, 'sources': sources, 'limit': limit, 'cursor': cursor},
      );

      if (response.data case EmptyData()) {
        return (labels: labels, cursor: null);
      }

      for (final label in response.data['labels'] as List<dynamic>) {
        labels.add(Label.fromJson(label as Map<String, Object?>));
      }

      return (labels: labels, cursor: response.data['cursor'] as String?);
    });
  }

  @override
  Future<({String? cursor, List<StoriesByAuthor> storiesByAuthor})> getStoriesTimeline({int limit = 30, String? cursor}) {
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

      final response = await atproto.get(
        NSID.parse('so.sprk.feed.getStoriesTimeline'),
        parameters: {'limit': limit, 'cursor': cursor},
        headers: {'atproto-proxy': _client.sprkDid},
        to:
            (jsonMap) => (
              storiesByAuthor:
                  (jsonMap['storiesByAuthor'] as List<dynamic>).map((story) => StoriesByAuthor.fromJson(story)).toList(),
              cursor: jsonMap['cursor'] as String?,
            ),
      );

      return (storiesByAuthor: response.data.storiesByAuthor, cursor: response.data.cursor);
    });
  }

  @override
  Future<List<StoryView>> getStoryViews(List<AtUri> storyUris) {
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

      final response = await atproto.get(
        NSID.parse('so.sprk.feed.getStories'),
        parameters: {'storyUris': storyUris},
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) => (jsonMap['stories'] as List<dynamic>).map((story) => StoryView.fromJson(story)).toList(),
      );

      return response.data;
    });
  }
}
