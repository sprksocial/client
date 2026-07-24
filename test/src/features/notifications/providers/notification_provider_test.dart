import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/notification_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/notification_repository.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/notifications/providers/notification_provider.dart';
import 'package:spark/src/features/notifications/providers/notification_state.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

void main() {
  group('NotificationNotifier', () {
    late _FakeNotificationRepository repository;
    late int unreadRefreshCalls;

    ProviderContainer createContainer({bool? priority, List<String>? reasons}) {
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(repository),
          notificationLoggerProvider.overrideWithValue(
            SparkLogger(name: 'NotificationNotifierTest'),
          ),
          notificationUnreadCountRefresherProvider.overrideWithValue(() async {
            unreadRefreshCalls += 1;
          }),
        ],
      );
      final subscription = container.listen(
        notificationProvider(priority: priority, reasons: reasons),
        (previous, next) {},
      );
      addTearDown(subscription.close);
      addTearDown(container.dispose);
      return container;
    }

    Future<NotificationState> waitForState(
      ProviderContainer container,
      bool Function(NotificationState state) predicate, {
      bool? priority,
      List<String>? reasons,
    }) async {
      final completer = Completer<NotificationState>();
      final subscription = container.listen(
        notificationProvider(priority: priority, reasons: reasons),
        (previous, next) {
          if (!completer.isCompleted && predicate(next)) {
            completer.complete(next);
          }
        },
        fireImmediately: true,
      );
      final state = await completer.future;
      subscription.close();
      return state;
    }

    setUp(() {
      repository = _FakeNotificationRepository();
      unreadRefreshCalls = 0;
    });

    test('initial load forwards filters and stores notifications', () async {
      const reasons = ['like', 'reply'];
      final first = _notification('first', day: 3);
      repository.listResponses.add(
        () async => ListNotificationsResponse(
          notifications: [first],
          cursor: 'next-page',
        ),
      );

      final container = createContainer(priority: true, reasons: reasons);
      final state = await waitForState(
        container,
        (state) => !state.isLoading,
        priority: true,
        reasons: reasons,
      );

      expect(state.notifications, [first]);
      expect(state.cursor, 'next-page');
      expect(state.hasError, isFalse);
      expect(repository.listCalls.single.cursor, isNull);
      expect(repository.listCalls.single.priority, isTrue);
      expect(repository.listCalls.single.reasons, reasons);
    });

    test('initial load exposes repository errors', () async {
      repository.listResponses.add(
        () async => throw StateError('initial load failed'),
      );

      final container = createContainer();
      final state = await waitForState(container, (state) => !state.isLoading);

      expect(state.notifications, isEmpty);
      expect(state.hasError, isTrue);
      expect(state.errorMessage, contains('initial load failed'));
    });

    test('loadMore forwards cursor and appends the next page', () async {
      final first = _notification('first', day: 3);
      final second = _notification('second', day: 2);
      repository.listResponses
        ..add(
          () async => ListNotificationsResponse(
            notifications: [first],
            cursor: 'next-page',
          ),
        )
        ..add(() async => ListNotificationsResponse(notifications: [second]));
      final container = createContainer(priority: false);
      await waitForState(
        container,
        (state) => !state.isLoading,
        priority: false,
      );

      await container
          .read(notificationProvider(priority: false).notifier)
          .loadMore(priority: false);

      final state = container.read(notificationProvider(priority: false));
      expect(state.notifications, [first, second]);
      expect(state.hasMore, isFalse);
      expect(state.isLoadingMore, isFalse);
      expect(repository.listCalls.last.cursor, 'next-page');
      expect(repository.listCalls.last.priority, isFalse);
    });

    test('loadMore preserves existing items and exposes errors', () async {
      final first = _notification('first', day: 3);
      repository.listResponses
        ..add(
          () async => ListNotificationsResponse(
            notifications: [first],
            cursor: 'next-page',
          ),
        )
        ..add(() async => throw StateError('pagination failed'));
      final container = createContainer();
      await waitForState(container, (state) => !state.isLoading);

      await container.read(notificationProvider().notifier).loadMore();

      final state = container.read(notificationProvider());
      expect(state.notifications, [first]);
      expect(state.isLoadingMore, isFalse);
      expect(state.hasError, isTrue);
      expect(state.errorMessage, contains('pagination failed'));
    });

    test('refresh preserves items while loading and replaces them', () async {
      const reasons = ['mention'];
      final oldNotification = _notification('old', day: 2);
      final newNotification = _notification('new', day: 4);
      final refreshResponse = Completer<ListNotificationsResponse>();
      repository.listResponses
        ..add(
          () async => ListNotificationsResponse(
            notifications: [oldNotification],
            cursor: 'old-cursor',
          ),
        )
        ..add(() => refreshResponse.future);
      final container = createContainer(priority: true, reasons: reasons);
      await waitForState(
        container,
        (state) => !state.isLoading,
        priority: true,
        reasons: reasons,
      );

      final refresh = container
          .read(notificationProvider(priority: true, reasons: reasons).notifier)
          .refresh(priority: true, reasons: reasons);

      final refreshingState = container.read(
        notificationProvider(priority: true, reasons: reasons),
      );
      expect(refreshingState.notifications, [oldNotification]);
      expect(refreshingState.isRefreshing, isTrue);
      expect(refreshingState.isLoading, isFalse);

      refreshResponse.complete(
        ListNotificationsResponse(notifications: [newNotification]),
      );
      await refresh;

      final refreshedState = container.read(
        notificationProvider(priority: true, reasons: reasons),
      );
      expect(refreshedState.notifications, [newNotification]);
      expect(refreshedState.isRefreshing, isFalse);
      expect(repository.listCalls.last.priority, isTrue);
      expect(repository.listCalls.last.reasons, reasons);
    });

    test(
      'seen operations update the server and refresh unread count',
      () async {
        final newest = _notification('newest', day: 4);
        final unread = _notification('unread', day: 3);
        final alreadyRead = _notification('read', day: 2, isRead: true);
        repository.listResponses.add(
          () async => ListNotificationsResponse(
            notifications: [newest, unread, alreadyRead],
          ),
        );
        final container = createContainer();
        await waitForState(container, (state) => !state.isLoading);
        final notifier = container.read(notificationProvider().notifier);

        await notifier.markAsSeen();
        await notifier.markNotificationAsViewed(alreadyRead);
        await notifier.markNotificationAsViewed(unread);

        expect(repository.seenAt, [newest.indexedAt, unread.indexedAt]);
        expect(unreadRefreshCalls, 2);
      },
    );

    test('seen operations guard empty state and repository errors', () async {
      repository.listResponses.add(
        () async => const ListNotificationsResponse(notifications: []),
      );
      final container = createContainer();
      await waitForState(container, (state) => !state.isLoading);
      final notifier = container.read(notificationProvider().notifier);

      await notifier.markAsSeen();
      expect(repository.seenAt, isEmpty);

      repository.updateSeenError = StateError('seen failed');
      await notifier.markNotificationAsViewed(_notification('unread', day: 3));

      expect(unreadRefreshCalls, 0);
    });
  });
}

Notification _notification(String id, {required int day, bool isRead = false}) {
  return Notification(
    uri: AtUri('at://did:plc:test/so.sprk.feed.post/$id'),
    cid: 'cid-$id',
    author: ProfileView(did: 'did:plc:$id', handle: '$id.sprk.so'),
    reason: NotificationReason.valueOf('mention')!,
    record: const {},
    isRead: isRead,
    indexedAt: DateTime.utc(2026, 1, day),
  );
}

typedef _ListResponseFactory = Future<ListNotificationsResponse> Function();

class _FakeNotificationRepository implements NotificationRepository {
  final List<_ListCall> listCalls = [];
  final List<_ListResponseFactory> listResponses = [];
  final List<DateTime> seenAt = [];
  Object? updateSeenError;

  @override
  Future<ListNotificationsResponse> listNotifications({
    int limit = 50,
    String? cursor,
    bool? priority,
    List<String>? reasons,
  }) {
    listCalls.add(
      _ListCall(cursor: cursor, priority: priority, reasons: reasons),
    );
    return listResponses.removeAt(0)();
  }

  @override
  Future<void> updateSeen(DateTime seenAt) async {
    final error = updateSeenError;
    if (error != null) throw error;
    this.seenAt.add(seenAt);
  }

  @override
  Future<UnreadCountResponse> getUnreadCount({bool? priority}) {
    throw UnimplementedError();
  }

  @override
  Future<void> registerPush({
    required String token,
    required String platform,
    required String appId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> unregisterPush({
    required String token,
    required String platform,
    required String appId,
  }) {
    throw UnimplementedError();
  }
}

class _ListCall {
  const _ListCall({this.cursor, this.priority, this.reasons});

  final String? cursor;
  final bool? priority;
  final List<String>? reasons;
}
