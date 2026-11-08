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
      expect(await service.onTokenRefresh.toList(), isEmpty);
      await service.updateBadge(1);
      await service.clearBadge();
      expect(initializationCalls, 1);
    });

    test(
      'concurrent callers share initialization and await readiness',
      () async {
        final ready = Completer<PushMessagingClient>();
        final service = PushNotificationService(
          initializeMessaging: () {
            initializationCalls++;
            return ready.future;
          },
          isBadgeSupported: () async => true,
          updateBadge: (count) async => badgeUpdates.add(count),
          logger: SparkLogger(name: 'PushNotificationServiceTest'),
        );
        messaging.permissionStatus = PushAuthorizationStatus.authorized;
        messaging.requestedStatus = PushAuthorizationStatus.authorized;
        messaging.token = 'token-ready';

        final initialization = service.initialize();
        expect(identical(service.initialize(), initialization), isTrue);
        final permission = service.hasPermission();
        final requested = service.requestPermissionAndGetToken();
        final badge = service.updateBadge(3);
        expect(messaging.permissionStatusCalls, 0);
        expect(messaging.getTokenCalls, 0);
        expect(badgeUpdates, isEmpty);

        ready.complete(messaging);
        await initialization;
        expect(await permission, isTrue);
        expect(await requested, 'token-ready');
        await badge;
        expect(badgeUpdates, [3]);
        expect(initializationCalls, 1);
      },
    );

    test(
      'late cold-start message waits for initialization then routes once',
      () async {
        messaging.initialMessageCompleter = Completer<RemoteMessage?>();
        final service = createService();
        final initialized = service.initialize();
        final mainPageReady = initialized.then((_) {
          service.setNavigationReady(true);
        });
        await Future<void>.delayed(Duration.zero);
        expect(pushedRoutes, isEmpty);

        messaging.initialMessageCompleter!.complete(
          const RemoteMessage(
            data: {
              'reason': 'follow',
              'uri': 'at://did:plc:alice/app.bsky.graph.follow/123',
            },
          ),
        );
        await mainPageReady;
        service.setNavigationReady(true);
        await service.initialize();
        service.setNavigationReady(true);

        expect(pushedRoutes, hasLength(1));
        expect(service.hasPendingNotification, isFalse);
        expect(initializationCalls, 1);
      },
    );

    test(
      'notification taps wait for main page readiness and pause on exit',
      () async {
        final service = createService();
        await service.initialize();
        const message = RemoteMessage(
          data: {
            'reason': 'follow',
            'uri': 'at://did:plc:alice/app.bsky.graph.follow/123',
          },
        );

        messaging.messageOpenedController.add(message);
        expect(pushedRoutes, isEmpty);
        expect(service.hasPendingNotification, isTrue);
        service.setNavigationReady(true);
        expect(pushedRoutes, hasLength(1));

        service.setNavigationReady(false);
        messaging.messageOpenedController.add(message);
        expect(pushedRoutes, hasLength(1));
        service.setNavigationReady(true);
        expect(pushedRoutes, hasLength(2));
      },
    );

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

      service.setNavigationReady(true);

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
        service.setNavigationReady(true);
        expect(service.hasPendingNotification, isTrue);
        expect(pushedRoutes, isEmpty);

        routerAvailable = true;
        service.setNavigationReady(true);

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

    test('initial message failure does not disable token operations', () async {
      messaging.initialMessageError = StateError('initial message failed');
      messaging.token = 'token-ready';
      final service = createService();

      await service.initialize();

      expect(await service.getToken(), 'token-ready');
      expect(service.hasPendingNotification, isFalse);
    });

    test(
      'badge support failure does not prevent notification navigation',
      () async {
        messaging.initialMessage = const RemoteMessage(
          data: {
            'reason': 'follow',
            'uri': 'at://did:plc:alice/app.bsky.graph.follow/123',
          },
        );
        final service = PushNotificationService(
          initializeMessaging: () async => messaging,
          isBadgeSupported: () async => throw StateError('badge unavailable'),
          updateBadge: (count) async => badgeUpdates.add(count),
          isRouterAvailable: () => true,
          pushRoute: pushedRoutes.add,
          logger: SparkLogger(name: 'PushNotificationServiceTest'),
        );

        await service.initialize();
        service.setNavigationReady(true);
        await service.clearBadge();

        expect(pushedRoutes, hasLength(1));
        expect(badgeUpdates, isEmpty);
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
  Completer<RemoteMessage?>? initialMessageCompleter;
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
    final completer = initialMessageCompleter;
    if (completer != null) return completer.future;
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
