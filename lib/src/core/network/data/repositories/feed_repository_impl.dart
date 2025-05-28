import 'dart:convert';
import 'dart:typed_data';

import 'package:atproto/core.dart';
import 'package:atproto/atproto.dart';
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
  Future<PostThreadResponse> getPostThread(String postUri) async {
    _logger.d('Getting post thread for URI: $postUri');
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
        NSID.parse('so.sprk.feed.getPostThread'),
        parameters: {'uri': postUri},
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Post thread retrieved successfully');
      return PostThreadResponse.fromJson(result.data as Map<String, dynamic>);
    });
  }

  @override
  Future<FeedSkeleton> getFeedSkeleton(String feed, {int limit = 8}) async {
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
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Feed skeleton retrieved successfully');
      return FeedSkeleton.fromJson(result.data as Map<String, dynamic>);
    });
  }

  @override
  Future<Map<String, dynamic>> getPosts(List<String> uris) async {
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
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Posts retrieved successfully');
      return result.data as Map<String, dynamic>;
    });
  }

  @override
  Future<AuthorFeedResponse> getAuthorFeed(String actor, {int limit = 20, String? cursor, bool videosOnly = false}) async {
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
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Author feed retrieved successfully');
      return AuthorFeedResponse.fromJson(result.data);
    });
  }

  @override
  Future<StrongRef> likePost(String postCid, String postUri) async {
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
  Future<void> unlikePost(String likeUri) async {
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

      await atproto.repo.deleteRecord(uri: AtUri.parse(likeUri));
      _logger.i('Post unliked successfully');
    });
  }

  @override
  Future<StrongRef> postComment(
    String text,
    String parentCid,
    String parentUri, {
    String? rootCid,
    String? rootUri,
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
          final postType = switch (parentUri) {
            String uri when RegExp(r'^at://[^/]+/so\.sprk\.feed\.post/[^/]+$').hasMatch(uri) => "so.sprk.feed.post",
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
  Future<bool> deletePost(String postUri) async {
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

      // Ensure the URI starts with 'at://'
      final normalizedUri = switch (postUri) {
        String uri when uri.startsWith('at://') => uri,
        _ => 'at://$postUri',
      };

      try {
        final response = await atproto.repo.deleteRecord(uri: AtUri.parse(normalizedUri));

        switch (response.status.code) {
          case 200:
            _logger.i('Post deleted successfully: $normalizedUri');
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

      final record = PostRecord.video(
        text: text,
        embed: VideoEmbed(video: blob, type: 'so.sprk.embed.video', alt: alt),
        createdAt: DateTime.now(),
        langs: langs,
        selfLabels: selfLabels,
        tags: tags,
        // TODO: facets here
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
  Future<List<Comment>> getBlueskyComments(String postUri) async {
    _logger.d('Getting Bluesky comments for post: $postUri');

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
        // Parse the post URI
        final uri = AtUri.parse(postUri);

        // Get the post thread
        final response = await atproto.get(
          NSID.parse('app.bsky.feed.getPostThread'),
          parameters: {'uri': uri.toString(), 'depth': 10},
          to: (jsonMap) => jsonMap,
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
        );

        // Extract the replies from the thread
        final thread = (response.data as Map<String, dynamic>)['thread'] as Map<String, dynamic>;
        final replies = _extractBlueskyReplies(thread);

        _logger.d('Retrieved ${replies.length} Bluesky comments');
        return replies;
      } catch (e) {
        _logger.e('Failed to load Bluesky comments', error: e);
        throw Exception('Failed to load comments: ${e.toString()}');
      }
    });
  }

  @override
  Future<List<Comment>> getSparkComments(String postUri) async {
    _logger.d('Getting Spark comments for post: $postUri');

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
        final response = await atproto.get(
          NSID.parse('so.sprk.feed.getPostThread'),
          parameters: {'uri': postUri},
          headers: {'atproto-proxy': _client.sprkDid},
          to: (jsonMap) => jsonMap,
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
        );

        // Extract comments from the thread
        final thread = (response.data as Map<String, dynamic>)['thread'] as Map<String, dynamic>?;
        if (thread == null) {
          _logger.w('No thread data found for post: $postUri');
          return [];
        }

        final replies = _extractSparkReplies(thread);

        _logger.d('Retrieved ${replies.length} Spark comments');
        return replies;
      } catch (e) {
        _logger.e('Failed to load Spark comments', error: e);
        throw Exception('Failed to load comments: ${e.toString()}');
      }
    });
  }

  @override
  Future<Comment> getSparkComment(String commentUri) async {
    _logger.d('Getting Spark comment: $commentUri');

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
        final response = await atproto.repo.getRecord(uri: AtUri.parse(commentUri));

        return Comment.fromSparkCommentRecord(response.data.value, commentUri);
      } catch (e) {
        _logger.e('Failed to get Spark comment', error: e);
        throw Exception('Failed to get comment: ${e.toString()}');
      }
    });
  }

  @override
  Future<Comment> getBlueskyComment(String commentUri) async {
    _logger.d('Getting Bluesky comment: $commentUri');

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
        final response = await atproto.get(
          NSID.parse('app.bsky.feed.getPostThread'),
          parameters: {'uri': AtUri.parse(commentUri).toString()},
          to: (jsonMap) => jsonMap,
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
        );

        final post = ((response.data as Map<String, dynamic>)['thread'] as Map<String, dynamic>)['post'];

        if (post == null) {
          _logger.e('Failed to get Bluesky comment: Post not found');
          throw Exception('Failed to get comment: Post not found');
        }

        return Comment.fromBlueskyComment(post as Map<String, dynamic>);
      } catch (e) {
        _logger.e('Failed to get Bluesky comment', error: e);
        throw Exception('Failed to get comment: ${e.toString()}');
      }
    });
  }

  /// Extract replies from a Bluesky thread
  List<Comment> _extractBlueskyReplies(Map<String, dynamic> thread) {
    final List<Comment> result = [];

    // Skip the root post, only include replies
    final replies = thread['replies'] as List<dynamic>?;
    if (replies == null) {
      return result;
    }

    for (final reply in replies) {
      final post = reply['post'] as Map<String, dynamic>?;
      if (post == null) {
        continue;
      }

      // Create comment from the post
      final comment = Comment.fromBlueskyComment(post);

      // Process any nested replies if they exist
      final nestedReplies = reply['replies'] as List<dynamic>?;
      final List<Comment> commentReplies = [];
      if (nestedReplies != null) {
        for (final nestedReply in nestedReplies) {
          final nestedPost = nestedReply['post'] as Map<String, dynamic>?;
          if (nestedPost != null) {
            commentReplies.add(Comment.fromBlueskyComment(nestedPost));
          }
        }
      }

      // Add the comment with its nested replies
      result.add(
        Comment(
          id: comment.id,
          uri: comment.uri,
          cid: comment.cid,
          authorDid: comment.authorDid,
          username: comment.username,
          profileImageUrl: comment.profileImageUrl,
          text: comment.text,
          createdAt: comment.createdAt,
          likeCount: comment.likeCount,
          replyCount: commentReplies.length,
          hashtags: comment.hashtags,
          hasMedia: comment.hasMedia,
          mediaType: comment.mediaType,
          mediaUrl: comment.mediaUrl,
          likeUri: comment.likeUri,
          isSprk: comment.isSprk,
          replies: commentReplies,
          imageUrls: comment.imageUrls,
        ),
      );
    }

    return result;
  }

  /// Extract replies from a Spark thread
  List<Comment> _extractSparkReplies(Map<String, dynamic> thread) {
    final List<Comment> result = [];

    // Skip the root post, only include replies
    final replies = thread['replies'] as List<dynamic>?;
    if (replies == null) {
      return result;
    }

    for (final reply in replies) {
      final post = reply['post'] as Map<String, dynamic>?;
      if (post == null) {
        continue;
      }

      // Create comment from the post
      final comment = Comment.fromSparkComment(post);

      // Process any nested replies if they exist
      final List<Comment> nestedReplies = [];
      if (reply['replies'] != null) {
        final nestedRepliesData = reply['replies'] as List<dynamic>?;
        if (nestedRepliesData != null) {
          for (final nestedReply in nestedRepliesData) {
            final nestedPost = nestedReply['post'] as Map<String, dynamic>?;
            if (nestedPost != null) {
              nestedReplies.add(Comment.fromSparkComment(nestedPost));
            }
          }
        }
      }

      // Add the comment with its nested replies
      result.add(
        Comment(
          id: comment.id,
          uri: comment.uri,
          cid: comment.cid,
          authorDid: comment.authorDid,
          username: comment.username,
          profileImageUrl: comment.profileImageUrl,
          text: comment.text,
          createdAt: comment.createdAt,
          likeCount: comment.likeCount,
          replyCount: nestedReplies.length,
          hashtags: comment.hashtags,
          hasMedia: comment.hasMedia,
          mediaType: comment.mediaType,
          mediaUrl: comment.mediaUrl,
          likeUri: comment.likeUri,
          isSprk: comment.isSprk,
          replies: nestedReplies,
          imageUrls: comment.imageUrls,
        ),
      );
    }

    return result;
  }
}
