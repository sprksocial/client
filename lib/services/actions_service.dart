import 'package:atproto/atproto.dart';
import 'package:flutter/foundation.dart';
import 'package:atproto/core.dart';
import 'auth_service.dart';

class ActionsService extends ChangeNotifier {
  final AuthService _authService;

  // Track liked posts to maintain UI state
  final Map<String, bool> _likedPosts = {};

  ActionsService(this._authService);

  // Check if a post is liked
  bool isPostLiked(String postUri) {
    return _likedPosts[postUri] ?? false;
  }

  Future<StrongRef?> likePost(String postCid, String postUri) async {
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

    // Update local state and notify listeners
    _likedPosts[postUri] = true;
    notifyListeners();

    return response.data;
  }

  Future<EmptyData?> unlikePost(String likeUri) async {
    final authAtProto = _authService.atproto;
    if (authAtProto == null || authAtProto.session == null) {
      throw Exception('AtProto not initialized');
    }

    final response = await authAtProto.repo.deleteRecord(uri: AtUri.parse(likeUri));
    if (response.status != HttpStatus.ok) {
      throw Exception('Failed to unlike post: ${response.status} ${response.data}');
    }

    // Extract post URI from the like URI and update local state
    final postUri = likeUri.split('/').sublist(0, 3).join('/');
    _likedPosts[postUri] = false;
    notifyListeners();

    return response.data;
  }

  // Toggle like status for a post or video
  Future<void> toggleLike(String postCid, String postUri) async {
    try {
      final isCurrentlyLiked = isPostLiked(postUri);

      if (isCurrentlyLiked) {
        await unlikePost(postUri);
      } else {
        await likePost(postCid, postUri);
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      rethrow;
    }
  }
}
