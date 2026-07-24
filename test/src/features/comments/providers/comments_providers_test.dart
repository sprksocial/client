import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/features/comments/providers/comment_provider.dart';
import 'package:spark/src/features/comments/providers/comments_page_provider.dart';
import 'package:spark/src/features/feed/providers/post_updates.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart' show ProfileViewBasic;

void main() {
  late _FakeFeedRepository feedRepository;

  setUp(() async {
    await GetIt.I.reset();
    feedRepository = _FakeFeedRepository();
    GetIt.I.registerSingleton<SprkRepository>(
      _FakeSprkRepository(feedRepository),
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('CommentNotifier', () {
    test(
      'likes an unliked post and updates the shared post revision',
      () async {
        final thread = _thread(likeCount: 2);
        final container = ProviderContainer.test();
        addTearDown(container.dispose);
        final provider = commentProvider(thread);
        final notifier = container.read(provider.notifier);

        await notifier.toggleLike();

        expect(feedRepository.likeCalls, [(cid: 'cid-post', uri: _sparkUri)]);
        expect(container.read(provider).isLiked, isTrue);
        expect(container.read(provider).likeCount, 3);
        expect(container.read(postUpdateProvider(_sparkUri.toString())), 1);
      },
    );

    test('optimistically unlikes a liked post', () async {
      final thread = _thread(likeCount: 2, likeUri: _likeUri);
      final container = ProviderContainer.test();
      addTearDown(container.dispose);
      final provider = commentProvider(thread);
      final notifier = container.read(provider.notifier);

      await notifier.toggleLike();

      expect(feedRepository.unlikeCalls, [_likeUri]);
      expect(container.read(provider).isLiked, isFalse);
      expect(container.read(provider).likeCount, 1);
      expect(container.read(postUpdateProvider(_sparkUri.toString())), 1);
    });

    test('restores the original state when liking fails', () async {
      final thread = _thread(likeCount: 2);
      final error = StateError('like failed');
      feedRepository.likeError = error;
      final container = ProviderContainer.test();
      addTearDown(container.dispose);
      final provider = commentProvider(thread);
      final notifier = container.read(provider.notifier);

      await expectLater(notifier.toggleLike(), throwsA(same(error)));

      expect(container.read(provider).thread, thread);
      expect(container.read(provider).isLiked, isFalse);
      expect(container.read(provider).likeCount, 2);
      expect(container.read(postUpdateProvider(_sparkUri.toString())), 0);
    });

    test('restores the original state when unliking fails', () async {
      final thread = _thread(likeCount: 2, likeUri: _likeUri);
      final error = StateError('unlike failed');
      feedRepository.unlikeError = error;
      final container = ProviderContainer.test();
      addTearDown(container.dispose);
      final provider = commentProvider(thread);
      final notifier = container.read(provider.notifier);

      await expectLater(notifier.toggleLike(), throwsA(same(error)));

      expect(container.read(provider).thread, thread);
      expect(container.read(provider).isLiked, isTrue);
      expect(container.read(provider).likeCount, 2);
      expect(container.read(postUpdateProvider(_sparkUri.toString())), 0);
    });
  });

  group('CommentsPage', () {
    test('loads Spark and Bluesky threads using the correct backend', () async {
      feedRepository.threadResults.addAll([_thread(), _thread(uri: _bskyUri)]);
      final container = ProviderContainer.test(
        retry: (retryCount, error) => null,
      );
      addTearDown(container.dispose);

      final sparkState = await container.read(
        commentsPageProvider(postUri: _sparkUri).future,
      );
      final bskyState = await container.read(
        commentsPageProvider(postUri: _bskyUri).future,
      );

      expect(sparkState.thread.post.uri, _sparkUri);
      expect(bskyState.thread.post.uri, _bskyUri);
      expect(feedRepository.threadCalls, [
        (uri: _sparkUri, depth: 1, bluesky: false),
        (uri: _bskyUri, depth: 1, bluesky: true),
      ]);
    });

    test(
      'posts a comment, waits for replication, and refreshes the thread',
      () async {
        final refreshed = _thread(replyCount: 4);
        feedRepository.threadResults.addAll([_thread(), refreshed]);
        final delays = <Duration>[];
        final container = ProviderContainer.test(
          retry: (retryCount, error) => null,
          overrides: [
            commentsReplicationDelayProvider.overrideWithValue((
              duration,
            ) async {
              delays.add(duration);
            }),
          ],
        );
        addTearDown(container.dispose);
        final provider = commentsPageProvider(postUri: _sparkUri);
        final subscription = container.listen(provider, (_, _) {});
        addTearDown(subscription.close);
        await container.read(provider.future);

        await container
            .read(provider.notifier)
            .postComment(
              'hello',
              'parent-cid',
              _sparkUri.toString(),
              rootCid: 'root-cid',
              rootUri: _rootUri.toString(),
            );

        expect(feedRepository.commentCalls, [
          (
            text: 'hello',
            parentCid: 'parent-cid',
            parentUri: _sparkUri,
            rootCid: 'root-cid',
            rootUri: _rootUri,
          ),
        ]);
        expect(delays, [const Duration(milliseconds: 700)]);
        expect(container.read(provider).value?.thread, refreshed);
        expect(feedRepository.threadCalls.last, (
          uri: _sparkUri,
          depth: 1,
          bluesky: false,
        ));
        expect(container.read(postUpdateProvider(_sparkUri.toString())), 1);
      },
    );

    test('deletes a comment and refreshes the loaded thread', () async {
      final refreshed = _thread(replyCount: 0);
      feedRepository.threadResults.addAll([_thread(replyCount: 1), refreshed]);
      final container = ProviderContainer.test(
        retry: (retryCount, error) => null,
      );
      addTearDown(container.dispose);
      final provider = commentsPageProvider(postUri: _sparkUri);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      await container.read(provider.future);

      await container
          .read(provider.notifier)
          .deleteComment(_commentUri.toString());

      expect(feedRepository.deletedUris, [_commentUri]);
      expect(container.read(provider).value?.thread, refreshed);
      expect(container.read(postUpdateProvider(_sparkUri.toString())), 1);
    });

    test(
      'post failure preserves the thread and skips delay and refresh',
      () async {
        final initial = _thread(replyCount: 1);
        final error = StateError('post failed');
        feedRepository
          ..threadResults.add(initial)
          ..commentError = error;
        final delays = <Duration>[];
        final container = ProviderContainer.test(
          retry: (retryCount, error) => null,
          overrides: [
            commentsReplicationDelayProvider.overrideWithValue((
              duration,
            ) async {
              delays.add(duration);
            }),
          ],
        );
        addTearDown(container.dispose);
        final provider = commentsPageProvider(postUri: _sparkUri);
        final subscription = container.listen(provider, (_, _) {});
        addTearDown(subscription.close);
        await container.read(provider.future);

        await expectLater(
          container
              .read(provider.notifier)
              .postComment('hello', 'parent-cid', _sparkUri.toString()),
          throwsA(same(error)),
        );

        expect(container.read(provider).value?.thread, initial);
        expect(delays, isEmpty);
        expect(feedRepository.threadCalls, hasLength(1));
        expect(container.read(postUpdateProvider(_sparkUri.toString())), 0);
      },
    );

    test('delete failure preserves the thread and skips refresh', () async {
      final initial = _thread(replyCount: 1);
      final error = StateError('delete failed');
      feedRepository
        ..threadResults.add(initial)
        ..deleteError = error;
      final container = ProviderContainer.test(
        retry: (retryCount, error) => null,
      );
      addTearDown(container.dispose);
      final provider = commentsPageProvider(postUri: _sparkUri);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      await container.read(provider.future);

      await expectLater(
        container.read(provider.notifier).deleteComment(_commentUri.toString()),
        throwsA(same(error)),
      );

      expect(container.read(provider).value?.thread, initial);
      expect(feedRepository.threadCalls, hasLength(1));
      expect(container.read(postUpdateProvider(_sparkUri.toString())), 0);
    });
  });
}

final _sparkUri = AtUri.parse('at://did:plc:author/so.sprk.feed.post/post');
final _bskyUri = AtUri.parse('at://did:plc:author/app.bsky.feed.post/post');
final _rootUri = AtUri.parse('at://did:plc:author/so.sprk.feed.post/root');
final _commentUri = AtUri.parse(
  'at://did:plc:author/so.sprk.feed.reply/comment',
);
final _likeUri = AtUri.parse('at://did:plc:user/so.sprk.feed.like/like');
final _author = ProfileViewBasic(
  did: 'did:plc:author',
  handle: 'author.sprk.so',
);

ThreadViewPost _thread({
  AtUri? uri,
  int likeCount = 0,
  int replyCount = 0,
  AtUri? likeUri,
}) {
  final postUri = uri ?? _sparkUri;
  return ThreadViewPost(
    post: ThreadPost.post(
      post: PostView(
        uri: postUri,
        cid: 'cid-${postUri.rkey}',
        author: _author,
        record: const {r'$type': 'so.sprk.feed.post', 'text': 'post'},
        indexedAt: DateTime.parse('2026-07-01T12:00:00Z'),
        likeCount: likeCount,
        replyCount: replyCount,
        viewer: likeUri == null ? null : ViewerState(like: likeUri),
      ),
    ),
  );
}

class _FakeFeedRepository implements FeedRepository {
  final threadResults = <Thread>[];
  final threadCalls = <({AtUri uri, int depth, bool bluesky})>[];
  final likeCalls = <({String cid, AtUri uri})>[];
  final unlikeCalls = <AtUri>[];
  final deletedUris = <AtUri>[];
  final commentCalls =
      <
        ({
          String text,
          String parentCid,
          AtUri parentUri,
          String? rootCid,
          AtUri? rootUri,
        })
      >[];
  Object? likeError;
  Object? unlikeError;
  Object? commentError;
  Object? deleteError;

  @override
  Future<Thread> getThread(
    AtUri uri, {
    int depth = 2,
    int parentHeight = 0,
    bool bluesky = false,
  }) async {
    threadCalls.add((uri: uri, depth: depth, bluesky: bluesky));
    return threadResults.removeAt(0);
  }

  @override
  Future<RepoStrongRef> likePost(String postCid, AtUri postUri) async {
    likeCalls.add((cid: postCid, uri: postUri));
    if (likeError case final error?) throw error;
    return RepoStrongRef(uri: _likeUri, cid: 'like-cid');
  }

  @override
  Future<void> unlikePost(AtUri likeUri) async {
    unlikeCalls.add(likeUri);
    if (unlikeError case final error?) throw error;
  }

  @override
  Future<RepoStrongRef> postComment(
    String text,
    String parentCid,
    AtUri parentUri, {
    String? rootCid,
    AtUri? rootUri,
    List<XFile>? imageFiles,
    Map<String, String>? altTexts,
    List<Facet> facets = const [],
  }) async {
    commentCalls.add((
      text: text,
      parentCid: parentCid,
      parentUri: parentUri,
      rootCid: rootCid,
      rootUri: rootUri,
    ));
    if (commentError case final error?) throw error;
    return RepoStrongRef(uri: _commentUri, cid: 'comment-cid');
  }

  @override
  Future<bool> deletePost(AtUri postUri) async {
    deletedUris.add(postUri);
    if (deleteError case final error?) throw error;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSprkRepository implements SprkRepository {
  _FakeSprkRepository(this.feedRepository);

  final FeedRepository feedRepository;

  @override
  FeedRepository get feed => feedRepository;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
