import 'package:poptart/poptart.dart';

import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';

const _navigationThreadDepth = 6;
const _navigationParentHeight = 50;

class ResolvedStandalonePost {
  const ResolvedStandalonePost({
    required this.post,
    this.highlightedReplyUri,
    this.parentReplyUris = const <String>[],
  });

  final PostView post;
  final String? highlightedReplyUri;
  final List<String> parentReplyUris;
}

class _NavigationAnchor {
  const _NavigationAnchor({required this.uri, this.targetReplyUri});

  final String uri;
  final String? targetReplyUri;
}

class StandalonePostNavigationResolver {
  const StandalonePostNavigationResolver(this._feedRepository);

  final FeedRepository _feedRepository;

  Future<ResolvedStandalonePost> resolve({
    required String postUri,
    String? highlightedReplyUri,
  }) async {
    final anchors = [
      _NavigationAnchor(uri: postUri, targetReplyUri: highlightedReplyUri),
      if (highlightedReplyUri != null && highlightedReplyUri != postUri)
        _NavigationAnchor(
          uri: highlightedReplyUri,
          targetReplyUri: highlightedReplyUri,
        ),
    ];

    for (final anchor in anchors) {
      final resolvedPost = await _resolveThreadAt(anchor);
      if (resolvedPost != null) {
        return resolvedPost;
      }
    }

    final uri = AtUri.parse(postUri);
    final post = await _loadPostWithFallback(uri);
    return ResolvedStandalonePost(post: post);
  }

  Future<ResolvedStandalonePost?> _resolveThreadAt(
    _NavigationAnchor anchor,
  ) async {
    final uri = AtUri.parse(anchor.uri);
    final Thread thread;

    try {
      thread = await _loadThread(uri);
    } catch (_) {
      return null;
    }

    if (thread is! ThreadViewPost) return null;

    return _resolveThreadNavigation(thread: thread, uri: uri, anchor: anchor);
  }

  Future<Thread> _loadThread(AtUri uri) {
    return _feedRepository.getThread(
      uri,
      depth: _navigationThreadDepth,
      parentHeight: _navigationParentHeight,
      bluesky: _isBlueskyPost(uri),
    );
  }

  Future<ResolvedStandalonePost> _resolveThreadNavigation({
    required ThreadViewPost thread,
    required AtUri uri,
    required _NavigationAnchor anchor,
  }) async {
    final anchorThread = _findThreadByUri(thread, anchor.uri) ?? thread;
    final rawReplyPath = _findReplyPath(thread, anchor.uri);
    final replyPath =
        rawReplyPath != null &&
            rawReplyPath.length == 1 &&
            rawReplyPath.first.post.uri.toString() == anchor.uri &&
            rawReplyPath.first.parent is ThreadViewPost
        ? null
        : rawReplyPath;
    final rootThread = replyPath?.first ?? _findRootThread(anchorThread);
    final displayPost = await _getDisplayPost(rootThread);
    final anchorIsReply =
        (replyPath != null && replyPath.length > 1) ||
        anchorThread.parent is ThreadViewPost ||
        anchorThread.post is ThreadReplyView ||
        _isSprkReplyUri(uri);
    final targetReplyUri =
        anchor.targetReplyUri ?? (anchorIsReply ? anchor.uri : null);
    final parentReplyUri =
        targetReplyUri != null && targetReplyUri != anchor.uri && anchorIsReply
        ? anchor.uri
        : null;

    return ResolvedStandalonePost(
      post: displayPost,
      highlightedReplyUri: targetReplyUri,
      parentReplyUris: _resolveParentReplyUris(
        anchorIsReply: anchorIsReply,
        anchorThread: anchorThread,
        replyPath: replyPath,
        parentReplyUri: parentReplyUri,
      ),
    );
  }

  List<String> _resolveParentReplyUris({
    required bool anchorIsReply,
    required ThreadViewPost anchorThread,
    required List<ThreadViewPost>? replyPath,
    required String? parentReplyUri,
  }) {
    if (!anchorIsReply) return const <String>[];

    final replyPathUris = replyPath != null
        ? _collectReplyChainUrisFromPath(replyPath)
        : const <String>[];
    final parentChainUris = _collectIntermediateReplyUris(anchorThread);
    // Thread APIs can return the target as a shallow reply while preserving
    // richer parent links; route with whichever ancestry source is deeper.
    final replyUris = parentChainUris.length > replyPathUris.length
        ? parentChainUris
        : replyPathUris;

    if (parentReplyUri == null) return replyUris;
    if (replyUris.isNotEmpty && replyUris.last == parentReplyUri) {
      return replyUris;
    }

    return [...replyUris, parentReplyUri];
  }

  ThreadViewPost? _findThreadByUri(
    ThreadViewPost thread,
    String targetUri, {
    Set<String>? visited,
  }) {
    final seen = visited ?? <String>{};
    final currentUri = thread.post.uri.toString();
    if (!seen.add(currentUri)) return null;
    if (currentUri == targetUri) return thread;

    if (thread.parent case ThreadViewPost parentThread) {
      final match = _findThreadByUri(parentThread, targetUri, visited: seen);
      if (match != null) {
        return match;
      }
    }

    final replies = thread.replies;
    if (replies != null) {
      for (final reply in replies) {
        if (reply is! ThreadViewPost) continue;
        final match = _findThreadByUri(reply, targetUri, visited: seen);
        if (match != null) {
          return match;
        }
      }
    }

    return null;
  }

  List<ThreadViewPost>? _findReplyPath(
    ThreadViewPost thread,
    String targetUri, {
    Set<String>? visited,
  }) {
    final seen = visited ?? <String>{};
    final currentUri = thread.post.uri.toString();
    if (!seen.add(currentUri)) return null;
    if (currentUri == targetUri) return [thread];

    final replies = thread.replies;
    if (replies == null) return null;

    for (final reply in replies) {
      if (reply is! ThreadViewPost) continue;
      final childPath = _findReplyPath(reply, targetUri, visited: {...seen});
      if (childPath != null) {
        return [thread, ...childPath];
      }
    }

    return null;
  }

  ThreadViewPost _findRootThread(ThreadViewPost thread) {
    var current = thread;
    while (true) {
      final parentThread = current.parent;
      if (parentThread is! ThreadViewPost) {
        return current;
      }
      current = parentThread;
    }
  }

  List<String> _collectIntermediateReplyUris(ThreadViewPost anchorThread) {
    final replyUris = <String>[];
    var current = anchorThread.parent;

    while (current is ThreadViewPost) {
      if (current.parent is ThreadViewPost) {
        replyUris.add(current.post.uri.toString());
      }
      current = current.parent;
    }

    return replyUris.reversed.toList(growable: false);
  }

  List<String> _collectReplyChainUrisFromPath(List<ThreadViewPost> replyPath) {
    if (replyPath.length < 3) return const <String>[];
    return replyPath
        .sublist(1, replyPath.length - 1)
        .map((thread) => thread.post.uri.toString())
        .toList(growable: false);
  }

  Future<PostView> _getDisplayPost(ThreadViewPost rootThread) async {
    if (rootThread.post case ThreadPostView(:final post)) {
      return post;
    }

    return _loadPostWithFallback(rootThread.post.uri);
  }

  Future<PostView> _loadPostWithFallback(AtUri uri) async {
    const maxRetries = 3;
    const delay = Duration(seconds: 2);

    for (var i = 0; i < maxRetries; i++) {
      final networkPost = await _feedRepository.getPosts([
        uri,
      ], bluesky: _isBlueskyPost(uri));
      if (networkPost.isNotEmpty) {
        return networkPost.first;
      }
      if (i < maxRetries - 1) {
        await Future.delayed(delay);
      }
    }

    throw Exception('Failed to load post after $maxRetries attempts');
  }

  bool _isBlueskyPost(AtUri uri) {
    return uri.collection.toString().startsWith('app.bsky.feed.post');
  }

  bool _isSprkReplyUri(AtUri uri) {
    return uri.collection.toString() == 'so.sprk.feed.reply';
  }
}
