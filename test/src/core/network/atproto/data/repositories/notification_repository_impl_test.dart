import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/atproto/data/repositories/notification_repository_impl.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

import 'repository_test_support.dart';

void main() {
  group('NotificationRepositoryImpl', () {
    test('listNotifications forwards non-empty filters', () async {
      final harness = RepositoryHarness(
        getResponse: {'notifications': <dynamic>[], 'cursor': 'next'},
      );
      final repository = NotificationRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
        clearBadge: () async {},
      );

      final result = await repository.listNotifications(
        limit: 9,
        cursor: 'page',
        priority: true,
        reasons: const ['like', 'reply'],
      );

      expect(result.cursor, 'next');
      expect(harness.transport.singleRequest.uri.queryParametersAll, {
        'limit': ['9'],
        'cursor': ['page'],
        'priority': ['true'],
        'reasons': ['like', 'reply'],
      });
    });

    test('getUnreadCount maps count and optional priority', () async {
      final harness = RepositoryHarness(getResponse: const {'count': 12});
      final repository = NotificationRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
        clearBadge: () async {},
      );

      final result = await repository.getUnreadCount(priority: false);

      expect(result.count, 12);
      expect(harness.transport.singleRequest.uri.queryParameters, {
        'priority': 'false',
      });
    });

    test('omits empty list filters from the request', () async {
      final harness = RepositoryHarness(
        getResponse: const {'notifications': <dynamic>[]},
      );
      final repository = NotificationRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
        clearBadge: () async {},
      );

      await repository.listNotifications(cursor: '', reasons: const []);

      expect(harness.transport.singleRequest.uri.queryParameters, {
        'limit': '50',
      });
    });

    test('auth failures occur before notification transport', () async {
      final harness = RepositoryHarness(authenticated: false);
      final repository = NotificationRepositoryImpl(
        harness.sprk,
        logger: SparkLogger(),
        clearBadge: () async {},
      );

      await expectLater(
        repository.getUnreadCount(),
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
  });
}
