import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/atproto/data/repositories/labeler_repository_impl.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

import 'repository_test_support.dart';

void main() {
  group('LabelerRepositoryImpl', () {
    test(
      'getServices requests the basic view and returns the first service',
      () async {
        final harness = RepositoryHarness();
        harness.transport.enqueueGet({
          'views': [_basicLabeler],
        });
        final repository = LabelerRepositoryImpl(
          harness.sprk,
          logger: SparkLogger(),
        );

        final service = await repository.getServices([
          'did:plc:labeler-one',
          'did:plc:labeler-two',
        ]);

        final request = harness.transport.singleRequest;
        expect(request.uri.path, '/xrpc/so.sprk.labeler.getServices');
        expect(request.uri.queryParametersAll['dids'], [
          'did:plc:labeler-one',
          'did:plc:labeler-two',
        ]);
        expect(request.uri.queryParameters['detailed'], 'false');
        expect(
          request.headers['atproto-proxy'],
          'did:web:sprk.test#sprk_appview',
        );
        expect(
          request.headers['atproto-accept-labelers'],
          'did:web:mod.sprk.test',
        );
        expect(service.creator.did, 'did:plc:labeler-one');
      },
    );

    test('getServicesDetailed selects the detailed union variant', () async {
      final harness = RepositoryHarness();
      harness.transport.enqueueGet({
        'views': [_detailedLabeler],
      });
      final repository = LabelerRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );

      final service = await repository.getServicesDetailed([
        'did:plc:labeler-one',
      ]);

      final request = harness.transport.singleRequest;
      expect(request.uri.queryParameters['detailed'], 'true');
      expect(service.creator.did, 'did:plc:labeler-one');
      expect(service.policies.labelValues, isEmpty);
    });

    test(
      'resolveIdentifier resolves handles directly through the PDS',
      () async {
        final harness = RepositoryHarness(
          getResponse: const {'did': 'did:plc:resolved'},
        );
        final repository = LabelerRepositoryImpl(
          harness.sprk,
          logger: SparkLogger(),
        );

        final did = await repository.resolveIdentifier('@labeler.test');

        final request = harness.transport.singleRequest;
        expect(request.uri.path, '/xrpc/com.atproto.identity.resolveHandle');
        expect(request.uri.queryParameters['handle'], 'labeler.test');
        expect(request.headers, isNot(contains('atproto-proxy')));
        expect(request.headers, isNot(contains('atproto-accept-labelers')));
        expect(did, 'did:plc:resolved');
      },
    );

    test('resolveIdentifier normalizes DIDs without transport', () async {
      final harness = RepositoryHarness();
      final repository = LabelerRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );

      expect(
        await repository.resolveIdentifier(' did:plc:labeler#service '),
        'did:plc:labeler',
      );
      expect(harness.transport.requests, isEmpty);
    });

    test('validateService rejects a mismatched returned service', () {
      final harness = RepositoryHarness();
      harness.transport.enqueueGet({
        'views': [_detailedLabeler],
      });
      final repository = LabelerRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );

      expect(
        repository.validateService('did:plc:different'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('does not match'),
          ),
        ),
      );
    });

    test('getServices rejects an empty server result', () {
      final harness = RepositoryHarness();
      harness.transport.enqueueGet({'views': <dynamic>[]});
      final repository = LabelerRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );

      expect(
        repository.getServices(['did:plc:labeler-one']),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('No labeler services'),
          ),
        ),
      );
    });

    test('detailed lookup rejects a basic-only response', () {
      final harness = RepositoryHarness();
      harness.transport.enqueueGet({
        'views': [_basicLabeler],
      });
      final repository = LabelerRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );

      expect(
        repository.getServicesDetailed(['did:plc:labeler-one']),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('No detailed labeler service'),
          ),
        ),
      );
    });

    test('lookups enforce authentication before transport', () {
      final harness = RepositoryHarness(authenticated: false);
      final repository = LabelerRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );

      expect(
        repository.getServices(['did:plc:labeler-one']),
        throwsA(isA<Exception>()),
      );
      expect(harness.transport.requests, isEmpty);
    });
  });
}

const _creator = <String, dynamic>{
  r'$type': 'so.sprk.actor.defs#profileView',
  'did': 'did:plc:labeler-one',
  'handle': 'labeler.test',
};

const _basicLabeler = <String, dynamic>{
  r'$type': 'so.sprk.labeler.defs#labelerView',
  'uri': 'at://did:plc:labeler-one/so.sprk.labeler.service/self',
  'cid': 'labeler-cid',
  'creator': _creator,
  'indexedAt': '2026-07-22T12:00:00.000Z',
};

const _detailedLabeler = <String, dynamic>{
  r'$type': 'so.sprk.labeler.defs#labelerViewDetailed',
  'uri': 'at://did:plc:labeler-one/so.sprk.labeler.service/self',
  'cid': 'labeler-cid',
  'creator': _creator,
  'policies': {
    r'$type': 'so.sprk.labeler.defs#labelerPolicies',
    'labelValues': <dynamic>[],
  },
  'indexedAt': '2026-07-22T12:00:00.000Z',
};
