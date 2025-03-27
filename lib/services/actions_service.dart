import 'dart:typed_data';
import 'package:atproto/atproto.dart';
import 'package:flutter/foundation.dart';
import 'package:atproto/core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import '../models/feed_post.dart';
import 'auth_service.dart';

class ActionsService extends ChangeNotifier {
  final AuthService _authService;

  ActionsService(this._authService);

  // Check if a post is liked
  bool isPostLiked(FeedPost post) {
    return post.isLiked;
  }

  Future<XRPCResponse<StrongRef>> likePost(String postCid, String postUri) async {
    final authAtProto = _authService.atproto;
    if (authAtProto == null || authAtProto.session == null) {
      throw Exception('AtProto not initialized');
    }

    final likeRecord = {
      "\$type": "so.sprk.feed.like",
      "subject": {"cid": postCid, "uri": postUri},
      "createdAt": DateTime.now().toUtc().toIso8601String(),
    };

    final response = await authAtProto.repo.createRecord(collection: NSID.parse('so.sprk.feed.like'), record: likeRecord);

    if (response.status != HttpStatus.ok) {
      throw Exception('Failed to like post: ${response.status} ${response.data}');
    }

    notifyListeners();
    return response;
  }

  Future<XRPCResponse<StrongRef>> postComment(
    String text,
    String parentCid,
    String parentUri, {
    String? rootCid,
    String? rootUri,
    List<XFile>? imageFiles,
  }) async {
    final authAtProto = _authService.atproto;
    if (authAtProto == null || authAtProto.session == null) {
      throw Exception('AtProto not initialized');
    }

    // Upload images and prepare embed JSON if provided
    Map<String, dynamic>? embedJson; // Use a Map for the embed JSON
    if (imageFiles != null && imageFiles.isNotEmpty) {
      final List<Map<String, dynamic>> imagesJsonList = []; // List to hold image JSON objects

      for (final file in imageFiles) {
        final imageBytes = await file.readAsBytes();
        final detectedMimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

        // Upload the blob
        final response = await authAtProto.repo.uploadBlob(imageBytes);

        if (response.status != HttpStatus.ok) {
          throw Exception('Failed to upload image: ${response.status} ${response.data}');
        }

        debugPrint('Uploaded image: ${response.data.blob.toJson()}');

        // Add the image JSON object to the list
        imagesJsonList.add({
          "\$type": "so.sprk.embed.images#image", // Optional: type for individual image if needed by spec
          "alt": '', // Placeholder for alt text
          "image": response.data.blob.toJson(), // Use the blob reference from the response
        });
      }

      // Construct the embed JSON
      embedJson = {
        "\$type": "so.sprk.embed.images", // Standard Bluesky image embed type
        "images": imagesJsonList,
      };
    }

    // If root isn't provided, use parent as root
    rootCid ??= parentCid;
    rootUri ??= parentUri;

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

    final response = await authAtProto.repo.createRecord(collection: NSID.parse('so.sprk.feed.post'), record: commentRecord);

    if (response.status != HttpStatus.ok) {
      throw Exception('Failed to post comment: ${response.status} ${response.data}');
    }

    notifyListeners();
    return response;
  }

  Future<XRPCResponse<EmptyData>> unlikePost(String likeUri) async {
    final authAtProto = _authService.atproto;
    if (authAtProto == null || authAtProto.session == null) {
      throw Exception('AtProto not initialized');
    }

    final response = await authAtProto.repo.deleteRecord(uri: AtUri.parse(likeUri));
    if (response.status != HttpStatus.ok) {
      throw Exception('Failed to unlike post: ${response.status} ${response.data}');
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
        // Return the new like URI from the response
        return response.data.uri.toString();
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      rethrow;
    }
  }
}
