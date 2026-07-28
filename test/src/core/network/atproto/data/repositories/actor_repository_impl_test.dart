import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository_impl.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

import 'repository_test_support.dart';

void main() {
  group('ActorRepositoryImpl', () {
    test('getProfile routes the actor and Spark proxy header', () async {
      final harness = RepositoryHarness();
      harness.transport.enqueueGet(_detailedProfile('did:plc:alice'));
      final repository = ActorRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );

      final profile = await repository.getProfile('did:plc:alice');

      final request = harness.transport.singleRequest;
      expect(request.method, 'GET');
      expect(request.uri.path, '/xrpc/so.sprk.actor.getProfile');
      expect(request.uri.queryParameters['actor'], 'did:plc:alice');
      expect(
        request.headers['atproto-proxy'],
        'did:web:sprk.test#sprk_appview',
      );
      expect(profile.did, 'did:plc:alice');
    });

    test('getProfile rejects unauthenticated requests before transport', () {
      final harness = RepositoryHarness(authenticated: false);
      final repository = ActorRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );

      expect(
        repository.getProfile('did:plc:alice'),
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

    test(
      'getProfiles short-circuits an empty batch without auth or I/O',
      () async {
        final harness = RepositoryHarness(
          authenticated: false,
          atprotoInitialized: false,
        );
        final repository = ActorRepositoryImpl(
          harness.sprk,
          logger: SparkLogger(),
        );

        expect(await repository.getProfiles(const []), isEmpty);
        expect(harness.transport.requests, isEmpty);
      },
    );

    test('typeahead clamps the limit and uses the Spark proxy', () async {
      final harness = RepositoryHarness();
      harness.transport.enqueueGet({
        'actors': [
          {'did': 'did:plc:alice', 'handle': 'alice.test'},
        ],
      });
      final repository = ActorRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );

      final result = await repository.searchActorsTypeahead('ali', limit: 999);

      final request = harness.transport.singleRequest;
      expect(request.uri.path, '/xrpc/so.sprk.actor.searchActorsTypeahead');
      expect(request.uri.queryParameters, containsPair('q', 'ali'));
      expect(request.uri.queryParameters, containsPair('limit', '100'));
      expect(
        request.headers['atproto-proxy'],
        'did:web:sprk.test#sprk_appview',
      );
      expect(result.actors.single.did, 'did:plc:alice');
    });

    test(
      'updateProfile writes the self record to the authenticated repo',
      () async {
        final harness = RepositoryHarness();
        harness.transport.enqueuePost({
          'uri': 'at://did:plc:viewer/so.sprk.actor.profile/self',
          'cid': 'profile-cid',
        });
        final repository = ActorRepositoryImpl(
          harness.sprk,
          logger: SparkLogger(),
        );

        await repository.updateProfile(
          displayName: 'Alice',
          description: 'Hello',
        );

        final request = harness.transport.singleRequest;
        expect(request.uri.path, '/xrpc/com.atproto.repo.putRecord');
        expect(request.jsonBody['repo'], 'did:plc:viewer');
        expect(request.jsonBody['collection'], 'so.sprk.actor.profile');
        expect(request.jsonBody['rkey'], 'self');
        expect(
          request.jsonBody['record'],
          containsPair(r'$type', 'so.sprk.actor.profile'),
        );
        expect(
          request.jsonBody['record'],
          containsPair('displayName', 'Alice'),
        );
      },
    );
  });
}

Map<String, dynamic> _detailedProfile(String did) => {
  r'$type': 'so.sprk.actor.defs#profileViewDetailed',
  'did': did,
  'handle': 'alice.test',
};
