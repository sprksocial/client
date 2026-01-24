import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/notification_models.dart';
import 'package:spark/src/features/notifications/models/grouped_notification.dart';

part 'notification_state.freezed.dart';

@freezed
abstract class NotificationState with _$NotificationState {
  const factory NotificationState({
    required List<Notification> notifications,
    String? cursor,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasError,
    String? errorMessage,
    @Default(false) bool isRefreshing,
  }) = _NotificationState;
  const NotificationState._();

  int get length => notifications.length;
  bool get hasMore => cursor != null && cursor!.isNotEmpty;
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Get notifications grouped by type and subject
  List<GroupedNotification> get groupedNotifications =>
      groupNotifications(notifications);

  /// Number of grouped notification items
  int get groupedLength => groupedNotifications.length;

  static const int fetchLimit =
      50; // number of notifications to fetch at a time
}
