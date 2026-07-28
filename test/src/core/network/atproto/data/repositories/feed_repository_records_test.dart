import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository_impl.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

import 'repository_test_support.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 7, 22, 12, 34, 56);

  FeedRepositoryImpl repository(RepositoryHarness harness) {
    return FeedRepositoryImpl(
      harness.sprk,
      logger: SparkLogger(),
      now: () => fixedNow,
    );
  }

  group('FeedRepositoryImpl records', () {
    test(
      'likePost selects the record collection and uses the injected clock',
      () async {
        final harness = RepositoryHarness();
        final sparkPost = AtUri(
          'at://did:plc:author/so.sprk.feed.post/spark-post',
        );
        final bskyPost = AtUri(
          'at://did:plc:author/app.bsky.feed.post/bsky-post',
        );
        final feedRepository = repository(harness);

        await feedRepository.likePost('spark-cid', sparkPost);
        await feedRepository.likePost('bsky-cid', bskyPost);

        expect(harness.repo.createCalls, hasLength(2));
        final sparkCall = harness.repo.createCalls[0];
        expect(sparkCall.collection, 'so.sprk.feed.like');
        expect(sparkCall.record[r'$type'], 'so.sprk.feed.like');
        _expectStrongRef(
          sparkCall.record['subject'],
          uri: sparkPost,
          cid: 'spark-cid',
        );
        expect(sparkCall.record['createdAt'], fixedNow.toIso8601String());

        final bskyCall = harness.repo.createCalls[1];
        expect(bskyCall.collection, 'app.bsky.feed.like');
        expect(bskyCall.record[r'$type'], 'app.bsky.feed.like');
        _expectStrongRef(
          bskyCall.record['subject'],
          uri: bskyPost,
          cid: 'bsky-cid',
        );
        expect(bskyCall.record['createdAt'], fixedNow.toIso8601String());
      },
    );

    test(
      'unlikePost deletes the interaction without crosspost cleanup',
      () async {
        final harness = RepositoryHarness();
        final likeUri = AtUri(
          'at://did:plc:viewer/so.sprk.feed.like/interaction',
        );

        await repository(harness).unlikePost(likeUri);

        expect(harness.repo.deleteCalls, hasLength(1));
        expect(harness.repo.deleteCalls.single.uri, likeUri);
        expect(
          harness.repo.deleteCalls.single.skipBskyCrosspostCleanup,
          isTrue,
        );
      },
    );

    test('postComment writes Spark reply roots and parents', () async {
      final harness = RepositoryHarness();
      final parentUri = AtUri('at://did:plc:author/so.sprk.feed.post/parent');
      final rootUri = AtUri('at://did:plc:author/so.sprk.feed.post/root');

      await repository(harness).postComment(
        'A Spark reply',
        'parent-cid',
        parentUri,
        rootCid: 'root-cid',
        rootUri: rootUri,
      );

      final call = harness.repo.createCalls.single;
      expect(call.collection, 'so.sprk.feed.reply');
      expect(call.record[r'$type'], 'so.sprk.feed.reply');
      expect(call.record['text'], 'A Spark reply');
      expect(call.record, isNot(contains('facets')));
      expect(call.record['createdAt'], fixedNow.toIso8601String());
      final reply = call.record['reply'] as Map<String, dynamic>;
      expect(reply[r'$type'], 'so.sprk.feed.reply#replyRef');
      _expectStrongRef(reply['root'], uri: rootUri, cid: 'root-cid');
      _expectStrongRef(reply['parent'], uri: parentUri, cid: 'parent-cid');
    });

    test(
      'postComment writes Bluesky posts and defaults root to parent',
      () async {
        final harness = RepositoryHarness();
        final parentUri = AtUri(
          'at://did:web:sprk.so/app.bsky.feed.post/parent',
        );

        await repository(
          harness,
        ).postComment('A Bluesky reply', 'parent-cid', parentUri);

        final call = harness.repo.createCalls.single;
        expect(call.collection, 'app.bsky.feed.post');
        expect(call.record[r'$type'], 'app.bsky.feed.post');
        expect(call.record['text'], 'A Bluesky reply');
        expect(call.record['createdAt'], fixedNow.toIso8601String());
        final reply = call.record['reply'] as Map<String, dynamic>;
        expect(reply[r'$type'], 'app.bsky.feed.post#replyRef');
        _expectStrongRef(reply['root'], uri: parentUri, cid: 'parent-cid');
        _expectStrongRef(reply['parent'], uri: parentUri, cid: 'parent-cid');
      },
    );

    test('record creation errors propagate through the repository', () {
      final harness = RepositoryHarness()
        ..repo.createError = StateError('record write failed');

      expect(
        repository(
          harness,
        ).likePost('cid', AtUri('at://did:plc:author/so.sprk.feed.post/post')),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'record write failed',
          ),
        ),
      );
    });
  });

  group('FeedRepositoryImpl threads', () {
    test(
      'getThread sends Spark thread parameters and maps not-found posts',
      () async {
        final threadUri = AtUri(
          'at://did:plc:author/so.sprk.feed.post/missing',
        );
        final harness = RepositoryHarness(
          getResponse: <String, dynamic>{
            'thread': [
              {
                r'$type': 'so.sprk.feed.getPostThread#threadItem',
                'uri': threadUri.toString(),
                'depth': 0,
                'value': {
                  r'$type': 'so.sprk.feed.defs#notFoundPost',
                  'uri': threadUri.toString(),
                  'notFound': true,
                },
              },
            ],
          },
        );

        final result = await repository(
          harness,
        ).getThread(threadUri, depth: 4, parentHeight: 2);

        final request = harness.transport.singleRequest;
        expect(request.uri.path, '/xrpc/so.sprk.feed.getPostThread');
        expect(request.uri.queryParameters['anchor'], threadUri.toString());
        expect(request.uri.queryParameters['depth'], '4');
        expect(request.uri.queryParameters['parentHeight'], '2');
        expect(
          request.headers['atproto-proxy'],
          FakeSprkRepository.testSprkDid,
        );
        expect(result, isA<NotFoundPost>());
        expect((result as NotFoundPost).uri, threadUri);
        expect(result.notFound, isTrue);
      },
    );

    test('getThread rejects an uninitialized AtProto client', () {
      final harness = RepositoryHarness(atprotoInitialized: false);

      expect(
        repository(
          harness,
        ).getThread(AtUri('at://did:plc:author/so.sprk.feed.post/post')),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('AtProto not initialized'),
          ),
        ),
      );
      expect(harness.transport.requests, isEmpty);
    });
  });
}

void _expectStrongRef(
  Object? value, {
  required AtUri uri,
  required String cid,
}) {
  final ref = value as Map<String, dynamic>;
  expect(ref[r'$type'], 'com.atproto.repo.strongRef');
  expect(ref['uri'], uri.toString());
  expect(ref['cid'], cid);
}
