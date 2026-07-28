import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/repositories/graph_repository_impl.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

import 'repository_test_support.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 7, 22, 12, 34, 56);

  group('GraphRepositoryImpl', () {
    test('getFollowers forwards actor, cursor, and Spark proxy', () async {
      final harness = RepositoryHarness();
      harness.transport.enqueueGet({
        'subject': _profile('did:plc:alice'),
        'cursor': 'next-page',
        'followers': [_profile('did:plc:bob')],
      });
      final repository = GraphRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
        now: () => fixedNow,
      );

      final output = await repository.getFollowers(
        'did:plc:alice',
        cursor: 'page-1',
      );

      final request = harness.transport.singleRequest;
      expect(request.uri.path, '/xrpc/so.sprk.graph.getFollowers');
      expect(request.uri.queryParameters['actor'], 'did:plc:alice');
      expect(request.uri.queryParameters['cursor'], 'page-1');
      expect(
        request.headers['atproto-proxy'],
        'did:web:sprk.test#sprk_appview',
      );
      expect(output.cursor, 'next-page');
      expect(output.followers.single.did, 'did:plc:bob');
    });

    test('graph reads fail before transport when auth is absent', () {
      final harness = RepositoryHarness(authenticated: false);
      final repository = GraphRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
        now: () => fixedNow,
      );

      expect(repository.getFollows('did:plc:alice'), throwsA(isA<Exception>()));
      expect(harness.transport.requests, isEmpty);
    });

    test(
      'followUser checks duplicates then writes a deterministic record',
      () async {
        final harness = RepositoryHarness();
        harness.transport.enqueueGet({'records': <dynamic>[]});
        final repository = GraphRepositoryImpl(
          harness.sprk,
          logger: SparkLogger(),
          now: () => fixedNow,
        );

        final result = await repository.followUser('did:plc:alice');

        final request = harness.transport.singleRequest;
        expect(request.uri.path, '/xrpc/com.atproto.repo.listRecords');
        expect(request.uri.queryParameters['repo'], 'did:plc:viewer');
        expect(
          request.uri.queryParameters['collection'],
          'so.sprk.graph.follow',
        );
        final create = harness.repo.createCalls.single;
        expect(create.collection, 'so.sprk.graph.follow');
        expect(create.repo, 'did:plc:viewer');
        expect(create.record['subject'], 'did:plc:alice');
        expect(create.record['createdAt'], fixedNow.toIso8601String());
        expect(result.cid, 'result-cid');
      },
    );

    test(
      'followUser rejects an existing relationship without another write',
      () {
        final harness = RepositoryHarness();
        harness.transport.enqueueGet({
          'records': [
            {
              r'$type': 'com.atproto.repo.listRecords#record',
              'uri': 'at://did:plc:viewer/so.sprk.graph.follow/existing',
              'cid': 'existing-cid',
              'value': {'subject': 'did:plc:alice'},
            },
          ],
        });
        final repository = GraphRepositoryImpl(
          harness.sprk,
          logger: SparkLogger(),
          now: () => fixedNow,
        );

        expect(
          repository.followUser('did:plc:alice'),
          throwsA(
            isA<Exception>().having(
              (error) => error.toString(),
              'message',
              contains('Already following'),
            ),
          ),
        );
        expect(harness.repo.createCalls, isEmpty);
      },
    );

    test(
      'unfollow delegates exact URI and suppresses crosspost cleanup',
      () async {
        final harness = RepositoryHarness();
        final repository = GraphRepositoryImpl(
          harness.sprk,
          logger: SparkLogger(),
          now: () => fixedNow,
        );
        final uri = AtUri(
          'at://did:plc:viewer/so.sprk.graph.follow/follow-rkey',
        );

        await repository.unfollowUser(uri);

        final deletion = harness.repo.deleteCalls.single;
        expect(deletion.uri, uri);
        expect(deletion.skipBskyCrosspostCleanup, isTrue);
      },
    );
  });
}

Map<String, dynamic> _profile(String did) => {
  r'$type': 'so.sprk.actor.defs#profileView',
  'did': did,
  'handle': '${did.split(':').last}.test',
};
