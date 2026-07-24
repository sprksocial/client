import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/record_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/repo_repository_impl.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

import 'repository_test_support.dart';

void main() {
  group('RepoRepositoryImpl', () {
    test(
      'getRecord decomposes the URI and returns record plus strong ref',
      () async {
        final harness = RepositoryHarness();
        const record = <String, dynamic>{
          r'$type': 'app.bsky.feed.post',
          'text': 'Hello',
          'facets': <dynamic>[],
        };
        harness.transport.enqueueGet({
          'uri': 'at://did:plc:alice/app.bsky.feed.post/post-1',
          'cid': 'post-cid',
          'value': record,
        });
        final repository = RepoRepositoryImpl(
          harness.sprk,
          logger: SparkLogger(),
        );
        final uri = AtUri('at://did:plc:alice/app.bsky.feed.post/post-1');

        final result = await repository.getRecord(uri: uri);

        final request = harness.transport.singleRequest;
        expect(request.uri.path, '/xrpc/com.atproto.repo.getRecord');
        expect(request.uri.queryParameters['repo'], 'did:plc:alice');
        expect(request.uri.queryParameters['collection'], 'app.bsky.feed.post');
        expect(request.uri.queryParameters['rkey'], 'post-1');
        expect(result.record, isA<BskyPostRecord>());
        expect(result.strongRef.uri, uri);
        expect(result.strongRef.cid, 'post-cid');
      },
    );

    test('getRecord enforces authentication before transport', () {
      final harness = RepositoryHarness(authenticated: false);
      final repository = RepoRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );

      expect(
        repository.getRecord(
          uri: AtUri('at://did:plc:alice/app.bsky.feed.post/post-1'),
        ),
        throwsA(isA<Exception>()),
      );
      expect(harness.transport.requests, isEmpty);
    });

    test(
      'createRecord uses the session DID and preserves optional rkey',
      () async {
        final harness = RepositoryHarness();
        harness.transport.enqueuePost({
          'uri': 'at://did:plc:viewer/so.sprk.feed.post/custom-rkey',
          'cid': 'new-cid',
        });
        final repository = RepoRepositoryImpl(
          harness.sprk,
          logger: SparkLogger(),
        );
        final record = <String, dynamic>{
          r'$type': 'so.sprk.feed.post',
          'caption': {'text': 'Hello', 'facets': <dynamic>[]},
        };

        final result = await repository.createRecord(
          collection: 'so.sprk.feed.post',
          record: record,
          rkey: 'custom-rkey',
        );

        final request = harness.transport.singleRequest;
        expect(request.uri.path, '/xrpc/com.atproto.repo.createRecord');
        expect(request.jsonBody['repo'], 'did:plc:viewer');
        expect(request.jsonBody['collection'], 'so.sprk.feed.post');
        expect(request.jsonBody['rkey'], 'custom-rkey');
        expect(request.jsonBody['record'], record);
        expect(result.cid, 'new-cid');
      },
    );

    test('editRecordJson maps the target URI into putRecord input', () async {
      final harness = RepositoryHarness();
      harness.transport.enqueuePost({
        'uri': 'at://did:plc:alice/so.sprk.feed.post/post-1',
        'cid': 'edited-cid',
      });
      final repository = RepoRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );
      final uri = AtUri('at://did:plc:alice/so.sprk.feed.post/post-1');

      final result = await repository.editRecordJson(
        uri: uri,
        record: const {r'$type': 'so.sprk.feed.post', 'edited': true},
      );

      final body = harness.transport.singleRequest.jsonBody;
      expect(body['repo'], 'did:plc:alice');
      expect(body['collection'], 'so.sprk.feed.post');
      expect(body['rkey'], 'post-1');
      expect(body['record'], containsPair('edited', true));
      expect(result.cid, 'edited-cid');
    });

    test('listRecords forwards pagination defaults and maps records', () async {
      final harness = RepositoryHarness();
      harness.transport.enqueueGet({
        'cursor': 'next',
        'records': [
          {
            r'$type': 'com.atproto.repo.listRecords#record',
            'uri': 'at://did:plc:alice/app.bsky.feed.post/post-1',
            'cid': 'post-cid',
            'value': {
              r'$type': 'app.bsky.feed.post',
              'text': 'Hello',
              'facets': <dynamic>[],
            },
          },
        ],
      });
      final repository = RepoRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );

      final records = await repository.listRecords(
        repo: 'did:plc:alice',
        collection: 'app.bsky.feed.post',
      );

      final request = harness.transport.singleRequest;
      expect(request.uri.queryParameters['limit'], '50');
      expect(request.uri.queryParameters['reverse'], 'false');
      expect(records, hasLength(1));
      expect(records.single, isA<BskyPostRecord>());
    });

    test('deleteRecord can explicitly skip counterpart cleanup', () async {
      final harness = RepositoryHarness();
      harness.transport.enqueuePost(<String, dynamic>{});
      final repository = RepoRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );
      final uri = AtUri('at://did:plc:alice/so.sprk.feed.post/post-1');

      await repository.deleteRecord(uri: uri, skipBskyCrosspostCleanup: true);

      expect(harness.transport.requests, hasLength(1));
      final request = harness.transport.singleRequest;
      expect(request.uri.path, '/xrpc/com.atproto.repo.deleteRecord');
      expect(request.jsonBody['repo'], 'did:plc:alice');
      expect(request.jsonBody['collection'], 'so.sprk.feed.post');
      expect(request.jsonBody['rkey'], 'post-1');
    });
  });
}
