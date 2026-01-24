import 'package:spark/src/core/network/atproto/data/models/notification_models.dart';

/// Interface for Notification-related API endpoints
abstract class NotificationRepository {
  /// List notifications for the requesting account
  ///
  /// [limit] The number of notifications to return (default 50, max 100)
  /// [cursor] Pagination cursor for the next set of results
  /// [priority] Whether to return only priority notifications
  /// [reasons] Optional list of notification reasons to filter by
  Future<ListNotificationsResponse> listNotifications({
    int limit = 50,
    String? cursor,
    bool? priority,
    List<String>? reasons,
  });

  /// Get the count of unread notifications
  ///
  /// [priority] Whether to count only priority notifications
  Future<UnreadCountResponse> getUnreadCount({bool? priority});

  /// Mark notifications as seen
  ///
  /// [seenAt] The timestamp to mark notifications as seen at
  Future<void> updateSeen(DateTime seenAt);
}
