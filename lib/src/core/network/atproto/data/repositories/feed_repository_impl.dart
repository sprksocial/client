import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:bluesky/bluesky.dart' as bsky;
// ignore: implementation_imports
import 'package:bluesky/src/services/entities/converter/embed_converter.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:sparksocial/src/core/config/app_config.dart';
import 'package:sparksocial/src/core/feed_algorithms/hardcoded_feed_algorithm.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';

/// Implementation of Feed-related API endpoints
class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._client) {
    _logger.v('FeedRepository initialized');
  }
  final SprkRepository _client;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger('FeedRepository');

  List<T> _parseAndFilterPosts<T>({
    required List<dynamic> rawPosts,
    required T Function(Map<String, dynamic>) fromJson,
    required PostView Function(T) getPostView,
    required String source,
  }) {
    final posts = <T>[];
    for (final rawPost in rawPosts) {
      try {
        final postData = rawPost is Map<String, dynamic> ? rawPost : rawPost.toJson();
        if (postData['reply'] != null) {
          continue;
        }
        final parsedPost = fromJson(postData as Map<String, dynamic>);
        final postView = getPostView(parsedPost);

        if (postView.hasSupportedMedia) {
          posts.add(parsedPost);
        } else {
          _logger.d('Filtered out $source post with unsupported embed type: ${postView.uri}');
        }
      } catch (e) {
        _logger.w('Failed to parse $source post, skipping: $e');
      }
    }
    return posts;
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
            to: FeedSkeleton.fromJson,
            adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
          );
          _logger.d('Feed skeleton retrieved successfully');
          return result.data;
        });
      case _:
        throw ArgumentError('Invalid feed: $feed');
    }
  }

  @override
  Future<List<PostView>> getPosts(List<AtUri> uris, {bool bluesky = false, bool filter = true}) async {
    _logger.d('Getting posts for URIs: ${uris.length} URIs');
    if (bluesky) {
      _logger.d('Getting posts on bluesky API for: ${uris.length} URIs');
      final blueskyClient = bsky.Bluesky.fromSession(_client.authRepository.session!);
      final posts = await blueskyClient.feed.getPosts(uris: uris);
      final filteredPosts = filter
          ? _parseAndFilterPosts<PostView>(
              rawPosts: posts.data.posts,
              fromJson: PostView.fromJson,
              getPostView: (post) => post,
              source: 'bsky',
            )
          : posts.data.posts.map((post) => PostView.fromJson(post.toJson())).toList();
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
          return _parseAndFilterPosts<PostView>(
            rawPosts: posts,
            fromJson: PostView.fromJson,
            getPostView: (post) => post,
            source: 'sprk',
          );
        },
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
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
          to: (jsonMap) {
            final rawFeed = jsonMap['feed']! as List<dynamic>;
            final feedPosts = _parseAndFilterPosts<FeedViewPost>(
              rawPosts: rawFeed,
              fromJson: FeedViewPost.fromJson,
              getPostView: (feedViewPost) => feedViewPost.post,
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
          filter: videosOnly ? bsky.FeedFilter.postsWithVideo : bsky.FeedFilter.postsWithMedia,
        );

        final filteredPosts = _parseAndFilterPosts<FeedViewPost>(
          rawPosts: resultBsky.data.feed.map((post) => post.toJson()).toList(),
          fromJson: FeedViewPost.fromJson,
          getPostView: (feedViewPost) => feedViewPost.post,
          source: 'bsky author feed',
        );

        _logger.d('Author feed retrieved successfully from Bsky');
        return (posts: filteredPosts, cursor: resultBsky.data.cursor);
      } catch (e) {
        _logger.e('Error getting author feed from Bsky', error: e);
        rethrow;
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
        // eventually use a like record class here for consistency
        r'$type': 'so.sprk.feed.like',
        'subject': {'cid': postCid, 'uri': postUri.toString()},
        'createdAt': DateTime.now().toUtc().toIso8601String(),
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

          // Upload images if provided
          Map<String, dynamic>? embedJson;
          if (imageFiles case final List<XFile> files when files.isNotEmpty) {
            _logger.d('Uploading ${files.length} images for comment');
            final uploadedImageMaps = await uploadImages(imageFiles: files, altTexts: altTexts);
            embedJson = EmbedImage(images: uploadedImageMaps).toJson();
          }

          // Create the correct record JSON depending on the target platform.
          final isSprk = parentUri.toString().contains('sprk');

          final Map<String, dynamic> recordJson;
          final NSID collection;

          if (isSprk) {
            // Sprk comment
            final sprkRecord = PostRecord(
              text: text,
              reply: RecordReplyRef(
                root: StrongRef(uri: effectiveRootUri, cid: effectiveRootCid),
                parent: StrongRef(uri: parentUri, cid: parentCid),
              ),
              createdAt: DateTime.now(),
              embed: embedJson != null ? Embed.fromJson(embedJson) : null,
            );
            recordJson = sprkRecord.toJson();
            collection = NSID.parse('so.sprk.feed.post');
          } else {
            // Bluesky comment
            final bskyRecord = bsky.PostRecord(
              text: text,
              createdAt: DateTime.now(),
              reply: bsky.ReplyRef(
                root: StrongRef(uri: effectiveRootUri, cid: effectiveRootCid),
                parent: StrongRef(uri: parentUri, cid: parentCid),
              ),
              embed: embedJson != null ? embedConverter.fromJson(embedJson) : null,
            );
            recordJson = bskyRecord.toJson();
            collection = NSID.parse('app.bsky.feed.post');
          }

          final result = await atproto.repo.createRecord(collection: collection, record: recordJson);

          _logger.i('Comment posted successfully: ${result.data.uri}');

          return result.data;
      }
    });
  }

  @override
  Future<StrongRef> postImages(
    String text,
    List<XFile> imageFiles,
    Map<String, String> altTexts, {
    bool crosspostToBsky = false,
  }) async {
    _logger.d('Creating image post with ${imageFiles.length} images, crosspost: $crosspostToBsky');

    switch (imageFiles) {
      case final List<XFile> files when files.isEmpty:
        _logger.e('No images provided for image post');
        throw ArgumentError('At least one image is required for an image post.');
      default:
        return _client.executeWithRetry(() async {
          if (!_client.authRepository.isAuthenticated) {
            _logger.w('Not authenticated');
            throw Exception('Not authenticated');
          }

          if (_client.authRepository.atproto case final atproto?) {
            final uploadedImageMaps = await uploadImages(imageFiles: imageFiles, altTexts: altTexts);

            // Create Sprk post first
            final record = PostRecord(
              text: text,
              embed: EmbedImage(images: uploadedImageMaps),
              createdAt: DateTime.now(),
            );

            final result = await atproto.repo.createRecord(collection: NSID.parse('so.sprk.feed.post'), record: record.toJson());

            _logger.i('Image post created successfully: ${result.data.uri}');

            // Crosspost to Bluesky if enabled
            if (crosspostToBsky) {
              try {
                await _crosspostToBlueSky(text, uploadedImageMaps, result.data, altTexts);
              } catch (e) {
                _logger.w('Failed to crosspost to Bluesky: $e');
                // Don't fail the entire operation if Bluesky crossposting fails
              }
            }

            return result.data;
          } else {
            _logger.e('AtProto not initialized');
            throw Exception('AtProto not initialized');
          }
        });
    }
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
                final response = await atproto.repo.uploadBlob(processedBytes);

                switch (response.status.code) {
                  case 200:
                    _logger.d('Image uploaded successfully: ${imageFile.name}');

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
  Future<Blob> uploadVideo(String videoPath) async {
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
        lxm: NSID.parse('com.atproto.repo.uploadBlob'),
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
      while (responseData['jobStatus']?['state'] == 'JOB_STATE_PROCESSING') {
        _logger.d('Video upload in progress, status: ${responseData['jobStatus']?['state']}');
        await Future.delayed(const Duration(seconds: 2));
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
        } else {
          responseData = jsonDecode(response.body);
          _logger.d('Video upload status response: $responseData');
        }
      }
      if (responseData['jobStatus']?['state'] == 'JOB_STATE_FAILED') {
        throw Exception('Video upload failed: ${responseData['jobStatus']?['status']}');
      }
      Map<String, dynamic> blob;
      if (responseData case {'jobStatus': {'blob': final blobData}}) {
        blob = blobData as Map<String, dynamic>;
      } else if (responseData case {'blobRef': final blobRef}) {
        blob = blobRef as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response format: $responseData');
      }
      return Blob.fromJson(blob);
    });
  }

  /// Crosspost images to Bluesky using same blobs but Bluesky models
  Future<void> _crosspostToBlueSky(
    String text,
    List<Image> sparkImages,
    StrongRef sparkPostData,
    Map<String, String> altTexts,
  ) async {
    _logger.d('Crossposting to Bluesky with ${sparkImages.length} images');

    // Convert Spark images to Bluesky images and handle 4-image limit
    final bskyImages = <bsky.Image>[];
    const maxBskyImages = 4;
    final imagesToUse = sparkImages.take(maxBskyImages).toList();

    for (final sparkImage in imagesToUse) {
      bskyImages.add(
        bsky.Image(
          alt: sparkImage.alt ?? '',
          image: sparkImage.image, // Use the same blob
        ),
      );
    }

    // Determine final text for Bluesky post
    var finalText = text;
    final facets = <bsky.Facet>[];

    // If more than 4 images, add link to Spark post
    if (sparkImages.length > maxBskyImages) {
      final sparkRkey = sparkPostData.uri.rkey;
      final uriDid = sparkPostData.uri.hostname;
      final sparkLink = 'https://watch.sprk.so/?uri=$uriDid/$sparkRkey';

      if (text.isEmpty) {
        finalText = sparkLink;
        // Create facet for the entire text (which is just the link)
        facets.add(
          bsky.Facet(
            index: bsky.ByteSlice(byteStart: 0, byteEnd: sparkLink.length),
            features: [bsky.FacetFeature.link(data: bsky.FacetLink(uri: sparkLink))],
          ),
        );
      } else {
        final linkWithNewlines = '\n\n$sparkLink';
        final availableTextLength = 300 - linkWithNewlines.length;

        if (text.length <= availableTextLength) {
          finalText = '$text$linkWithNewlines';
          // Create facet for the link part
          final linkStart = text.length + 2; // +2 for the \n\n
          facets.add(
            bsky.Facet(
              index: bsky.ByteSlice(byteStart: linkStart, byteEnd: linkStart + sparkLink.length),
              features: [bsky.FacetFeature.link(data: bsky.FacetLink(uri: sparkLink))],
            ),
          );
        } else {
          const ellipsis = '...';
          final croppedTextLength = availableTextLength - ellipsis.length;
          final croppedText = text.substring(0, croppedTextLength);
          finalText = '$croppedText$ellipsis$linkWithNewlines';
          // Create facet for the link part
          final linkStart = croppedText.length + ellipsis.length + 2; // +2 for the \n\n
          facets.add(
            bsky.Facet(
              index: bsky.ByteSlice(byteStart: linkStart, byteEnd: linkStart + sparkLink.length),
              features: [bsky.FacetFeature.link(data: bsky.FacetLink(uri: sparkLink))],
            ),
          );
        }
      }
    }

    final bskyPost = bsky.PostRecord(
      text: finalText,
      createdAt: DateTime.now().toUtc(),
      embed: bsky.Embed.images(data: bsky.EmbedImages(images: bskyImages)),
      facets: facets,
    );

    final bskyAtProto = _client.authRepository.atproto!;
    final bskyResult = await bskyAtProto.repo.createRecord(
      collection: NSID.parse('app.bsky.feed.post'),
      record: bskyPost.toJson(),
      rkey: sparkPostData.uri.rkey,
    );

    _logger.i('Successfully crossposted to Bluesky: ${bskyResult.data.uri}');
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
            _logger.i('Post deleted successfully: $postUri');
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

      if (response.status == HttpStatus.ok) {
        _logger.i('Video posted successfully: ${response.data.uri}');
        return response.data;
      } else {
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

      // Get the post thread
      if (bluesky) {
        final bluesky = bsky.Bluesky.fromSession(_client.authRepository.session!);
        final response = await bluesky.feed.getPostThread(uri: uri, depth: depth, parentHeight: parentHeight);
        return Thread.fromBsky(thread: response.data.thread, uri: uri);
      }
      const source = 'so.sprk.feed.getPostThread';
      final response = await atproto.get(
        NSID.parse(source),
        parameters: {'uri': uri.toString(), 'depth': depth, 'parentHeight': parentHeight},
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) {
          return Thread.fromJson(jsonMap['thread']! as Map<String, dynamic>);
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
  Future<({String? cursor, Map<ProfileViewBasic, List<StoryView>> storiesByAuthor})> getStoriesTimeline({
    int limit = 30,
    String? cursor,
  }) {
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
        to: (jsonMap) {
          final storiesByAuthorMap = <ProfileViewBasic, List<StoryView>>{};

          final storiesByAuthorArray = jsonMap['storiesByAuthor']! as List<dynamic>;
          for (final item in storiesByAuthorArray) {
            final itemMap = item as Map<String, dynamic>;
            final author = ProfileViewBasic.fromJson(itemMap['author'] as Map<String, dynamic>);
            final stories = (itemMap['stories'] as List<dynamic>)
                .map((story) => StoryView.fromJson(story as Map<String, dynamic>))
                .toList();
            storiesByAuthorMap[author] = stories;
          }

          return (storiesByAuthor: storiesByAuthorMap, cursor: jsonMap['cursor'] as String?);
        },
      );

      return response.data;
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
        parameters: {'uris': storyUris},
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) =>
            (jsonMap['stories']! as List<dynamic>).map((story) => StoryView.fromJson(story as Map<String, dynamic>)).toList(),
      );

      return response.data;
    });
  }

  @override
  Future<StrongRef> postStory(Embed embed, {List<SelfLabel>? selfLabels, List<String>? tags}) {
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final record = StoryRecord(createdAt: DateTime.now(), media: embed, selfLabels: selfLabels, tags: tags);

      final response = await _client.authRepository.atproto!.repo.createRecord(
        collection: NSID.parse('so.sprk.feed.story'),
        record: record.toJson(),
      );

      if (response.status == HttpStatus.ok) {
        _logger.i('Story posted successfully: ${response.data.uri}');
        return response.data;
      } else {
        _logger.e('Failed to post story: ${response.status} ${response.data}');
        throw Exception('Failed to post story: ${response.status} ${response.data}');
      }
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
