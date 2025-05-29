import 'dart:convert';
import 'dart:typed_data';

import 'package:atproto/core.dart';
import 'package:atproto/atproto.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';
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
  Future<FeedSkeleton> getFeedSkeleton(AtUri feed, {int limit = 8}) async {
    _logger.d('Getting feed skeleton for feed: $feed, limit: $limit');
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
        parameters: {'feed': feed, 'limit': limit},
        service: 'feeds.sprk.so',
        to: (jsonMap) => FeedSkeleton.fromJson(jsonMap),
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Feed skeleton retrieved successfully');
      return result.data;
    });
  }

  @override
  Future<List<PostView>> getPosts(List<AtUri> uris) async {
    _logger.d('Getting posts for URIs: ${uris.length} URIs');
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
          return posts.map((post) => PostView.fromJson(post)).toList();
        },
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Posts retrieved successfully');

      return result.data;
    });
  }

  @override
  Future<({List<FeedViewPost> posts, String? cursor})> getAuthorFeed(
    String actor, {
    int limit = 20,
    String? cursor,
    bool videosOnly = false,
  }) async {
    _logger.d('Getting author feed for actor: $actor, limit: $limit, cursor: $cursor');
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

      final parameters = <String, dynamic>{'actor': actor, 'limit': limit};

      if (videosOnly) {
        parameters['filter'] = 'posts_with_video';
      } else {
        parameters['filter'] = 'posts_with_media';
      }

      if (cursor != null) {
        parameters['cursor'] = cursor;
      }

      final result = await atproto.get(
        NSID.parse('so.sprk.feed.getAuthorFeed'),
        parameters: parameters,
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) => (
          posts: (jsonMap['posts'] as List<dynamic>).map((post) => FeedViewPost.fromJson(post)).toList(),
          cursor: jsonMap['cursor'] as String?,
        ),
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Author feed retrieved successfully');
      return result.data;
    });
  }

  @override
  Future<StrongRef> likePost(String postCid, AtUri postUri) async {
    _logger.d('Liking post with CID: $postCid, URI: $postUri');
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
        "subject": {"cid": postCid, "uri": postUri},
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
          final postType = switch (parentUri.origin) {
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
              "root": {"cid": effectiveRootCid, "uri": effectiveRootUri},
              "parent": {"cid": parentCid, "uri": parentUri},
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
        embed: Embed.video(
          video: VideoEmbed(video: blob, alt: alt),
        ),
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
        final source = bluesky ? 'app.bsky.feed.getPostThread' : 'so.sprk.feed.getThread';
        final response = await atproto.get(
          NSID.parse(source),
          parameters: {'uri': uri.toString(), 'depth': depth, 'parentHeight': parentHeight},
          to: (jsonMap) => Thread.fromJson(jsonMap),
        );

        return response.data;
      } catch (e) {
        _logger.e('Failed to load Bluesky comments', error: e);
        throw Exception('Failed to load comments: ${e.toString()}');
      }
    });
  }

  @override
  Future<({List<bsky.FeedView> bsky, List<PostView> sprk, String? cursor})> getPostsByFeed(
    Feed feed, {
    int limit = 8,
    String? cursor,
  }) async {
    _logger.d('Getting posts by feed: $feed, limit: $limit, cursor: $cursor');
    final blueskySession = bsky.Bluesky.fromSession(_client.authRepository.session!);
    final bskyFeed = <bsky.FeedView>[];
    final sprkFeed = <PostView>[];

    switch (feed) {
      case FeedHardCoded(:final hardCodedFeed):
        switch (hardCodedFeed) {
          case HardCodedFeed.following:
            // bsky feed
            final unfilteredBskyFeed = (await blueskySession.feed.getTimeline(limit: limit, cursor: cursor)).data.feed;
            bskyFeed.addAll(
              unfilteredBskyFeed.where((feedview) {
                return feedview.post.embed != null && feedview.post.record.reply == null;
              }),
            );

          // sprk feed
          // TODO: spark following feed
          case HardCodedFeed.forYou:
            // bsky feed
            final unfilteredBskyFeed = (await blueskySession.feed.getFeed(
              generatorUri: AtUri.parse('at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/thevids'),
              limit: limit,
              cursor: cursor,
            )).data.feed;

            bskyFeed.addAll(
              unfilteredBskyFeed.where((feedview) {
                return feedview.post.embed != null && feedview.post.record.reply == null;
              }),
            );

          // sprk feed
          // TODO: spark for you feed
          case HardCodedFeed.latestSprk:
            // no bsky feed
            // sprk feed
            final skeleton = await _getFeedSkeletonHardcoded('simple-desc', limit: limit);
            final hydratedFeed = <PostView>[];
            final uris = skeleton.feed.map((post) => post.uri).toList();
            hydratedFeed.addAll(await getPosts(uris));
            hydratedFeed.sort((a, b) => b.indexedAt.compareTo(a.indexedAt));
            sprkFeed.addAll(hydratedFeed);
          case HardCodedFeed.mutuals:
          // TODO: spark mutuals feed
          case HardCodedFeed.shared:
          // TODO: spark shared feed
        }
      case FeedCustom():
      // TODO: custom feeds
      default:
        return (bsky: bskyFeed, sprk: sprkFeed, cursor: null);
    }
    return (bsky: bskyFeed, sprk: sprkFeed, cursor: null);
  }

  // this exists just because feeds are not real yet
  Future<FeedSkeleton> _getFeedSkeletonHardcoded(String feed, {int limit = 8}) async {
    _logger.d('Getting feed skeleton for feed: $feed, limit: $limit');
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
        parameters: {'feed': feed, 'limit': limit},
        service: 'feeds.sprk.so',
        to: (jsonMap) => FeedSkeleton.fromJson(jsonMap),
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Feed skeleton retrieved successfully');
      return result.data;
    });
  }
}
