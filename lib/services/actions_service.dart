import 'package:atproto/core.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../models/feed_post.dart';
import 'auth_service.dart';
import 'settings_service.dart';
import 'sprk_client.dart';

class ActionsService extends ChangeNotifier {
  final AuthService _authService;
  final SettingsService _settingsService;
  late final SprkClient _client;

  ActionsService(this._authService, this._settingsService) {
    _client = SprkClient(_authService);
  }

  // Check if a post is liked
  bool isPostLiked(FeedPost post) {
    return post.isLiked;
  }

  // Delete a post by its URI
  Future<bool> deletePost(String postUri) async {
    try {
      // Ensure the URI starts with 'at://'
      final normalizedUri = postUri.startsWith('at://') ? postUri : 'at://$postUri';

      final response = await _client.repo.deleteRecord(uri: AtUri.parse(normalizedUri));

      if (response.status.code != 200) {
        debugPrint('Failed to delete post: ${response.status.code} ${response.data}');
        return false;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting post: $e');
      return false;
    }
  }

  Future<dynamic> likePost(String postCid, String postUri) async {
    final likeRecord = {
      "\$type": "so.sprk.feed.like",
      "subject": {"cid": postCid, "uri": postUri},
      "createdAt": DateTime.now().toUtc().toIso8601String(),
    };

    final response = await _client.repo.createRecord(collection: NSID.parse('so.sprk.feed.like'), record: likeRecord);

    if (response.status.code != 200) {
      throw Exception('Failed to like post: ${response.status.code} ${response.data}');
    }

    notifyListeners();
    return response;
  }

  Future<dynamic> postComment(
    String text,
    String parentCid,
    String parentUri, {
    String? rootCid,
    String? rootUri,
    List<XFile>? imageFiles,
    Map<String, String>? altTexts,
  }) async {
    // Upload images and prepare embed JSON if provided
    Map<String, dynamic>? embedJson;
    if (imageFiles != null && imageFiles.isNotEmpty) {
      final List<Map<String, dynamic>> uploadedBlobs = await _uploadImageBlobs(imageFiles, altTexts ?? {});
      final List<Map<String, dynamic>> sparkImages =
          uploadedBlobs.map((blobData) {
            return {"\$type": "so.sprk.embed.images#image", "alt": blobData["alt"], "image": blobData["blob"]};
          }).toList();
      embedJson = {"\$type": "so.sprk.embed.images", "images": sparkImages};
    }

    // If root isn't provided, use parent as root
    rootCid ??= parentCid;
    rootUri ??= parentUri;

    final isSprk = RegExp(r'^at://[^/]+/so\.sprk\.feed\.post/[^/]+$').hasMatch(parentUri);
    final postType = isSprk ? "so.sprk.feed.post" : "app.bsky.feed.post";

    final commentRecord = <String, dynamic>{
      "\$type": postType,
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

    // Use the correct NSID for Spark posts
    final response = await _client.repo.createRecord(collection: NSID.parse(postType), record: commentRecord);

    // Check response status
    if (response.status.code != 200) {
      throw Exception('Failed to post comment: ${response.status.code} ${response.data}');
    }

    notifyListeners();
    return response;
  }

  Future<dynamic> unlikePost(String likeUri) async {
    final response = await _client.repo.deleteRecord(uri: AtUri.parse(likeUri));

    if (response.status.code != 200) {
      throw Exception('Failed to unlike post: ${response.status.code} ${response.data}');
    }

    notifyListeners();
    return response;
  }

  // Toggle like status for a post or video
  Future<String?> toggleLike(FeedPost post) async {
    try {
      if (post.isLiked) {
        if (post.likeUri == null) {
          throw Exception('Cannot unlike post: like URI is null');
        }
        await unlikePost(post.likeUri!);
        return null; // Post is now unliked
      } else {
        final response = await likePost(post.cid, post.uri);
        return response.data.uri.toString();
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      rethrow;
    }
  }

  /// Posts a new feed item with text and images using the Spark NSID.
  /// Returns the StrongRef of the created post record.
  Future<dynamic> postImageFeedSprk(String text, List<XFile> imageFiles, Map<String, String> altTexts) async {
    if (imageFiles.isEmpty) {
      throw ArgumentError('At least one image is required for an image post.');
    }

    // Upload blobs and create Spark post
    final List<Map<String, dynamic>> uploadedBlobs = await _uploadImageBlobs(imageFiles, altTexts);
    return await _createSparkPost(text, uploadedBlobs);
  }

  /// Posts a new video feed item to Spark only
  Future<dynamic> postVideoSprk(String text, Map<String, dynamic> videoBlobData, String videoAltText) async {
    return await _createSparkVideoPost(text, videoBlobData, videoAltText);
  }

  /// Posts the same video content to both Spark and Bluesky, reusing the same blob
  Future<Map<String, dynamic>> postVideoToBoth(String text, Map<String, dynamic> videoBlobData, String videoAltText) async {
    // Create Spark post first
    final sparkResponse = await _createSparkVideoPost(text, videoBlobData, videoAltText);

    // Create Bluesky post, passing Spark post info for potential linking if needed
    final bskyResponse = await _createBlueSkyVideoPost(text, videoBlobData, videoAltText, sparkPostData: sparkResponse);

    return {'spark': sparkResponse, 'bluesky': bskyResponse};
  }

  /// Posts the same content to both Spark and Bluesky, uploading images once and reusing blobs
  Future<Map<String, dynamic>> postImageToBoth(String text, List<XFile> imageFiles, Map<String, String> altTexts) async {
    if (imageFiles.isEmpty) {
      throw ArgumentError('At least one image is required for an image post.');
    }

    // Upload blobs once
    final List<Map<String, dynamic>> uploadedBlobs = await _uploadImageBlobs(imageFiles, altTexts);

    // Create Spark post first
    final sparkResponse = await _createSparkPost(text, uploadedBlobs);

    // Create Bluesky post, passing Spark post info for linking if needed
    final bskyResponse = await _createBlueSkyPost(text, uploadedBlobs, sparkPostData: sparkResponse);

    return {'spark': sparkResponse, 'bluesky': bskyResponse};
  }

  /// Uploads image blobs and returns blob references with metadata
  Future<List<Map<String, dynamic>>> _uploadImageBlobs(List<XFile> imageFiles, Map<String, String> altTexts) async {
    final List<Map<String, dynamic>> uploadedBlobs = [];
    for (final imageFile in imageFiles) {
      try {
        final originalBytes = await imageFile.readAsBytes();

        img.Image? decodedImage = img.decodeImage(originalBytes);

        if (decodedImage == null) {
          throw Exception('Failed to decode image ${imageFile.name}');
        }

        final processedBytes = Uint8List.fromList(img.encodeJpg(decodedImage, quality: 85));
        final response = await _client.repo.uploadBlob(processedBytes);

        if (response.status.code != 200) {
          throw Exception('Blob upload failed for ${imageFile.name}: ${response.status.code}');
        }

        uploadedBlobs.add({"alt": altTexts[imageFile.path] ?? '', "blob": response.data.blob.toJson()});
      } catch (e) {
        debugPrint('Error processing/uploading image ${imageFile.name}: $e');
        rethrow;
      }
    }
    return uploadedBlobs;
  }

  /// Creates a Spark post using pre-uploaded blobs
  Future<dynamic> _createSparkPost(String text, List<Map<String, dynamic>> uploadedBlobs) async {
    final List<Map<String, dynamic>> sparkImages =
        uploadedBlobs.map((blobData) {
          return {"\$type": "so.sprk.embed.images#image", "alt": blobData["alt"], "image": blobData["blob"]};
        }).toList();

    final embed = {"\$type": "so.sprk.embed.images", 'images': sparkImages};

    try {
      final response = await _client.repo.createRecord(
        collection: NSID.parse('so.sprk.feed.post'),
        record: {
          "\$type": "so.sprk.feed.post",
          'text': text,
          'embed': embed,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        },
      );

      if (response.status.code != 200) {
        throw Exception('Failed to create Spark image post: ${response.status.code} ${response.data}');
      }

      return response.data;
    } catch (e) {
      debugPrint('Error creating Spark image post record: $e');
      rethrow;
    }
  }

  /// Creates a Bluesky post using pre-uploaded blobs
  Future<dynamic> _createBlueSkyPost(String text, List<Map<String, dynamic>> uploadedBlobs, {dynamic sparkPostData}) async {
    Map<String, dynamic>? embed;
    String finalText = text;

    // Check if we have more than 4 images (Bluesky limit)
    if (uploadedBlobs.length > 4) {
      // Create a text-only post with link to Spark post
      if (sparkPostData != null) {
        final userDid = _authService.session?.did ?? '';
        // sparkPostData is the response.data, which has a uri property
        final sparkUri = (sparkPostData as dynamic).uri.toString();

        // Extract rkey from the Spark post URI (format: at://did/collection/rkey)
        final sparkRkey = sparkUri.split('/').last;
        final sparkLink = 'https://watch.sprk.so/?uri=$userDid/$sparkRkey';

        // Add link to text if text is not empty, otherwise just use the link
        if (text.isNotEmpty) {
          finalText = '$text\n\n$sparkLink';
        } else {
          finalText = '🔗 View all images: $sparkLink';
        }
      }
      // No embed for text-only post
    } else {
      // Use images normally (4 or fewer)
      final List<Map<String, dynamic>> bskyImages =
          uploadedBlobs.take(4).map((blobData) {
            return {"alt": blobData["alt"], "image": blobData["blob"]};
          }).toList();

      embed = {"\$type": "app.bsky.embed.images", 'images': bskyImages};
    }

    try {
      Map<String, dynamic> record = {
        "\$type": "app.bsky.feed.post",
        'text': finalText,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      };

      // Add embed only if we have images to show
      if (embed != null) {
        record['embed'] = embed;
      }

      final response = await _client.repo.createRecord(collection: NSID.parse('app.bsky.feed.post'), record: record);

      if (response.status.code != 200) {
        throw Exception('Failed to create Bluesky image post: ${response.status.code} ${response.data}');
      }

      return response.data;
    } catch (e) {
      debugPrint('Error creating Bluesky image post record: $e');
      rethrow;
    }
  }

  /// Creates a Spark video post using pre-processed video blob
  Future<dynamic> _createSparkVideoPost(String text, Map<String, dynamic> videoBlobData, String videoAltText) async {
    if (videoBlobData['\$type'] != 'blob') {
      throw Exception('Invalid video data - expected blob type');
    }

    try {
      Map<String, dynamic> record = {
        "\$type": "so.sprk.feed.post",
        'text': text,
        'embed': {'\$type': 'so.sprk.embed.video', 'video': videoBlobData},
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      };

      // Add alt text if provided
      if (videoAltText.isNotEmpty) {
        (record['embed'] as Map<String, dynamic>)['alt'] = videoAltText;
      }

      final response = await _client.repo.createRecord(collection: NSID.parse('so.sprk.feed.post'), record: record);

      if (response.status.code != 200) {
        throw Exception('Failed to create Spark video post: ${response.status.code} ${response.data}');
      }

      return response.data;
    } catch (e) {
      debugPrint('Error creating Spark video post record: $e');
      rethrow;
    }
  }

  /// Creates a Bluesky video post using pre-processed video blob
  Future<dynamic> _createBlueSkyVideoPost(
    String text,
    Map<String, dynamic> videoBlobData,
    String videoAltText, {
    dynamic sparkPostData,
  }) async {
    if (videoBlobData['\$type'] != 'blob') {
      throw Exception('Invalid video data - expected blob type');
    }

    try {
      Map<String, dynamic> record = {
        "\$type": "app.bsky.feed.post",
        'text': text,
        'embed': {'\$type': 'app.bsky.embed.video', 'video': videoBlobData},
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      };

      // Add alt text if provided
      if (videoAltText.isNotEmpty) {
        (record['embed'] as Map<String, dynamic>)['alt'] = videoAltText;
      }

      final response = await _client.repo.createRecord(collection: NSID.parse('app.bsky.feed.post'), record: record);

      if (response.status.code != 200) {
        throw Exception('Failed to create Bluesky video post: ${response.status.code} ${response.data}');
      }

      return response.data;
    } catch (e) {
      debugPrint('Error creating Bluesky video post record: $e');
      rethrow;
    }
  }

  Future<dynamic> followUser(String did) async {
    try {
      final mode = _settingsService.followMode;
      if (mode == FollowMode.sprk) {
        // Check if already following in Spark
        final existingFollows = await _client.repo.listRecords(
          repo: _authService.session!.did,
          collection: NSID.parse('so.sprk.graph.follow'),
        );
        for (final record in existingFollows.data.records) {
          if (record.value['subject'] == did) {
            throw Exception('Already following this user');
          }
        }
        final followRecord = {
          "\$type": "so.sprk.graph.follow",
          "subject": did,
          "createdAt": DateTime.now().toUtc().toIso8601String(),
        };
        final response = await _client.repo.createRecord(collection: NSID.parse('so.sprk.graph.follow'), record: followRecord);
        if (response.status.code != 200) {
          throw Exception('Failed to follow user: \\${response.status.code} \\${response.data}');
        }
        notifyListeners();
        return response;
      } else {
        // Bluesky mode
        final session = _authService.session;
        if (session == null) throw Exception('Not authenticated');
        // Check if already following in Bluesky
        final followsRes = await _client.repo.listRecords(repo: session.did, collection: NSID.parse('app.bsky.graph.follow'));
        for (final record in followsRes.data.records) {
          if (record.value['subject'] == did) {
            throw Exception('Already following this user');
          }
        }
        final followRecord = {
          "\$type": "app.bsky.graph.follow",
          "subject": did,
          "createdAt": DateTime.now().toUtc().toIso8601String(),
        };
        final response = await _client.repo.createRecord(collection: NSID.parse('app.bsky.graph.follow'), record: followRecord);
        if (response.status.code != 200) {
          throw Exception('Failed to follow user (bsky): \\${response.status.code} \\${response.data}');
        }
        notifyListeners();
        return response;
      }
    } catch (e) {
      debugPrint('Error in followUser: $e');
      rethrow;
    }
  }

  Future<dynamic> unfollowUser(String followUri) async {
    final response = await _client.repo.deleteRecord(uri: AtUri.parse(followUri));

    if (response.status.code != 200) {
      throw Exception('Failed to unfollow user: ${response.status.code} ${response.data}');
    }

    notifyListeners();
    return response;
  }

  Future<String?> toggleFollow(String did, String? followUri) async {
    try {
      if (followUri != null) {
        await unfollowUser(followUri);
        return null; // User is now unfollowed
      } else {
        final response = await followUser(did);
        return response.data.uri.toString();
      }
    } catch (e) {
      debugPrint('Error toggling follow: $e');
      rethrow;
    }
  }
}
