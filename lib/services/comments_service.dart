import 'package:atproto/core.dart';
import 'package:bluesky/bluesky.dart';
import 'package:flutter/foundation.dart';

import '../models/comment.dart';
import 'auth_service.dart';

class CommentsService extends ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  String? _error;
  List<Comment>? _comments;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Comment>? get comments => _comments;

  CommentsService(this._authService);

  /// Fetch comments for a post from Bluesky
  Future<List<Comment>> getBlueskyComments(String postUri) async {
    if (!_authService.isAuthenticated) {
      throw Exception('Not authenticated');
    }

    // Set loading state but don't notify listeners yet
    _isLoading = true;
    _error = null;
    _comments = null;

    try {
      final bsky = Bluesky.fromSession(_authService.session!);

      // Parse the post URI
      final uri = AtUri.parse(postUri);

      // Get the post thread
      final response = await bsky.feed.getPostThread(uri: uri);

      // Extract the replies from the thread
      final thread = response.data.thread;
      final replies = _extractBlueskyReplies(thread);

      // Update state and notify listeners once all async operations are complete
      _comments = replies;
      _isLoading = false;
      notifyListeners();

      return replies;
    } catch (e) {
      _error = 'Failed to load comments: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      throw Exception(_error);
    }
  }

  /// Fetch comments for a post from Spark
  Future<List<Comment>> getSparkComments(String postUri) async {
    if (!_authService.isAuthenticated) {
      throw Exception('Not authenticated');
    }

    // Set loading state but don't notify listeners yet
    _isLoading = true;
    _error = null;
    _comments = null;

    try {
      final atproto = _authService.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }

      // Get the post thread
      final response = await atproto.get(
        NSID.parse('so.sprk.feed.getPostThread'),
        parameters: {'uri': postUri},
        headers: {
          'atproto-proxy': 'did:web:api.sprk.so#sprk_appview'
        },
        to: (json) => json,
      );

      // Extract comments from the thread
      final thread = response.data['thread'] as Map<String, dynamic>?;
      if (thread == null) {
        _comments = [];
        _isLoading = false;
        notifyListeners();
        return [];
      }

      final replies = _extractSparkReplies(thread);

      // Update state and notify listeners once all async operations are complete
      _comments = replies;
      _isLoading = false;
      notifyListeners();

      return replies;
    } catch (e) {
      _error = 'Failed to load comments: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      throw Exception(_error);
    }
  }

  /// Extract replies from a Bluesky thread
  List<Comment> _extractBlueskyReplies(PostThreadView thread) {
    final List<Comment> result = [];

    // Skip the root post, only include replies
    final replies = thread.whenOrNull(
      record: (rec) => rec.replies
    );

    if (replies == null) {
      return result;
    }

    for (final reply in replies) {
      final post = reply.whenOrNull(
        record: (rec) => rec.post,
      );

      if (post == null) {
        continue;
      }

      result.add(Comment.fromBlueskyComment(post));

      // Process any nested replies if they exist
      //if (post.) {
       // result.addAll(_extractBlueskyReplies(reply));
      //}
    }

    return result;
  }

  /// Extract replies from a Spark thread
  List<Comment> _extractSparkReplies(Map<String, dynamic> thread) {
    final List<Comment> result = [];

    // Skip the root post, only include replies
    final replies = thread['replies'] as List<dynamic>?;
    if (replies == null) {
      return result;
    }

    for (final reply in replies) {
      final post = reply['post'] as Map<String, dynamic>;
      result.add(Comment.fromSparkComment(post));

      // Process any nested replies if they exist
      if (reply['replies'] != null) {
        final nestedReplies = reply as Map<String, dynamic>;
        result.addAll(_extractSparkReplies(nestedReplies));
      }
    }

    return result;
  }
}