import 'dart:convert';
import 'dart:typed_data';

import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository_impl.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/repo_models.dart';

/// Implementation of Feed-related API endpoints
class FeedRepositoryImpl implements FeedRepository {
  final SprkRepositoryImpl _client;
  final _logger = GetIt.instance<LogService>().getLogger('FeedRepository');

  FeedRepositoryImpl(this._client) {
    _logger.v('FeedRepository initialized');
  }

  @override
  Future<PostThreadResponse> getPostThread(String postUri) async {
    _logger.d('Getting post thread for URI: $postUri');
    return _client.executeWithRetry(() async {
      if (!_client.authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authService.atproto;
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
  Future<FeedSkeletonResponse> getFeedSkeleton(String feed, {int limit = 30}) async {
    _logger.d('Getting feed skeleton for feed: $feed, limit: $limit');
    return _client.executeWithRetry(() async {
      if (!_client.authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authService.atproto;
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
  Future<PostsResponse> getPosts(List<String> uris) async {
    _logger.d('Getting posts for URIs: ${uris.length} URIs');
    return _client.executeWithRetry(() async {
      if (!_client.authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authService.atproto;
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
      return PostsResponse.fromJson(result.data as Map<String, dynamic>);
    });
  }

  @override
  Future<AuthorFeedResponse> getAuthorFeed(String actor) async {
    _logger.d('Getting author feed for actor: $actor');
    return _client.executeWithRetry(() async {
      if (!_client.authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.get(
        NSID.parse('so.sprk.feed.getAuthorFeed'),
        parameters: {'actor': actor},
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
      if (!_client.authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final likeRecord = {
        "\$type": "so.sprk.feed.like",
        "subject": {"cid": postCid, "uri": postUri},
        "createdAt": DateTime.now().toUtc().toIso8601String(),
      };

      final result = await atproto.repo.createRecord(
        collection: NSID.parse('so.sprk.feed.like'),
        record: likeRecord
      );
      
      _logger.i('Post liked successfully: ${result.data.uri}');
      
      return LikePostResponse(
        uri: result.data.uri.toString(),
        cid: result.data.cid,
      );
    });
  }
  
  @override
  Future<void> unlikePost(String likeUri) async {
    _logger.d('Unliking post with like URI: $likeUri');
    return _client.executeWithRetry(() async {
      if (!_client.authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authService.atproto;
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
      if (!_client.authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      // If root isn't provided, use parent as root
      rootCid ??= parentCid;
      rootUri ??= parentUri;
      
      // Upload images and prepare embed JSON if provided
      Map<String, dynamic>? embedJson;
      if (imageFiles != null && imageFiles.isNotEmpty) {
        _logger.d('Uploading ${imageFiles.length} images for comment');
        final List<Map<String, dynamic>> uploadedImageMaps = await _uploadImages(imageFiles, altTexts ?? {});
        embedJson = {"\$type": "so.sprk.embed.images", "images": uploadedImageMaps};
      }

      final commentRecord = <String, dynamic>{
        "\$type": "so.sprk.feed.post",
        "text": text,
        "reply": {
          "root": {"cid": rootCid, "uri": rootUri},
          "parent": {"cid": parentCid, "uri": parentUri},
        },
        "createdAt": DateTime.now().toUtc().toIso8601String(),
      };

      // Add embed JSON if images were uploaded
      if (embedJson != null) {
        commentRecord['embed'] = embedJson;
      }

      final result = await atproto.repo.createRecord(
        collection: NSID.parse('so.sprk.feed.post'),
        record: commentRecord
      );
      
      _logger.i('Comment posted successfully: ${result.data.uri}');
      
      return CommentPostResponse(
        uri: result.data.uri.toString(),
        cid: result.data.cid,
      );
    });
  }
  
  @override
  Future<RecordResponse> postImageFeed(
    String text,
    List<XFile> imageFiles,
    Map<String, String> altTexts,
  ) async {
    _logger.d('Creating image post with ${imageFiles.length} images');
    
    if (imageFiles.isEmpty) {
      _logger.e('No images provided for image post');
      throw ArgumentError('At least one image is required for an image post.');
    }

    return _client.executeWithRetry(() async {
      if (!_client.authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final List<Map<String, dynamic>> uploadedImageMaps = await _uploadImages(imageFiles, altTexts);
      final embed = {"\$type": "so.sprk.embed.images", 'images': uploadedImageMaps};

      final record = {
        "\$type": "so.sprk.feed.post",
        'text': text,
        'embed': embed,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      };
      
      final result = await atproto.repo.createRecord(
        collection: NSID.parse('so.sprk.feed.post'),
        record: record,
      );
      
      _logger.i('Image post created successfully: ${result.data.uri}');
      
      return RecordResponse(
        uri: result.data.uri.toString(),
        cid: result.data.cid,
        value: record,
      );
    });
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
        final img.Image? decodedImage = img.decodeImage(originalBytes);
        if (decodedImage == null) {
          _logger.e('Failed to decode image ${imageFile.name}');
          throw Exception('Failed to decode image ${imageFile.name}');
        }
        
        // Re-encode the image with reduced quality to optimize size
        final processedBytes = Uint8List.fromList(img.encodeJpg(decodedImage, quality: 85));
        
        // Upload the processed image
        final atproto = _client.authService.atproto;
        if (atproto == null) {
          _logger.e('AtProto not initialized');
          throw Exception('AtProto not initialized');
        }
        
        final response = await atproto.repo.uploadBlob(processedBytes);
        if (response.status.code != 200) {
          _logger.e('Failed to upload image blob: ${response.status.code}');
          throw Exception('Blob upload failed for ${imageFile.name}: ${response.status.code}');
        }
        
        _logger.d('Image uploaded successfully: ${imageFile.name}');
        
        // Add the uploaded image to our result list
        uploadedImageMaps.add({
          "\$type": "so.sprk.embed.images#image",
          "alt": altTexts[imageFile.path] ?? '',
          "image": response.data.blob.toJson(),
        });
      } catch (e) {
        _logger.e('Error processing/uploading image ${imageFile.name}', error: e);
        rethrow;
      }
    }
    
    _logger.d('Successfully processed and uploaded ${uploadedImageMaps.length} images');
    return uploadedImageMaps;
  }
} 