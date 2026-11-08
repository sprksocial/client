import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/di/service_locator.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/notifications/push_notification_service.dart';
import 'package:spark/src/core/storage/cache/download_manager_interface.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/core/utils/logging/logger_factory.dart';

import '../../../support/in_memory_storage.dart';

void main() {
  test('service registration does not wait for push initialization', () async {
    await sl.reset();
    LoggerFactory.clearDefaultOutputs();
    final messaging = Completer<PushMessagingClient>();
    var initializationCalls = 0;
    final pushService = PushNotificationService(
      initializeMessaging: () {
        initializationCalls++;
        return messaging.future;
      },
      isBadgeSupported: () async => false,
      logger: SparkLogger(name: 'StartupPushTest'),
    );
    addTearDown(() async {
      if (!messaging.isCompleted) {
        final initialization = pushService.initialize();
        messaging.completeError(StateError('Push unavailable'));
        await initialization;
      }
      await sl.reset();
      LoggerFactory.reset();
    });

    await initServiceLocator(
      preferencesStorage: InMemoryStorage(),
      secureStorage: InMemoryStorage(),
      initializeDownloadManager: () async => _FakeDownloadManager(),
      createPushNotifications: () => pushService,
    ).timeout(const Duration(seconds: 5));
    await sl<AuthRepository>().initializationComplete;

    expect(sl<PushNotificationService>(), same(pushService));
    expect(initializationCalls, 0);
    expect(messaging.isCompleted, isFalse);

    var initialized = false;
    final initialization = pushService.initialize().then((_) {
      initialized = true;
    });
    await Future<void>.value();
    expect(initializationCalls, 1);
    expect(initialized, isFalse);

    messaging.completeError(StateError('Push unavailable'));
    await initialization;
    expect(initialized, isTrue);
    expect(await pushService.hasPermission(), isFalse);
    expect(initializationCalls, 1);
  });
}

class _FakeDownloadManager implements DownloadManagerInterface {
  @override
  bool get poolFull => false;

  @override
  Future<void> dispose() async {}

  @override
  void setActiveFeed(Feed feed) {}

  @override
  void submitTask(DownloadTask task) {}
}
