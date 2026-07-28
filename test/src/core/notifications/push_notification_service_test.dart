import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/notifications/push_notification_service.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

void main() {
  group('PushNotificationService', () {
    late _FakePushMessagingClient messaging;
    late List<PageRouteInfo> pushedRoutes;
    late List<int> badgeUpdates;
    late bool routerAvailable;
    late bool badgeSupported;
    late Object? initializationError;
    late int initializationCalls;

    PushNotificationService createService() {
      return PushNotificationService(
        initializeMessaging: () async {
          initializationCalls += 1;
          final error = initializationError;
          if (error != null) throw error;
          return messaging;
        },
        isBadgeSupported: () async => badgeSupported,
        updateBadge: (count) async => badgeUpdates.add(count),
        isRouterAvailable: () => routerAvailable,
        pushRoute: pushedRoutes.add,
        logger: SparkLogger(name: 'PushNotificationServiceTest'),
      );
    }

    setUp(() {
      messaging = _FakePushMessagingClient();
      addTearDown(messaging.dispose);
      pushedRoutes = [];
      badgeUpdates = [];
      routerAvailable = true;
      badgeSupported = false;
      initializationError = null;
      initializationCalls = 0;
    });

    test('initialize failure leaves platform operations guarded', () async {
      initializationError = StateError('Firebase unavailable');
      final service = createService();

      await service.initialize();

      expect(initializationCalls, 1);
      expect(await service.hasPermission(), isFalse);
      expect(await service.requestPermission(), isFalse);
      expect(await service.getToken(), isNull);
      expect(messaging.permissionStatusCalls, 0);
      expect(messaging.requestPermissionCalls, 0);
      expect(messaging.getTokenCalls, 0);
    });

    test('initialize queues and later routes a cold-start message', () async {
      messaging.initialMessage = const RemoteMessage(
        data: {
          'reason': 'follow',
          'uri': 'at://did:plc:alice/app.bsky.graph.follow/123',
        },
      );
      final service = createService();

      await service.initialize();

      expect(messaging.tokenRefreshController.hasListener, isTrue);
      expect(messaging.messageOpenedController.hasListener, isTrue);
      expect(messaging.foregroundMessageController.hasListener, isTrue);
      expect(service.hasPendingNotification, isTrue);
      expect(pushedRoutes, isEmpty);

      service.processPendingNotification();

      expect(service.hasPendingNotification, isFalse);
      final route = pushedRoutes.single;
      expect(route, isA<ProfileRoute>());
      expect((route.args as ProfileRouteArgs).did, 'did:plc:alice');
    });

    test(
      'pending message remains queued until a router is available',
      () async {
        routerAvailable = false;
        final service = createService();
        await service.initialize();

        messaging.messageOpenedController.add(
          const RemoteMessage(
            data: {
              'reason': 'reply',
              'uri': 'at://did:plc:reply/so.sprk.feed.reply/123',
              'subject': 'at://did:plc:root/so.sprk.feed.post/456',
            },
          ),
        );

        expect(service.hasPendingNotification, isTrue);
        service.processPendingNotification();
        expect(service.hasPendingNotification, isTrue);
        expect(pushedRoutes, isEmpty);

        routerAvailable = true;
        service.processPendingNotification();

        expect(service.hasPendingNotification, isFalse);
        final route = pushedRoutes.single;
        expect(route, isA<StandalonePostRoute>());
        final args = route.args as StandalonePostRouteArgs;
        expect(args.postUri, 'at://did:plc:root/so.sprk.feed.post/456');
        expect(
          args.highlightedReplyUri,
          'at://did:plc:reply/so.sprk.feed.reply/123',
        );
      },
    );

    test('permission checks map statuses and recover from errors', () async {
      final service = createService();
      await service.initialize();

      messaging.permissionStatus = PushAuthorizationStatus.authorized;
      expect(await service.hasPermission(), isTrue);
      messaging.permissionStatus = PushAuthorizationStatus.provisional;
      expect(await service.hasPermission(), isTrue);
      messaging.permissionStatus = PushAuthorizationStatus.denied;
      expect(await service.hasPermission(), isFalse);
      messaging.permissionStatusError = StateError('settings failed');
      expect(await service.hasPermission(), isFalse);

      messaging.requestedStatus = PushAuthorizationStatus.provisional;
      expect(await service.requestPermission(), isTrue);
      messaging.requestedStatus = PushAuthorizationStatus.denied;
      expect(await service.requestPermission(), isFalse);
      messaging.requestPermissionError = StateError('prompt failed');
      expect(await service.requestPermission(), isFalse);
    });

    test('permission flow only fetches a token after authorization', () async {
      final service = createService();
      await service.initialize();

      messaging.permissionStatus = PushAuthorizationStatus.denied;
      messaging.requestedStatus = PushAuthorizationStatus.denied;
      expect(await service.requestPermissionAndGetToken(), isNull);
      expect(messaging.getTokenCalls, 0);

      messaging.requestedStatus = PushAuthorizationStatus.authorized;
      messaging.token = 'token-1';
      expect(await service.requestPermissionAndGetToken(), 'token-1');
      expect(messaging.getTokenCalls, 1);
    });

    test(
      'getToken caches values and token refresh replaces the cache',
      () async {
        messaging.token = 'token-1';
        final service = createService();
        await service.initialize();

        expect(await service.getToken(), 'token-1');
        expect(await service.getToken(), 'token-1');
        expect(messaging.getTokenCalls, 1);

        messaging.tokenRefreshController.add('token-2');

        expect(await service.getToken(), 'token-2');
        expect(messaging.getTokenCalls, 1);
      },
    );

    test('getToken returns null when the messaging client fails', () async {
      messaging.getTokenError = StateError('token failed');
      final service = createService();
      await service.initialize();

      expect(await service.getToken(), isNull);
    });

    test('badge operations are guarded and errors do not escape', () async {
      final unsupportedService = createService();
      await unsupportedService.initialize();

      await unsupportedService.updateBadge(4);
      await unsupportedService.clearBadge();
      expect(badgeUpdates, isEmpty);

      badgeSupported = true;
      final supportedService = createService();
      await supportedService.initialize();

      await supportedService.updateBadge(4);
      await supportedService.clearBadge();
      expect(badgeUpdates, [4, 0]);

      final failingService = PushNotificationService(
        initializeMessaging: () async => messaging,
        isBadgeSupported: () async => true,
        updateBadge: (_) async => throw StateError('badge failed'),
        logger: SparkLogger(name: 'PushNotificationServiceTest'),
      );
      await failingService.initialize();

      await expectLater(failingService.updateBadge(1), completes);
      await expectLater(failingService.clearBadge(), completes);
    });
  });
}

class _FakePushMessagingClient implements PushMessagingClient {
  final StreamController<String> tokenRefreshController =
      StreamController<String>.broadcast(sync: true);
  final StreamController<RemoteMessage> messageOpenedController =
      StreamController<RemoteMessage>.broadcast(sync: true);
  final StreamController<RemoteMessage> foregroundMessageController =
      StreamController<RemoteMessage>.broadcast(sync: true);

  RemoteMessage? initialMessage;
  Object? initialMessageError;
  PushAuthorizationStatus permissionStatus = PushAuthorizationStatus.denied;
  Object? permissionStatusError;
  PushAuthorizationStatus requestedStatus = PushAuthorizationStatus.denied;
  Object? requestPermissionError;
  String? token;
  Object? getTokenError;
  int permissionStatusCalls = 0;
  int requestPermissionCalls = 0;
  int getTokenCalls = 0;

  @override
  Stream<RemoteMessage> get onMessage => foregroundMessageController.stream;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      messageOpenedController.stream;

  @override
  Stream<String> get onTokenRefresh => tokenRefreshController.stream;

  @override
  Future<RemoteMessage?> getInitialMessage() async {
    final error = initialMessageError;
    if (error != null) throw error;
    return initialMessage;
  }

  @override
  Future<PushAuthorizationStatus> getPermissionStatus() async {
    permissionStatusCalls += 1;
    final error = permissionStatusError;
    if (error != null) throw error;
    return permissionStatus;
  }

  @override
  Future<PushAuthorizationStatus> requestPermission() async {
    requestPermissionCalls += 1;
    final error = requestPermissionError;
    if (error != null) throw error;
    return requestedStatus;
  }

  @override
  Future<String?> getToken() async {
    getTokenCalls += 1;
    final error = getTokenError;
    if (error != null) throw error;
    return token;
  }

  Future<void> dispose() async {
    await tokenRefreshController.close();
    await messageOpenedController.close();
    await foregroundMessageController.close();
  }
}
