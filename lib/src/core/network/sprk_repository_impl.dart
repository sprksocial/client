import 'dart:convert';
import 'dart:typed_data';

import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/core/config/app_config.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/auth/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/network/sprk_repository_interface.dart';
import 'package:sparksocial/src/core/network/models/actor_models.dart';
import 'package:sparksocial/src/core/network/models/repo_models.dart';

import 'models/feed_models.dart';
import 'models/graph_models.dart';
import 'models/label_models.dart';

/// Client for interacting with Spark API endpoints
class SprkRepository implements SprkRepositoryInterface {
  final AuthRepository _authService;
  final String _sprkDid;
  final _logger = GetIt.instance<LogService>().getLogger('SprkRepository');

  SprkRepository(this._authService) : _sprkDid = _getSprkDid() {
    _logger.d('SprkRepository initialized with DID: $_sprkDid');
  }

  static String _getSprkDid() {
    final sprkAppView = Uri.parse(AppConfig.appViewUrl);
    return "did:web:${sprkAppView.host}#sprk_appview";
  }

  /// Execute API request with token expiration handling
  Future<T> _executeWithRetry<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (e) {
      // Check if the error is a token expired error
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('400') && (errorStr.contains('expired'))) {
        _logger.i('Token expired, attempting to refresh');
        // Try to refresh the token
        final refreshed = await _authService.refreshToken();
        if (!refreshed) {
          _logger.e('Failed to refresh expired token');
          throw Exception('Failed to refresh expired token');
        }

        _logger.i('Token refreshed successfully, retrying API call');
        // Retry the call with the new token
        return await apiCall();
      }

      _logger.e('API call failed', error: e);
      // Rethrow other errors
      rethrow;
    }
  }

  @override
  ActorRepositoryImpl get actor => ActorRepositoryImpl(this);

  @override
  RepoRepositoryImpl get repo => RepoRepositoryImpl(this);

  @override
  FeedRepositoryImpl get feed => FeedRepositoryImpl(this);

  @override
  GraphRepositoryImpl get graph => GraphRepositoryImpl(this);
  
  @override
  LabelRepositoryImpl get label => LabelRepositoryImpl(this);
}

/// Actor-related API endpoints implementation
class ActorRepositoryImpl implements ActorRepositoryInterface {
  final SprkRepository _client;
  final _logger = GetIt.instance<LogService>().getLogger('ActorAPI');

  ActorRepositoryImpl(this._client) {
    _logger.v('ActorAPI initialized');
  }

  @override
  Future<ProfileResponse> getProfile(String did) async {
    _logger.d('Getting profile for DID: $did');
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.get(
        NSID.parse('so.sprk.actor.getProfile'),
        parameters: {'actor': did},
        headers: {'atproto-proxy': _client._sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Profile retrieved successfully');
      return ProfileResponse.fromJson(result.data as Map<String, dynamic>);
    });
  }

  @override
  Future<ActorSearchResponse> searchActors(String query) async {
    _logger.d('Searching actors with query: $query');
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.get(
        NSID.parse('so.sprk.actor.searchActors'),
        parameters: {'q': query},
        headers: {'atproto-proxy': _client._sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Actor search completed successfully');
      return ActorSearchResponse.fromJson(result.data as Map<String, dynamic>);
    });
  }
}

/// Repository-related API endpoints implementation
class RepoRepositoryImpl implements RepoRepositoryInterface {
  final SprkRepository _client;
  final _logger = GetIt.instance<LogService>().getLogger('RepoAPI');

  RepoRepositoryImpl(this._client) {
    _logger.v('RepoAPI initialized');
  }

  @override
  Future<RecordResponse> getRecord({required AtUri uri}) async {
    _logger.d('Getting record for URI: $uri');
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }
      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }
      final result = await atproto.repo.getRecord(uri: uri);
      _logger.d('Record retrieved successfully');
      final value = result.data.value;
      return RecordResponse(
        uri: result.data.uri.toString(),
        cid: result.data.cid ?? '',
        value: value,
      );
    });
  }

  @override
  Future<RecordResponse> editRecord({required AtUri uri, required Map<String, dynamic> record}) async {
    _logger.d('Editing record at URI: $uri');
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }
      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }
      final result = await atproto.repo.putRecord(uri: uri, record: record);
      _logger.d('Record edited successfully');
      return RecordResponse(
        uri: result.data.uri.toString(),
        cid: result.data.cid,
        value: record,
      );
    });
  }

  @override
  Future<RecordResponse> createRecord({required NSID collection, required Map<String, dynamic> record, String? rkey}) async {
    _logger.d('Creating record in collection: $collection');
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.repo.createRecord(collection: collection, record: record, rkey: rkey);
      _logger.d('Record created successfully');
      return RecordResponse(
        uri: result.data.uri.toString(),
        cid: result.data.cid,
        value: record,
      );
    });
  }

  @override
  Future<void> deleteRecord({required AtUri uri}) async {
    _logger.d('Deleting record at URI: $uri');
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      await atproto.repo.deleteRecord(uri: uri);
      _logger.d('Record deleted successfully');
    });
  }

  @override
  Future<BlobResponse> uploadBlob(Uint8List data) async {
    _logger.d('Uploading blob of size: ${data.length} bytes');
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.repo.uploadBlob(data);
      _logger.d('Blob uploaded successfully');
      
      // Create blobRef map
      final Map<String, dynamic> blobRef = {};
      blobRef['\$type'] = 'blob';
      blobRef['ref'] = result.data.blob.ref;
      blobRef['mimeType'] = result.data.blob.mimeType;
      
      return BlobResponse(
        blob: result.data.blob.toString(),
        blobRef: blobRef,
      );
    });
  }

  @override
  Future<RecordsListResponse> listRecords({
    required String repo, 
    required NSID collection, 
    String? cursor, 
    int? limit, 
    bool? reverse
  }) async {
    _logger.d('Listing records in repo: $repo, collection: $collection');
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.repo.listRecords(
        repo: repo, 
        collection: collection, 
        cursor: cursor, 
        limit: limit, 
        reverse: reverse
      );
      
      _logger.d('Records listed successfully');
      
      final records = result.data.records.map((record) => RecordItem(
        uri: record.uri.toString(),
        cid: record.cid ?? '',
        value: record.value,
      )).toList();
      
      return RecordsListResponse(
        records: records,
        cursor: result.data.cursor,
      );
    });
  }
} 

/// Implementation of Feed-related API endpoints
class FeedRepositoryImpl implements FeedRepositoryInterface {
  final SprkRepository _client;
  final _logger = GetIt.instance<LogService>().getLogger('FeedRepository');

  FeedRepositoryImpl(this._client) {
    _logger.v('FeedRepository initialized');
  }

  @override
  Future<PostThreadResponse> getPostThread(String postUri) async {
    _logger.d('Getting post thread for URI: $postUri');
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.get(
        NSID.parse('so.sprk.feed.getPostThread'),
        parameters: {'uri': postUri},
        headers: {'atproto-proxy': _client._sprkDid},
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
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
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
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.get(
        NSID.parse('so.sprk.feed.getPosts'),
        parameters: {'uris': uris},
        headers: {'atproto-proxy': _client._sprkDid},
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
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.get(
        NSID.parse('so.sprk.feed.getAuthorFeed'),
        parameters: {'actor': actor},
        headers: {'atproto-proxy': _client._sprkDid},
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
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
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
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
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
    
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
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

    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
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
        final atproto = _client._authService.atproto;
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

/// Implementation of Graph-related API endpoints
class GraphRepositoryImpl implements GraphRepositoryInterface {
  final SprkRepository _client;
  final _logger = GetIt.instance<LogService>().getLogger('GraphRepository');

  GraphRepositoryImpl(this._client) {
    _logger.v('GraphRepository initialized');
  }

  @override
  Future<FollowersResponse> getFollowers(String did) async {
    _logger.d('Getting followers for DID: $did');
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.get(
        NSID.parse('so.sprk.graph.getFollowers'),
        parameters: {'actor': did},
        headers: {'atproto-proxy': _client._sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Followers retrieved successfully');
      return FollowersResponse.fromJson(result.data as Map<String, dynamic>);
    });
  }

  @override
  Future<FollowsResponse> getFollows(String did) async {
    _logger.d('Getting follows for DID: $did');
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.get(
        NSID.parse('so.sprk.graph.getFollows'),
        parameters: {'actor': did},
        headers: {'atproto-proxy': _client._sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Follows retrieved successfully');
      return FollowsResponse.fromJson(result.data as Map<String, dynamic>);
    });
  }
  
  @override
  Future<FollowUserResponse> followUser(String did) async {
    _logger.d('Following user with DID: $did');
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      // Check if already following
      try {
        _logger.d('Checking if already following user: $did');
        // Query existing follow records
        final existingFollows = await atproto.repo.listRecords(
          repo: _client._authService.session!.did,
          collection: NSID.parse('so.sprk.graph.follow'),
        );

        // Check if we're already following this specific user
        for (final record in existingFollows.data.records) {
          if (record.value['subject'] == did) {
            _logger.w('Already following this user: $did');
            throw Exception('Already following this user');
          }
        }

        // If not already following, create new follow record
        final followRecord = {
          "\$type": "so.sprk.graph.follow",
          "subject": did,
          "createdAt": DateTime.now().toUtc().toIso8601String(),
        };

        final result = await atproto.repo.createRecord(
          collection: NSID.parse('so.sprk.graph.follow'),
          record: followRecord
        );
        
        _logger.i('User followed successfully: ${result.data.uri}');
        
        return FollowUserResponse(
          uri: result.data.uri.toString(),
          cid: result.data.cid,
        );
      } catch (e) {
        _logger.e('Error in followUser', error: e);
        rethrow;
      }
    });
  }
  
  @override
  Future<void> unfollowUser(String followUri) async {
    _logger.d('Unfollowing user with follow URI: $followUri');
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      await atproto.repo.deleteRecord(uri: AtUri.parse(followUri));
      _logger.i('User unfollowed successfully');
    });
  }
} 

/// Implementation of Label-related API endpoints
class LabelRepositoryImpl implements LabelRepositoryInterface {
  final SprkRepository _client;
  final _logger = GetIt.instance<LogService>().getLogger('LabelRepository');
  
  // Default labeler DID
  static const String _defaultLabelerDid = 'did:plc:pbgyr67hftvpoqtvaurpsctc';
  
  // Cache for label values and definitions
  final Map<String, List<String>> _labelValuesCache = {};
  final Map<String, List<LabelValue>> _labelValueDefinitionsCache = {};
  
  LabelRepositoryImpl(this._client) {
    _logger.v('LabelRepository initialized');
  }
  
  @override
  Future<LabelValueListResponse> getLabelValues({String? labelerDid}) async {
    final targetDid = labelerDid ?? _defaultLabelerDid;
    _logger.d('Fetching label values from labeler: $targetDid');
    
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }
      
      try {
        // Configure header to use the proxy for the labeler
        final Map<String, String> headers = {};
        headers['atproto-proxy'] = '$targetDid#atproto_labeler';
        
        final responseData = await atproto.get(
          NSID.parse('com.atproto.label.getLabelValues'),
          headers: headers,
          to: (json) => json as Map<String, dynamic>,
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
        );
        
        // Extract and convert the values
        final values = List<String>.from(responseData.data['values'] ?? []);
        
        // Update the local cache
        _labelValuesCache[targetDid] = values;
        
        _logger.d('Fetched ${values.length} label values successfully');
        
        return LabelValueListResponse(values: values);
      } catch (e) {
        // Check if this is a 501 Method Not Implemented error
        if (e.toString().contains('501 Method Not Implemented')) {
          _logger.w('Method not implemented, using default values');
          // For default labeler, return default values
          if (targetDid == _defaultLabelerDid) {
            final values = _getDefaultLabelValues();
            _labelValuesCache[targetDid] = values;
            return LabelValueListResponse(values: values);
          }
        }
        
        _logger.e('Error fetching label values', error: e);
        throw Exception('Error fetching label values: $e');
      }
    });
  }
  
  @override
  Future<LabelValueDefinitionsResponse> getLabelValueDefinitions({String? labelerDid}) async {
    final targetDid = labelerDid ?? _defaultLabelerDid;
    _logger.d('Fetching label value definitions from labeler: $targetDid');
    
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }
      
      try {
        // Configure header to use the proxy for the labeler
        final Map<String, String> headers = {};
        headers['atproto-proxy'] = '$targetDid#atproto_labeler';
        
        final responseData = await atproto.get(
          NSID.parse('com.atproto.label.getLabelValueDefinitions'),
          headers: headers,
          to: (json) => json as Map<String, dynamic>,
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
        );
        
        // Extract and convert the definitions
        final definitionsMaps = List<Map<String, dynamic>>.from(responseData.data['definitions'] ?? []);
        final definitions = definitionsMaps.map((map) => LabelValue.fromJson(map)).toList();
        
        // Update the local cache
        _labelValueDefinitionsCache[targetDid] = definitions;
        
        _logger.d('Fetched ${definitions.length} label definitions successfully');
        
        return LabelValueDefinitionsResponse(definitions: definitions);
      } catch (e) {
        // Check if this is a 501 Method Not Implemented error
        if (e.toString().contains('501 Method Not Implemented')) {
          _logger.w('Method not implemented, using default definitions');
          // For default labeler, return default definitions
          if (targetDid == _defaultLabelerDid) {
            final definitions = _getDefaultLabelValueDefinitions();
            _labelValueDefinitionsCache[targetDid] = definitions;
            return LabelValueDefinitionsResponse(definitions: definitions);
          }
        }
        
        _logger.e('Error fetching label definitions', error: e);
        throw Exception('Error fetching label definitions: $e');
      }
    });
  }
  
  @override
  Future<LabelerInfoResponse> getLabelerInfo({String? labelerDid}) async {
    final targetDid = labelerDid ?? _defaultLabelerDid;
    _logger.d('Getting info for labeler: $targetDid');
    
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }
      
      try {
        // Configure header to use the proxy for the labeler
        final Map<String, String> headers = {};
        headers['atproto-proxy'] = '$targetDid#atproto_labeler';
        
        final responseData = await atproto.get(
          NSID.parse('com.atproto.label.getLabelerInfo'),
          headers: headers,
          to: (json) => json as Map<String, dynamic>,
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
        );
        
        _logger.d('Labeler info retrieved successfully');
        
        return LabelerInfoResponse.fromJson(responseData.data);
      } catch (e) {
        // Check if this is a 501 Method Not Implemented error
        if (e.toString().contains('501 Method Not Implemented')) {
          _logger.w('Method not implemented, using default info');
          // Fallback for default labeler
          if (targetDid == _defaultLabelerDid) {
            return LabelerInfoResponse(
              did: targetDid,
              displayName: 'Default Labeler',
              description: 'System default content labeler',
            );
          } else {
            // Generic fallback for other labelers
            return LabelerInfoResponse(
              did: targetDid,
              displayName: 'Labeler ${targetDid.substring(0, 10)}...',
              description: 'Content labeler',
            );
          }
        }
        
        _logger.e('Error fetching labeler info', error: e);
        throw Exception('Error fetching labeler info: $e');
      }
    });
  }
  
  @override
  Future<QueryLabelsResponse> queryLabels({
    required List<String> uriPatterns,
    List<String>? sources,
    int limit = 50,
    String? cursor,
    String? labelerDid,
  }) async {
    final targetDid = labelerDid ?? _defaultLabelerDid;
    _logger.d('Querying labels for ${uriPatterns.length} URI patterns from labeler: $targetDid');
    
    return _client._executeWithRetry(() async {
      if (!_client._authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client._authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }
      
      try {
        // Configure header to use the proxy for the labeler
        final Map<String, String> headers = {};
        headers['atproto-proxy'] = '$targetDid#atproto_labeler';
        
        // Prepare parameters
        final Map<String, dynamic> parameters = {
          'uriPatterns': uriPatterns,
        };
        
        if (sources != null && sources.isNotEmpty) {
          parameters['sources'] = sources;
        }
        
        if (limit != 50) {
          parameters['limit'] = limit;
        }
        
        if (cursor != null) {
          parameters['cursor'] = cursor;
        }
        
        final responseData = await atproto.get(
          NSID.parse('com.atproto.label.queryLabels'),
          parameters: parameters,
          headers: headers,
          to: (json) => json as Map<String, dynamic>,
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
        );
        
        // Extract and convert the labels
        final labelsMaps = List<Map<String, dynamic>>.from(responseData.data['labels'] ?? []);
        final labels = labelsMaps.map((map) => LabelDetail.fromJson(map)).toList();
        
        _logger.d('Retrieved ${labels.length} labels successfully');
        
        return QueryLabelsResponse(
          labels: labels,
          cursor: responseData.data['cursor'] as String?,
        );
      } catch (e) {
        _logger.e('Error querying labels', error: e);
        throw Exception('Error querying labels: $e');
      }
    });
  }
  
  @override
  Future<Map<String, LabelValue>> getAllLabelsWithDefinitions({String? labelerDid}) async {
    final targetDid = labelerDid ?? _defaultLabelerDid;
    _logger.d('Getting all label definitions from labeler: $targetDid');
    
    final Map<String, LabelValue> result = {};
    
    try {
      // Try to fetch the latest values and definitions
      try {
        // Load values if not already loaded for this DID
        if (!_labelValuesCache.containsKey(targetDid) || _labelValuesCache[targetDid]!.isEmpty) {
          await getLabelValues(labelerDid: targetDid);
        }
        
        // Load definitions if not already loaded for this DID
        if (!_labelValueDefinitionsCache.containsKey(targetDid) || _labelValueDefinitionsCache[targetDid]!.isEmpty) {
          await getLabelValueDefinitions(labelerDid: targetDid);
        }
        
        // Create the map of label values to their definitions
        final definitions = _labelValueDefinitionsCache[targetDid] ?? [];
        for (final definition in definitions) {
          result[definition.value] = definition;
        }
        
        _logger.d('Retrieved ${result.length} label definitions successfully');
      } catch (apiError) {
        _logger.w('API error, using fallback definitions', error: apiError);
        // If we can't fetch (501 or other API errors), use fallbacks for default labeler
        if (targetDid == _defaultLabelerDid) {
          // Load default fallback labels for the default labeler
          final definitions = _getDefaultLabelValueDefinitions();
          for (final definition in definitions) {
            result[definition.value] = definition;
          }
        }
      }
      
      return result;
    } catch (e) {
      _logger.e('Error getting all label definitions', error: e);
      
      // Final fallback if everything fails for the default labeler
      if (targetDid == _defaultLabelerDid) {
        final definitions = _getDefaultLabelValueDefinitions();
        for (final definition in definitions) {
          result[definition.value] = definition;
        }
      }
      
      return result;
    }
  }
  
  /// Returns default label values for the standard labeler
  List<String> _getDefaultLabelValues() {
    return [
      '!hide',
      '!warn',
      'porn',
      'sexual',
      'nudity',
      'sexual-figurative',
      'graphic-media',
      'self-harm',
      'sensitive',
      'extremist',
      'intolerant',
      'threat',
      'rude',
      'illicit',
      'security',
      'unsafe-link',
      'impersonation',
      'misinformation',
      'scam',
      'engagement-farming',
      'spam',
      'rumor',
      'misleading',
      'inauthentic',
    ];
  }
  
  /// Returns default label value definitions for the standard labeler
  List<LabelValue> _getDefaultLabelValueDefinitions() {
    return [
      LabelValue(
        value: 'spam',
        identifier: 'spam',
        blurs: 'content',
        severity: 'inform',
        defaultSetting: 'hide',
        adultOnly: false,
        locales: [
          LabelLocale(
            lang: 'en',
            name: 'Spam',
            description: 'Unwanted, repeated, or unrelated actions that bother users.',
          ),
        ],
      ),
      LabelValue(
        value: 'impersonation',
        identifier: 'impersonation',
        blurs: 'none',
        severity: 'inform',
        defaultSetting: 'hide',
        adultOnly: false,
        locales: [
          LabelLocale(
            lang: 'en',
            name: 'Impersonation',
            description: 'Pretending to be someone else without permission.',
          ),
        ],
      ),
      LabelValue(
        value: 'scam',
        identifier: 'scam',
        blurs: 'content',
        severity: 'alert',
        defaultSetting: 'hide',
        adultOnly: false,
        locales: [
          LabelLocale(
            lang: 'en',
            name: 'Scam',
            description: 'Scams, phishing & fraud.',
          ),
        ],
      ),
      // Add other default label values as needed
    ];
  }
} 