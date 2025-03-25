import 'package:atproto/atproto.dart';
import 'package:flutter/foundation.dart';
import 'package:atproto/core.dart';
import 'dart:developer' as developer;
import 'auth_service.dart';

class ActionsService extends ChangeNotifier {
  final AuthService _authService;

  // Track liked posts to maintain UI state
  final Map<String, bool> _likedPosts = {};

  ActionsService(this._authService);

  // Check if a post is liked
  bool isPostLiked(String postUri) {
    developer.log('Checking if post is liked: $postUri, result: ${_likedPosts[postUri] ?? false}');
    return _likedPosts[postUri] ?? false;
  }

  Future<StrongRef?> likePost(String postCid, String postUri) async {
    developer.log('Liking post: $postUri with CID: $postCid');
    final authAtProto = _authService.atproto;
    if (authAtProto == null || authAtProto.session == null) {
      developer.log('Error: AtProto not initialized');
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

    developer.log('Creating like record: $likeRecord');
    final response = await authAtProto.repo.createRecord(
      collection: NSID.parse('so.sprk.feed.like'),
      record: likeRecord
    );

    if (response.status != HttpStatus.ok) {
      developer.log('Failed to like post: ${response.status} ${response.data}');
      throw Exception('Failed to like post: ${response.status} ${response.data}');
    }

    // Update local state and notify listeners
    _likedPosts[postUri] = true;
    developer.log('Post liked successfully: $postUri');
    notifyListeners();

    return response.data;
  }

  Future<EmptyData?> unlikePost(String likeUri) async {
    developer.log('Unliking post with like URI: $likeUri');
    final authAtProto = _authService.atproto;
    if (authAtProto == null || authAtProto.session == null) {
      developer.log('Error: AtProto not initialized');
      throw Exception('AtProto not initialized');
    }

    final response = await authAtProto.repo.deleteRecord(uri: AtUri.parse(likeUri));
    if (response.status != HttpStatus.ok) {
      developer.log('Failed to unlike post: ${response.status} ${response.data}');
      throw Exception('Failed to unlike post: ${response.status} ${response.data}');
    }

    // Extract post URI from the like URI and update local state
    final postUri = likeUri.split('/').sublist(0, 3).join('/');
    _likedPosts[postUri] = false;
    developer.log('Post unliked successfully: $postUri');
    notifyListeners();

    return response.data;
  }

  // Toggle like status for a post or video
  Future<void> toggleLike(String postCid, String postUri) async {
    developer.log('Toggling like for post: $postUri, CID: $postCid');
    try {
      final isCurrentlyLiked = isPostLiked(postUri);
      developer.log('Post is currently liked: $isCurrentlyLiked');

      if (isCurrentlyLiked) {
        await unlikePost(postUri);
      } else {
        await likePost(postCid, postUri);
      }
    } catch (e) {
      developer.log('Error toggling like: $e', error: e);
      debugPrint('Error toggling like: $e');
      rethrow;
    }
  }
}
