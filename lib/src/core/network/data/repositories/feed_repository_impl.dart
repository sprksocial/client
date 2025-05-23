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
import 'package:sparksocial/src/core/network/data/models/repo_models.dart';
import 'package:sparksocial/src/core/network/data/repositories/label_repository.dart';

/// Implementation of Feed-related API endpoints
class FeedRepositoryImpl implements FeedRepository {
  final SprkRepository _client;
  final _logger = GetIt.instance<LogService>().getLogger('FeedRepository');
  final LabelRepository _labelRepository;

  FeedRepositoryImpl(this._client, this._labelRepository) {
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
  Future<FeedSkeletonResponse> getFeedSkeleton(String feed, {int limit = 8}) async {
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
      return FeedSkeletonResponse.fromJson(result.data as Map<String, dynamic>);
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
  Future<AuthorFeedResponse> getAuthorFeed(String actor, {int limit = 8, String? cursor}) async {
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
      return AuthorFeedResponse.fromJson(result.data as Map<String, dynamic>);
    });
  }

  @override
  Future<LikePostResponse> likePost(String postCid, String postUri) async {
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

      return LikePostResponse(uri: result.data.uri.toString(), cid: result.data.cid);
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
  Future<CommentPostResponse> postComment(
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
            final List<Map<String, dynamic>> uploadedImageMaps = await _uploadImages(files, altTexts ?? {});
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

          return CommentPostResponse(uri: result.data.uri.toString(), cid: result.data.cid);
      }
    });
  }

  @override
  Future<RecordResponse> postImageFeed(String text, List<XFile> imageFiles, Map<String, String> altTexts) async {
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
            final List<Map<String, dynamic>> uploadedImageMaps = await _uploadImages(imageFiles, altTexts);
            final embed = {"\$type": "so.sprk.embed.images", 'images': uploadedImageMaps};

            final record = {
              "\$type": "so.sprk.feed.post",
              'text': text,
              'embed': embed,
              'createdAt': DateTime.now().toUtc().toIso8601String(),
            };

            final result = await atproto.repo.createRecord(collection: NSID.parse('so.sprk.feed.post'), record: record);

            _logger.i('Image post created successfully: ${result.data.uri}');

            return RecordResponse(uri: result.data.uri.toString(), cid: result.data.cid, value: record);
          } else {
            _logger.e('AtProto not initialized');
            throw Exception('AtProto not initialized');
          }
        });
    }
  }

  /// Helper to upload multiple images, stripping EXIF, and return a list of JSON maps for embedding
  Future<List<Map<String, dynamic>>> _uploadImages(List<XFile> imageFiles, Map<String, String> altTexts) async {
    _logger.d('Processing ${imageFiles.length} images for upload');

    final List<Map<String, dynamic>> uploadedImageMaps = [];
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
                    uploadedImageMaps.add({
                      "\$type": "so.sprk.embed.images#image",
                      "alt": altTexts[imageFile.path] ?? '',
                      "image": response.data.blob.toJson(),
                    });
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
  Future<StrongRef> postVideo(BlobReference? videoData, {String description = '', String videoAltText = ''}) async {
    _logger.d('Posting video with description: $description');

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      switch (videoData) {
        case null:
          _logger.e('Video data is null');
          throw Exception('Video data is null');
        case final data:
          // Create a VideoPost object with the provided data
          final videoPost = VideoPost.create(text: description, videoData: data.toJson(), videoAltText: videoAltText);

          // Use the common implementation
          return postVideoWithPost(videoPost);
      }
    });
  }

  @override
  Future<StrongRef> postVideoWithPost(VideoPost videoPost) async {
    _logger.d('Posting video with prepared VideoPost');

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
          // Convert the VideoPost to its raw format for the API
          final postRecord = videoPost.toJson();

          // Create the post record
          final recordRes = await atproto.repo.createRecord(collection: NSID.parse('so.sprk.feed.post'), record: postRecord);

          switch (recordRes.status) {
            case HttpStatus.ok:
              _logger.i('Video posted successfully: ${recordRes.data.uri}');
              return recordRes.data;
            default:
              _logger.e('Failed to post video: ${recordRes.status} ${recordRes.data}');
              throw Exception('Failed to post video: ${recordRes.status} ${recordRes.data}');
          }
      }
    });
  }

  @override
  Future<List<FeedPost>> fetchFeed(int feedType, {int limit = 8}) async {
    _logger.d('Fetching feed type: $feedType, limit: $limit');

    return switch (feedType) {
      0 => fetchFollowingFeed(limit: limit),
      1 => fetchForYouFeed(limit: limit),
      2 => fetchSparkNewFeed(limit: limit),
      _ => fetchForYouFeed(limit: limit),
    };
  }

  @override
  Future<List<FeedPost>> fetchFollowingFeed({int limit = 8}) async {
    _logger.d('Fetching following feed with limit: $limit');

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
          // Get timeline feed
          final result = await atproto.get(
            NSID.parse('app.bsky.feed.getTimeline'),
            parameters: {'limit': limit},
            to: (jsonMap) => jsonMap,
            adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
          );

          _logger.d('Timeline feed retrieved successfully');

          // Parse result into feed items
          final feedItems = switch (result.data['feed']) {
            List<dynamic> items => items.cast<Map<String, dynamic>>(),
            _ => <Map<String, dynamic>>[],
          };

          // Convert to FeedPost models
          final allPosts = feedItems.map((item) => _convertToFeedPost(item, false)).toList();

          // Filter posts to only show those with media that aren't replies
          final filteredPosts = allPosts.where((post) => post.hasMedia && !post.isReply).toList();

          // Fetch and apply labels
          return await _labelRepository.fetchLabelsForPosts(filteredPosts);
      }
    });
  }

  @override
  Future<List<FeedPost>> fetchForYouFeed({int limit = 8}) async {
    _logger.d('Fetching For You feed with limit: $limit');

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
          // Get feed from "thevids" generator
          final result = await atproto.get(
            NSID.parse('app.bsky.feed.getFeed'),
            parameters: {'feed': 'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/thevids', 'limit': limit},
            to: (jsonMap) => jsonMap,
            adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
          );

          _logger.d('For You feed retrieved successfully');

          // Parse result into feed items
          final feedItems = switch (result.data['feed']) {
            List<dynamic> items => items.cast<Map<String, dynamic>>(),
            _ => <Map<String, dynamic>>[],
          };

          // Convert to FeedPost models
          final allPosts = feedItems.map((item) => _convertToFeedPost(item, false)).toList();

          // Filter posts to only show those with media that aren't replies
          final filteredPosts = allPosts.where((post) => post.hasMedia && !post.isReply).toList();

          // Fetch and apply labels
          return await _labelRepository.fetchLabelsForPosts(filteredPosts);
      }
    });
  }

  @override
  Future<List<FeedPost>> fetchSparkNewFeed({int limit = 8}) async {
    _logger.d('Fetching Spark New feed with limit: $limit');

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      // Get feed skeleton with simple-desc feed
      final feedSkeleton = await getFeedSkeleton('simple-desc', limit: limit);

      // Extract post URIs
      final uris = feedSkeleton.feed.map((item) => item.post).toList();

      if (uris.isEmpty) {
        _logger.d('No posts found in Spark New feed');
        return [];
      }

      // Get the actual posts using the URIs
      final result = await getPosts(uris);

      _logger.d('Result: $result');

      final feedItems = switch (result['posts']) {
        List<dynamic> items => items.cast<Map<String, dynamic>>(),
        _ => <Map<String, dynamic>>[],
      };

      // Convert to FeedPost models
      final allPosts = feedItems.map((item) => _convertToFeedPost(item, false)).toList();

      // Filter posts to only show those with media that aren't replies
      final filteredPosts = allPosts.where((post) => post.hasMedia && !post.isReply).toList();

      // Fetch and apply labels
      return await _labelRepository.fetchLabelsForPosts(filteredPosts);
    });
  }

  /// Helper method to convert API response to FeedPost model
  FeedPost _convertToFeedPost(Map<String, dynamic> feedItem, bool isSprk) {
    _logger.v('Converting feed item to FeedPost (isSprk: $isSprk)');

    try {
      // Extract post data based on structure
      final postData = switch ((feedItem, isSprk)) {
        ({'post': Map<String, dynamic> post}, true) => post,
        ({'post': Map<String, dynamic> post}, false) => post,
        (Map(), true) => <String, dynamic>{},
        (_, false) => feedItem,
      };

      // Extract record and author data
      final (recordData, authorData) = switch (postData) {
        {'record': Map<String, dynamic> record, 'author': Map<String, dynamic> author} => (record, author),
        _ => (<String, dynamic>{}, <String, dynamic>{}),
      };

      // Extract text
      final text = recordData['text'] as String? ?? '';

      // Default media information
      var hasMedia = false;
      var imageUrls = <String>[];
      String? videoUrl;
      var imageAlts = <String>[];
      String? videoAlt;

      // Extract media information from embeds
      if (postData case {'embed': Map<String, dynamic> embedData}) {
        switch (embedData) {
          // Handle image embeds
          case {r'$type': String type} when type.contains('images'):
            hasMedia = true;

            if (embedData case {'images': List<dynamic> images}) {
              for (final imageItem in images) {
                if (imageItem case Map<String, dynamic> imageData) {
                  // Handle image URLs differently based on source
                  if (isSprk) {
                    if (imageData case {'fullsize': String fullsize}) {
                      imageUrls.add(fullsize);
                    }
                    if (imageData case {'alt': String alt}) {
                      imageAlts.add(alt);
                    }
                  } else {
                    if (imageData case {'fullsize': String fullsize}) {
                      imageUrls.add(fullsize);
                    }
                    if (imageData case {'alt': String alt}) {
                      imageAlts.add(alt);
                    }
                  }
                }
              }
            }

          // Handle video embeds
          case {r'$type': String type} when type.contains('video'):
            hasMedia = true;

            // Extract video URL - different structures depending on source
            videoUrl = switch (embedData) {
              {'playlist': String playlist} => playlist,
              {'video': Map<String, dynamic> video} => switch (video) {
                {'ref': String ref} => ref,
                _ => null,
              },
              _ => null,
            };

            // Extract video alt text
            videoAlt = embedData['alt'] as String?;
        }
      }

      // Check if post is a reply
      final isReply = recordData.containsKey('reply');

      // Extract like URI
      final likeUri = switch (postData) {
        {'viewer': Map<String, dynamic> viewer} => switch (viewer) {
          {'like': String like} => like,
          _ => null,
        },
        _ => null,
      };

      // Count values
      final likeCount = postData['likeCount'] as int? ?? 0;
      final commentCount = postData['replyCount'] as int? ?? 0;

      // Extract hashtags from text
      final hashtags = _extractHashtags(text);

      // Create FeedPost
      return FeedPost(
        username: authorData['handle'] as String? ?? '',
        authorDid: authorData['did'] as String? ?? '',
        profileImageUrl: authorData['avatar'] as String?,
        description: text,
        videoUrl: videoUrl,
        likeCount: likeCount,
        commentCount: commentCount,
        shareCount: 0, // Not provided in API
        hashtags: hashtags,
        labels: [], // Will be populated by _fetchLabelsForPosts
        imageUrls: imageUrls,
        uri: postData['uri'] as String? ?? '',
        cid: postData['cid'] as String? ?? '',
        isSprk: isSprk,
        likeUri: likeUri,
        hasMedia: hasMedia,
        isReply: isReply,
        imageAlts: imageAlts,
        videoAlt: videoAlt,
      );
    } catch (e) {
      _logger.e('Error converting feed item to FeedPost', error: e);
      // Return an empty FeedPost to prevent null errors
      return FeedPost(username: '', authorDid: '', description: 'Error loading post', uri: '', cid: '', hasMedia: false);
    }
  }

  /// Extract hashtags from text
  List<String> _extractHashtags(String text) {
    final matches = RegExp(r'#(\w+)').allMatches(text);
    return switch (matches) {
      final matches when matches.isNotEmpty => matches.map((m) => m.group(1)!).toList(),
      _ => [],
    };
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
