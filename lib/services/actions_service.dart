import 'package:atproto/atproto.dart' as atp;
import 'package:flutter/foundation.dart';
import 'package:atproto/core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../models/feed_post.dart';
import 'auth_service.dart';

class ActionsService extends ChangeNotifier {
  final AuthService _authService;

  ActionsService(this._authService);

  atp.ATProto? get _atproto => _authService.atproto; // Use prefixed type

  // Check if a post is liked
  bool isPostLiked(FeedPost post) {
    return post.isLiked;
  }

  Future<XRPCResponse<atp.StrongRef>> likePost(String postCid, String postUri) async {
    final authAtProto = _atproto;
    if (authAtProto == null || authAtProto.session == null) {
      throw Exception('AtProto not initialized');
    }

    final likeRecord = {
      "\$type": "so.sprk.feed.like",
      "subject": {"cid": postCid, "uri": postUri},
      "createdAt": DateTime.now().toUtc().toIso8601String(),
    };

    final response = await authAtProto.repo.createRecord(collection: NSID.parse('so.sprk.feed.like'), record: likeRecord);

    if (response.status.code != 200) {
      throw Exception('Failed to like post: ${response.status.code} ${response.data}');
    }

    notifyListeners();
    return response;
  }

  Future<XRPCResponse<atp.StrongRef>> postComment(
    String text,
    String parentCid,
    String parentUri, {
    String? rootCid,
    String? rootUri,
    List<XFile>? imageFiles,
  }) async {
    final authAtProto = _atproto;
    if (authAtProto == null || authAtProto.session == null) {
      throw Exception('AtProto not initialized');
    }

    // Upload images and prepare embed JSON if provided
    Map<String, dynamic>? embedJson;
    if (imageFiles != null && imageFiles.isNotEmpty) {
      // Use the updated _uploadImages which returns List<Map<String, dynamic>>
      final List<Map<String, dynamic>> uploadedImageMaps = await _uploadImages(imageFiles);

      // Construct the embed JSON using Spark lexicon type
      embedJson = {
        "\$type": "so.sprk.embed.images", // Spark image embed type
        "images": uploadedImageMaps,
      };
    }

    // If root isn't provided, use parent as root
    rootCid ??= parentCid;
    rootUri ??= parentUri;

    final commentRecord = <String, dynamic>{
      "\$type": "so.sprk.feed.post", // Spark feed post type
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
    final response = await authAtProto.repo.createRecord(collection: NSID.parse('so.sprk.feed.post'), record: commentRecord);

    // Check response status (using atp.HttpStatus if available, otherwise integer)
    // Assuming HttpStatus.ok is 200 or similar standard code
    if (response.status.code != 200) {
      // Adjust status code check if needed
      throw Exception('Failed to post comment: ${response.status.code} ${response.data}');
    }

    notifyListeners();
    return response;
  }

  Future<XRPCResponse<EmptyData>> unlikePost(String likeUri) async {
    final authAtProto = _atproto;
    if (authAtProto == null || authAtProto.session == null) {
      throw Exception('AtProto not initialized');
    }

    final response = await authAtProto.repo.deleteRecord(uri: AtUri.parse(likeUri));
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
  Future<atp.StrongRef> postImageFeed(String text, List<XFile> imageFiles) async {
    final authAtProto = _atproto; // Use prefixed type
    if (authAtProto == null || authAtProto.session == null) {
      throw Exception('AtProto not initialized');
    }
    if (imageFiles.isEmpty) {
      throw ArgumentError('At least one image is required for an image post.');
    }

    final List<Map<String, dynamic>> uploadedImageMaps = await _uploadImages(imageFiles);

    final embed = {"\$type": "so.sprk.embed.images", 'images': uploadedImageMaps};

    try {
      final response = await authAtProto.repo.createRecord(
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
      print('Error creating Spark image post record: $e');
      rethrow;
    }
  }

  /// Helper to upload multiple images, stripping EXIF, and return a list of JSON maps for embedding.
  Future<List<Map<String, dynamic>>> _uploadImages(List<XFile> imageFiles) async {
    final authAtProto = _atproto;
    if (authAtProto == null) {
      throw Exception('ATProto service not available');
    }

    final List<Map<String, dynamic>> uploadedImageMaps = [];
    for (final imageFile in imageFiles) {
      try {
        final originalBytes = await imageFile.readAsBytes();

        img.Image? decodedImage = img.decodeImage(originalBytes);

        if (decodedImage == null) {
          throw Exception('Failed to decode image ${imageFile.name}');
        }

        final processedBytes = Uint8List.fromList(img.encodeJpg(decodedImage, quality: 85));
        final response = await authAtProto.repo.uploadBlob(processedBytes);

        if (response.status.code != 200) {
          throw Exception('Blob upload failed for ${imageFile.name}: ${response.status.code}');
        }

        uploadedImageMaps.add({
          "\$type": "so.sprk.embed.images#image",
          "alt": '', // Alt text - consider adding a way to input this later
          "image": response.data.blob.toJson(),
        });
      } catch (e) {
        debugPrint('Error processing/uploading image ${imageFile.name}: $e');
        rethrow; // Rethrow to indicate failure
      }
    }
    return uploadedImageMaps;
  }
}
