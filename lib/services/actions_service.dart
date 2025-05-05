import 'package:atproto/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../models/feed_post.dart';
import 'auth_service.dart';
import 'sprk_client.dart';

class ActionsService extends ChangeNotifier {
  final AuthService _authService;
  late final SprkClient _client;

  ActionsService(this._authService) {
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
      final List<Map<String, dynamic>> uploadedImageMaps = await _uploadImages(imageFiles, altTexts ?? {});
      embedJson = {"\$type": "so.sprk.embed.images", "images": uploadedImageMaps};
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
  Future<dynamic> postImageFeed(String text, List<XFile> imageFiles, Map<String, String> altTexts) async {
    if (imageFiles.isEmpty) {
      throw ArgumentError('At least one image is required for an image post.');
    }

    final List<Map<String, dynamic>> uploadedImageMaps = await _uploadImages(imageFiles, altTexts);

    final embed = {"\$type": "so.sprk.embed.images", 'images': uploadedImageMaps};

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
        throw Exception('Failed to create image post: ${response.status.code} ${response.data}');
      }

      return response.data;
    } catch (e) {
      debugPrint('Error creating Spark image post record: $e');
      rethrow;
    }
  }

  /// Helper to upload multiple images, stripping EXIF, and return a list of JSON maps for embedding.
  Future<List<Map<String, dynamic>>> _uploadImages(List<XFile> imageFiles, Map<String, String> altTexts) async {
    final List<Map<String, dynamic>> uploadedImageMaps = [];
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

        uploadedImageMaps.add({
          "\$type": "so.sprk.embed.images#image",
          "alt": altTexts[imageFile.path] ?? '',
          "image": response.data.blob.toJson(),
        });
      } catch (e) {
        debugPrint('Error processing/uploading image ${imageFile.name}: $e');
        rethrow; // Rethrow to indicate failure
      }
    }
    return uploadedImageMaps;
  }

  Future<dynamic> followUser(String did) async {
    // Check if already following
    try {
      // Query existing follow records
      final existingFollows = await _client.repo.listRecords(
        repo: _authService.session!.did,
        collection: NSID.parse('so.sprk.graph.follow'),
      );

      // Check if we're already following this specific user
      for (final record in existingFollows.data.records) {
        if (record.value['subject'] == did) {
          throw Exception('Already following this user');
        }
      }

      // If not already following, create new follow record
      final followRecord = {
        "\$type": "so.sprk.graph.follow",
        "subject": did,
        "createdAt": DateTime.now().toUtc().toIso8601String(),
      };

      final response = await _client.repo.createRecord(collection: NSID.parse('so.sprk.graph.follow'), record: followRecord);

      if (response.status.code != 200) {
        throw Exception('Failed to follow user: ${response.status.code} ${response.data}');
      }

      notifyListeners();
      return response;
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
