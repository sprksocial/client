import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/features/feed/navigation/standalone_post_navigation_resolver.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

void main() {
  const rootPostUri = 'at://did:plc:author/so.sprk.feed.post/root';
  const directReplyUri = 'at://did:plc:author/so.sprk.feed.reply/direct';
  const parentReplyUri = 'at://did:plc:author/so.sprk.feed.reply/parent';
  const childReplyUri = 'at://did:plc:author/so.sprk.feed.reply/child';
  const fallbackPostUri = 'at://did:plc:author/so.sprk.feed.post/fallback';

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
    'uses highlighted reply as the anchor when notification subject is parent',
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
      expect(feedRepository.threadRequests, [childReplyUri]);
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

PostView _post(String uri) {
  return PostView(
    uri: AtUri.parse(uri),
    cid: 'cid-${AtUri.parse(uri).rkey}',
    author: _author,
    record: const {r'$type': 'so.sprk.feed.post', 'text': 'root post'},
    indexedAt: _indexedAt,
  );
}

ReplyView _reply(String uri) {
  return ReplyView(
    uri: AtUri.parse(uri),
    cid: 'cid-${AtUri.parse(uri).rkey}',
    author: _author,
    record: const {r'$type': 'so.sprk.feed.reply', 'text': 'reply'},
    indexedAt: _indexedAt,
  );
}

ThreadViewPost _threadPost(PostView post, {List<Thread>? replies}) {
  return ThreadViewPost(
    post: ThreadPost.post(post: post),
    replies: replies,
  );
}

ThreadViewPost _threadReply(String uri, {required ThreadViewPost parent}) {
  return ThreadViewPost(
    post: ThreadPost.reply(reply: _reply(uri)),
    parent: parent,
  );
}

class _FakeFeedRepository implements FeedRepository {
  final threads = <String, Thread>{};
  final posts = <String, PostView>{};
  final threadRequests = <String>[];
  final postRequests = <List<String>>[];

  @override
  Future<Thread> getThread(
    AtUri uri, {
    int depth = 2,
    int parentHeight = 0,
    bool bluesky = false,
  }) async {
    final uriString = uri.toString();
    threadRequests.add(uriString);
    final thread = threads[uriString];
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
