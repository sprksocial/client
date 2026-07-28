import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/pref_repository_impl.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

import 'repository_test_support.dart';

void main() {
  group('PrefRepositoryImpl', () {
    test(
      'getPreferences routes through Spark and decodes typed preferences',
      () async {
        final harness = RepositoryHarness();
        harness.transport.enqueueGet({
          'preferences': [_savedFeedsJson],
        });
        final repository = PrefRepositoryImpl(
          harness.sprk,
          logger: SparkLogger(),
        );

        final preferences = await repository.getPreferences();

        final request = harness.transport.singleRequest;
        expect(request.uri.path, '/xrpc/so.sprk.actor.getPreferences');
        expect(
          request.headers['atproto-proxy'],
          'did:web:sprk.test#sprk_appview',
        );
        expect(preferences.savedFeeds, hasLength(1));
        expect(preferences.savedFeeds!.single.id, 'timeline');
        expect(preferences.savedFeeds!.single.pinned, isTrue);
      },
    );

    test('getPreferences rejects unauthenticated requests without I/O', () {
      final harness = RepositoryHarness(authenticated: false);
      final repository = PrefRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );

      expect(repository.getPreferences(), throwsA(isA<Exception>()));
      expect(harness.transport.requests, isEmpty);
    });

    test('getPreferences propagates unsuccessful transport responses', () {
      final harness = RepositoryHarness();
      harness.transport.enqueueGet({
        'error': 'InternalServerError',
        'message': 'unavailable',
      }, statusCode: 500);
      final repository = PrefRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );

      expect(repository.getPreferences(), throwsA(isA<Exception>()));
    });

    test('putPreferences sends the complete typed preference list', () async {
      final harness = RepositoryHarness();
      harness.transport.enqueuePost(<String, dynamic>{});
      final repository = PrefRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
      );
      final preferences = preferencesFromJson({
        'preferences': [_savedFeedsJson],
      });

      await repository.putPreferences(preferences);

      final request = harness.transport.singleRequest;
      expect(request.uri.path, '/xrpc/so.sprk.actor.putPreferences');
      expect(
        request.headers['atproto-proxy'],
        'did:web:sprk.test#sprk_appview',
      );
      final sent = request.jsonBody['preferences'] as List<dynamic>;
      expect(sent, hasLength(1));
      expect(
        sent.single,
        containsPair(r'$type', 'so.sprk.actor.defs#savedFeedsPref'),
      );
      expect((sent.single as Map<String, dynamic>)['items'], hasLength(1));
    });
  });
}

const _savedFeedsJson = <String, dynamic>{
  r'$type': 'so.sprk.actor.defs#savedFeedsPref',
  'items': [
    {
      r'$type': 'so.sprk.actor.defs#savedFeed',
      'id': 'timeline',
      'type': 'timeline',
      'value': 'timeline',
      'pinned': true,
    },
  ],
};
