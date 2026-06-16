import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/features/feed/navigation/standalone_post_navigation_resolver.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

const rootPostUri = 'at://did:plc:author/so.sprk.feed.post/root';
const directReplyUri = 'at://did:plc:author/so.sprk.feed.reply/direct';
const parentReplyUri = 'at://did:plc:author/so.sprk.feed.reply/parent';
const childReplyUri = 'at://did:plc:author/so.sprk.feed.reply/child';
const fallbackPostUri = 'at://did:plc:author/so.sprk.feed.post/fallback';
const bskyRootPostUri = 'at://did:plc:author/app.bsky.feed.post/root';
const bskyDirectReplyUri = 'at://did:plc:author/app.bsky.feed.post/direct';
const bskyParentReplyUri = 'at://did:plc:author/app.bsky.feed.post/parent';
const bskyChildReplyUri = 'at://did:plc:author/app.bsky.feed.post/child';

void main() {
  late _FakeFeedRepository feedRepository;
  late StandalonePostNavigationResolver resolver;

  setUp(() {
    feedRepository = _FakeFeedRepository();
    resolver = StandalonePostNavigationResolver(feedRepository);
  });

  test('opens root posts without a comment route', () async {
    final rootPost = _post(rootPostUri);
    feedRepository.threads[rootPostUri] = _threadPost(rootPost);

    final resolved = await resolver.resolve(postUri: rootPostUri);

    expect(resolved.post.uri.toString(), rootPostUri);
    expect(resolved.highlightedReplyUri, isNull);
    expect(resolved.parentReplyUris, isEmpty);
  });

  test('opens a direct reply on the root post and highlights it', () async {
    final rootPost = _post(rootPostUri);
    final rootThread = _threadPost(rootPost);
    feedRepository.threads[directReplyUri] = _threadReply(
      directReplyUri,
      parent: rootThread,
    );

    final resolved = await resolver.resolve(postUri: directReplyUri);

    expect(resolved.post.uri.toString(), rootPostUri);
    expect(resolved.highlightedReplyUri, directReplyUri);
    expect(resolved.parentReplyUris, isEmpty);
  });

  test('opens parent reply pages before highlighting a nested reply', () async {
    final rootPost = _post(rootPostUri);
    final rootThread = _threadPost(rootPost);
    final parentThread = _threadReply(parentReplyUri, parent: rootThread);
    feedRepository.threads[childReplyUri] = _threadReply(
      childReplyUri,
      parent: parentThread,
    );

    final resolved = await resolver.resolve(postUri: childReplyUri);

    expect(resolved.post.uri.toString(), rootPostUri);
    expect(resolved.highlightedReplyUri, childReplyUri);
    expect(resolved.parentReplyUris, [parentReplyUri]);
  });

  test(
    'uses notification subject as the anchor for highlighted replies',
    () async {
      final rootPost = _post(rootPostUri);
      final rootThread = _threadPost(rootPost);
      final parentThread = _threadReply(parentReplyUri, parent: rootThread);
      feedRepository.threads[childReplyUri] = _threadReply(
        childReplyUri,
        parent: parentThread,
      );
      feedRepository.threads[parentReplyUri] = parentThread;

      final resolved = await resolver.resolve(
        postUri: parentReplyUri,
        highlightedReplyUri: childReplyUri,
      );

      expect(resolved.post.uri.toString(), rootPostUri);
      expect(resolved.highlightedReplyUri, childReplyUri);
      expect(resolved.parentReplyUris, [parentReplyUri]);
      expect(feedRepository.threadRequests.map((request) => request.uri), [
        parentReplyUri,
      ]);
    },
  );

  test(
    'loads enough reply depth to route nested reply notifications',
    () async {
      final rootPost = _post(rootPostUri);
      final shallowThread = _rootThreadWithDirectReply(rootPost);
      final nestedThread = _rootThreadWithReplyChain(rootPost);
      feedRepository.threadBuilders[parentReplyUri] = (request) {
        return request.depth >= 3 ? nestedThread : shallowThread;
      };

      final resolved = await resolver.resolve(
        postUri: parentReplyUri,
        highlightedReplyUri: childReplyUri,
      );

      expect(resolved.post.uri.toString(), rootPostUri);
      expect(resolved.highlightedReplyUri, childReplyUri);
      expect(resolved.parentReplyUris, [directReplyUri, parentReplyUri]);
      expect(feedRepository.threadRequests.single.depth, 6);
    },
  );

  test(
    'uses Bluesky post-view parent chains for nested reply notifications',
    () async {
      final rootThread = _threadPost(_bskyPost(bskyRootPostUri));
      final directThread = _threadPost(
        _bskyPost(bskyDirectReplyUri),
        parent: rootThread,
      );
      final parentThread = _threadPost(
        _bskyPost(bskyParentReplyUri),
        parent: directThread,
      );
      feedRepository.threads[bskyParentReplyUri] = parentThread;
      feedRepository.threads[bskyChildReplyUri] = _threadPost(
        _bskyPost(bskyChildReplyUri),
        parent: parentThread,
      );

      final resolved = await resolver.resolve(
        postUri: bskyParentReplyUri,
        highlightedReplyUri: bskyChildReplyUri,
      );

      expect(resolved.post.uri.toString(), bskyRootPostUri);
      expect(resolved.highlightedReplyUri, bskyChildReplyUri);
      expect(resolved.parentReplyUris, [
        bskyDirectReplyUri,
        bskyParentReplyUri,
      ]);
      expect(feedRepository.threadRequests.single.bluesky, isTrue);
    },
  );

  test(
    'prefers target parent chain when the reply appears shallow in replies',
    () async {
      final rootPost = _post(rootPostUri);
      final rootThread = _threadPost(rootPost);
      final directThread = _threadReply(directReplyUri, parent: rootThread);
      final parentThread = _threadReply(parentReplyUri, parent: directThread);
      final childThread = _threadReply(childReplyUri, parent: parentThread);
      feedRepository.threads[childReplyUri] = _threadPost(
        rootPost,
        replies: [childThread],
      );

      final resolved = await resolver.resolve(
        postUri: parentReplyUri,
        highlightedReplyUri: childReplyUri,
      );

      expect(resolved.post.uri.toString(), rootPostUri);
      expect(resolved.highlightedReplyUri, childReplyUri);
      expect(resolved.parentReplyUris, [directReplyUri, parentReplyUri]);
    },
  );

  test(
    'uses notification subject before the highlighted reply fallback',
    () async {
      final rootPost = _post(rootPostUri);
      final rootThread = _threadPost(rootPost);
      final directThread = _threadReply(directReplyUri, parent: rootThread);
      final parentThread = _threadReply(parentReplyUri, parent: directThread);
      feedRepository.threads[childReplyUri] = _threadPost(
        rootPost,
        replies: [_threadReply(childReplyUri, parent: rootThread)],
      );
      feedRepository.threads[parentReplyUri] = parentThread;

      final resolved = await resolver.resolve(
        postUri: parentReplyUri,
        highlightedReplyUri: childReplyUri,
      );

      expect(resolved.post.uri.toString(), rootPostUri);
      expect(resolved.highlightedReplyUri, childReplyUri);
      expect(resolved.parentReplyUris, [directReplyUri, parentReplyUri]);
      expect(feedRepository.threadRequests.map((request) => request.uri), [
        parentReplyUri,
      ]);
    },
  );

  test(
    'falls back to loading the requested post when thread loading fails',
    () async {
      final fallbackPost = _post(fallbackPostUri);
      feedRepository.posts[fallbackPostUri] = fallbackPost;

      final resolved = await resolver.resolve(postUri: fallbackPostUri);

      expect(resolved.post, fallbackPost);
      expect(resolved.highlightedReplyUri, isNull);
      expect(resolved.parentReplyUris, isEmpty);
      expect(feedRepository.postRequests, [
        [fallbackPostUri],
      ]);
    },
  );
}

final _author = ProfileViewBasic(
  did: 'did:plc:author',
  handle: 'author.sprk.so',
);
final _indexedAt = DateTime.parse('2026-06-01T12:00:00.000Z');

PostView _post(String uri, {String recordType = 'so.sprk.feed.post'}) {
  return PostView(
    uri: AtUri.parse(uri),
    cid: 'cid-${AtUri.parse(uri).rkey}',
    author: _author,
    record: {r'$type': recordType, 'text': 'root post'},
    indexedAt: _indexedAt,
  );
}

PostView _bskyPost(String uri) => _post(uri, recordType: 'app.bsky.feed.post');

ReplyView _reply(String uri) {
  return ReplyView(
    uri: AtUri.parse(uri),
    cid: 'cid-${AtUri.parse(uri).rkey}',
    author: _author,
    record: const {r'$type': 'so.sprk.feed.reply', 'text': 'reply'},
    indexedAt: _indexedAt,
  );
}

ThreadViewPost _threadPost(
  PostView post, {
  Thread? parent,
  List<Thread>? replies,
}) {
  return ThreadViewPost(
    post: ThreadPost.post(post: post),
    parent: parent,
    replies: replies,
  );
}

ThreadViewPost _threadReply(
  String uri, {
  required ThreadViewPost parent,
  List<Thread>? replies,
}) {
  return ThreadViewPost(
    post: ThreadPost.reply(reply: _reply(uri)),
    parent: parent,
    replies: replies,
  );
}

ThreadViewPost _rootThreadWithDirectReply(PostView rootPost) {
  final rootThread = _threadPost(rootPost);
  final directThread = _threadReply(directReplyUri, parent: rootThread);
  return _threadPost(rootPost, replies: [directThread]);
}

ThreadViewPost _rootThreadWithReplyChain(PostView rootPost) {
  final rootThread = _threadPost(rootPost);
  final directThread = _threadReply(directReplyUri, parent: rootThread);
  final parentThread = _threadReply(parentReplyUri, parent: directThread);
  final childThread = _threadReply(childReplyUri, parent: parentThread);
  final parentWithChild = _threadReply(
    parentReplyUri,
    parent: directThread,
    replies: [childThread],
  );
  final directWithParent = _threadReply(
    directReplyUri,
    parent: rootThread,
    replies: [parentWithChild],
  );
  return _threadPost(rootPost, replies: [directWithParent]);
}

typedef _ThreadRequest = ({
  String uri,
  int depth,
  int parentHeight,
  bool bluesky,
});

typedef _ThreadBuilder = Thread Function(_ThreadRequest request);

class _FakeFeedRepository implements FeedRepository {
  final threads = <String, Thread>{};
  final threadBuilders = <String, _ThreadBuilder>{};
  final posts = <String, PostView>{};
  final threadRequests = <_ThreadRequest>[];
  final postRequests = <List<String>>[];

  @override
  Future<Thread> getThread(
    AtUri uri, {
    int depth = 2,
    int parentHeight = 0,
    bool bluesky = false,
  }) async {
    final uriString = uri.toString();
    final request = (
      uri: uriString,
      depth: depth,
      parentHeight: parentHeight,
      bluesky: bluesky,
    );
    threadRequests.add(request);
    final thread =
        threadBuilders[uriString]?.call(request) ?? threads[uriString];
    if (thread == null) {
      throw StateError('No thread for $uriString');
    }
    return thread;
  }

  @override
  Future<List<PostView>> getPosts(
    List<AtUri> uris, {
    bool bluesky = false,
    bool filter = true,
  }) async {
    final uriStrings = uris.map((uri) => uri.toString()).toList();
    postRequests.add(uriStrings);
    return [for (final uri in uriStrings) ?posts[uri]];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
