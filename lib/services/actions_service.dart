import 'package:atproto/atproto.dart';
import 'package:flutter/foundation.dart';
import 'package:atproto/core.dart';
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
      "subject": {
        "cid": postCid,
        "uri": postUri,
      },
      "createdAt": DateTime.now().toUtc().toIso8601String(),
    };

    final response = await authAtProto.repo.createRecord(
      collection: NSID.parse('so.sprk.feed.like'),
      record: likeRecord
    );

    if (response.status != HttpStatus.ok) {
      throw Exception('Failed to like post: ${response.status} ${response.data}');
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
