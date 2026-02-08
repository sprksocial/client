import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/notification_models.dart'
    as models;
import 'package:spark/src/core/network/atproto/data/repositories/notification_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/notifications/providers/notification_state.dart';
import 'package:spark/src/features/notifications/providers/unread_count_provider.dart';

part 'notification_provider.g.dart';

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  late final NotificationRepository _notificationRepository;
  late final SparkLogger _logger;
  bool _isLoading = false;

  @override
  NotificationState build({
    bool? priority,
    List<String>? reasons,
  }) {
    _notificationRepository = GetIt.instance<SprkRepository>().notification;
    _logger = GetIt.instance<LogService>().getLogger('NotificationNotifier');

    // Schedule initial load after build completes
    Future.microtask(() {
      loadNotifications(priority: priority, reasons: reasons);
    });

    return const NotificationState(
      notifications: [],
      isLoading: true,
    );
  }

  /// Load initial notifications or refresh
  Future<void> loadNotifications({
    bool? priority,
    List<String>? reasons,
    bool refresh = false,
  }) async {
    if (_isLoading && !refresh) {
      return;
    }

    _isLoading = true;
    state = state.copyWith(
      isLoading: !refresh,
      isRefreshing: refresh,
      hasError: false,
      errorMessage: null,
    );

    try {
      final response = await _notificationRepository.listNotifications(
        priority: priority,
        reasons: reasons,
      );

      state = state.copyWith(
        notifications: response.notifications,
        cursor: response.cursor,
        isLoading: false,
        isRefreshing: false,
        hasError: false,
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Error loading notifications: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    } finally {
      _isLoading = false;
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMore({
    bool? priority,
    List<String>? reasons,
  }) async {
    if (_isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    _isLoading = true;
    state = state.copyWith(isLoadingMore: true);

    try {
      final response = await _notificationRepository.listNotifications(
        cursor: state.cursor,
        priority: priority,
        reasons: reasons,
      );

      state = state.copyWith(
        notifications: [...state.notifications, ...response.notifications],
        cursor: response.cursor,
        isLoadingMore: false,
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Error loading more notifications: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isLoadingMore: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    } finally {
      _isLoading = false;
    }
  }

  /// Mark notifications as seen
  Future<void> markAsSeen() async {
    if (state.notifications.isEmpty) {
      return;
    }

    try {
      // Use the most recent notification's indexedAt as seenAt
      final mostRecent = state.notifications.first;
      await _notificationRepository.updateSeen(mostRecent.indexedAt);
      // Refresh the unread count
      await ref.read(unreadCountProvider().notifier).refresh();
    } catch (e, stackTrace) {
      _logger.e(
        'Error marking notifications as seen: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Mark a specific notification as viewed (when it comes into viewport)
  /// This will update the seen timestamp on the server
  Future<void> markNotificationAsViewed(
    models.Notification notification,
  ) async {
    // Only mark unread notifications as viewed
    if (notification.isRead) {
      return;
    }

    try {
      // Use this notification's indexedAt as the seenAt timestamp
      await _notificationRepository.updateSeen(notification.indexedAt);
      // Refresh the unread count
      await ref.read(unreadCountProvider().notifier).refresh();
    } catch (e, stackTrace) {
      _logger.e(
        'Error marking notification as viewed: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Refresh notifications
  Future<void> refresh({
    bool? priority,
    List<String>? reasons,
  }) async {
    await loadNotifications(
      priority: priority,
      reasons: reasons,
      refresh: true,
    );
  }
}
