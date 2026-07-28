import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository_impl.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:sprk_poptart/so/sprk/actor/defs/profile_view_basic.dart';

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

  group('FeedRepositoryImpl feed requests', () {
    test('getFeed routes timeline requests and maps hydrated posts', () async {
      final post = _postView();
      final harness = RepositoryHarness(
        getResponse: <String, dynamic>{
          'cursor': 'timeline-next',
          'feed': [
            {'post': post.toJson()},
          ],
        },
      );
      final feed = Feed(
        type: 'timeline',
        config: makeSavedFeed(
          id: 'timeline',
          type: 'timeline',
          value: 'timeline',
          pinned: true,
        ),
      );

      final result = await repository(harness).getFeed(
        feed,
        limit: 12,
        cursor: 'timeline-cursor',
        labelerDids: const ['did:plc:one', 'did:plc:two'],
      );

      final request = harness.transport.singleRequest;
      expect(request.uri.path, '/xrpc/so.sprk.feed.getTimeline');
      expect(request.uri.queryParameters['limit'], '12');
      expect(request.uri.queryParameters['cursor'], 'timeline-cursor');
      expect(request.headers['atproto-proxy'], FakeSprkRepository.testSprkDid);
      expect(
        request.headers['atproto-accept-labelers'],
        'did:plc:one,did:plc:two',
      );
      expect(result.cursor, 'timeline-next');
      expect(result.feed.single.post.uri, post.uri);
    });

    test(
      'getFeedView sends Spark feed requests to the Spark service',
      () async {
        final post = _postView();
        final harness = RepositoryHarness(
          getResponse: <String, dynamic>{
            'cursor': 'spark-next',
            'feed': [
              {'post': post.toJson()},
            ],
          },
        );
        final feedUri = AtUri(
          'at://did:plc:generator/so.sprk.feed.generator/spark-feed',
        );

        final result = await repository(harness).getFeedView(
          feedUri,
          limit: 8,
          cursor: 'spark-cursor',
          labelerDids: const ['did:plc:labeler'],
        );

        final request = harness.transport.singleRequest;
        expect(request.uri.path, '/xrpc/so.sprk.feed.getFeed');
        expect(request.uri.queryParameters['feed'], feedUri.toString());
        expect(request.uri.queryParameters['limit'], '8');
        expect(request.uri.queryParameters['cursor'], 'spark-cursor');
        expect(
          request.headers['atproto-proxy'],
          FakeSprkRepository.testSprkDid,
        );
        expect(request.headers['atproto-accept-labelers'], 'did:plc:labeler');
        expect(result.cursor, 'spark-next');
        expect(result.feed.single.post.uri, post.uri);
      },
    );

    test(
      'getFeedView selects Bluesky and omits Spark labeler headers',
      () async {
        final harness = RepositoryHarness(
          getResponse: const <String, dynamic>{
            'cursor': 'bsky-next',
            'feed': <dynamic>[],
          },
        );
        final feedUri = AtUri(
          'at://did:plc:generator/app.bsky.feed.generator/bsky-feed',
        );

        final result = await repository(harness).getFeedView(
          feedUri,
          limit: 6,
          cursor: 'bsky-cursor',
          labelerDids: const ['did:plc:labeler'],
        );

        final request = harness.transport.singleRequest;
        expect(request.uri.path, '/xrpc/app.bsky.feed.getFeed');
        expect(request.uri.queryParameters['feed'], feedUri.toString());
        expect(request.uri.queryParameters['limit'], '6');
        expect(request.uri.queryParameters['cursor'], 'bsky-cursor');
        expect(
          request.headers['atproto-proxy'],
          FakeSprkRepository.testBskyDid,
        );
        expect(request.headers, isNot(contains('atproto-accept-labelers')));
        expect(result.cursor, 'bsky-next');
        expect(result.feed, isEmpty);
      },
    );

    test('getFeedView rejects unauthenticated requests before transport', () {
      final harness = RepositoryHarness(authenticated: false);

      expect(
        repository(harness).getFeedView(
          AtUri('at://did:plc:generator/so.sprk.feed.generator/feed'),
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Not authenticated'),
          ),
        ),
      );
      expect(harness.transport.requests, isEmpty);
    });

    test('getFeedView propagates the transport 500 response', () async {
      final harness = RepositoryHarness(
        getStatusCode: 500,
        getResponse: const <String, dynamic>{
          'error': 'InternalServerError',
          'message': 'feed unavailable',
        },
      );

      await expectLater(
        repository(harness).getFeedView(
          AtUri('at://did:plc:generator/so.sprk.feed.generator/feed'),
        ),
        throwsA(
          isA<InternalServerErrorException>().having(
            (error) => error.toString(),
            'message',
            allOf(
              contains('InternalServerError'),
              contains('feed unavailable'),
            ),
          ),
        ),
      );
      expect(harness.transport.requests, hasLength(1));
      expect(
        harness.transport.singleRequest.uri.path,
        '/xrpc/so.sprk.feed.getFeed',
      );
    });
  });
}

PostView _postView() {
  return PostView(
    uri: AtUri('at://did:plc:author/so.sprk.feed.post/post'),
    cid: 'post-cid',
    author: const ProfileViewBasic(
      did: 'did:plc:author',
      handle: 'author.test',
    ),
    record: const <String, dynamic>{
      r'$type': 'so.sprk.feed.post',
      'caption': {'text': 'A post', 'facets': <dynamic>[]},
      'createdAt': '2026-07-22T12:00:00.000Z',
    },
    indexedAt: DateTime.utc(2026, 7, 22, 12),
  );
}
