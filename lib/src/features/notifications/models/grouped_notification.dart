import 'package:spark/src/core/network/atproto/data/models/notification_models.dart';

/// Represents group of similar notifications that should be displayed together.
/// For example: "X and 5 others liked your post"
class GroupedNotification {
  /// The primary notification (most recent in the group)
  final Notification primaryNotification;

  /// All notifications in this group (including the primary)
  final List<Notification> notifications;

  /// The reason for the notification (like, repost, follow, etc.)
  String get reason => primaryNotification.reason;

  /// The subject being acted upon (e.g., the post being liked)
  /// Null for follows
  String? get reasonSubject => primaryNotification.reasonSubject?.toString();

  /// Number of unique actors in this group
  int get actorCount => _uniqueActors.length;

  /// Whether this notification group has been read
  bool get isRead => notifications.every((n) => n.isRead);

  /// The most recent indexedAt in the group
  DateTime get indexedAt => primaryNotification.indexedAt;

  /// Unique actors in this group (deduplicated by DID)
  List<Notification> get _uniqueActors {
    final seen = <String>{};
    return notifications.where((n) {
      final did = n.author.did;
      if (seen.contains(did)) return false;
      seen.add(did);
      return true;
    }).toList();
  }

  /// Get unique authors for display (limited to first N)
  List<Notification> getUniqueAuthors({int limit = 5}) {
    return _uniqueActors.take(limit).toList();
  }

  /// Get the "others" count for display
  int get othersCount => actorCount > 1 ? actorCount - 1 : 0;

  const GroupedNotification({
    required this.primaryNotification,
    required this.notifications,
  });

  /// Create a single-notification group
  factory GroupedNotification.single(Notification notification) {
    return GroupedNotification(
      primaryNotification: notification,
      notifications: [notification],
    );
  }
}

/// Groups notifications by type and subject.
/// - Follows are grouped together (follow-backs are shown separately)
/// - Likes on the same post are grouped
/// - Reposts of the same post are grouped
/// - Replies and mentions are NOT grouped
List<GroupedNotification> groupNotifications(List<Notification> notifications) {
  if (notifications.isEmpty) return [];

  final result = <GroupedNotification>[];
  final followGroups = <String, List<Notification>>{};
  final likeGroups = <String, List<Notification>>{};
  final repostGroups = <String, List<Notification>>{};

  // First pass: collect all groupable notifications
  for (final notification in notifications) {
    switch (notification.reason) {
      case 'follow':
        // Check if this is a follow-back (viewer follows the author)
        final isFollowBack = notification.author.viewer?.following != null;
        if (isFollowBack) {
          // Follow-backs are shown individually, not grouped
          result.add(GroupedNotification.single(notification));
        } else {
          // Regular follows are grouped together
          followGroups.putIfAbsent('follows', () => []).add(notification);
        }
      case 'like':
        // Group likes by reasonSubject (the post/reply being liked)
        if (notification.reasonSubject != null) {
          final key = notification.reasonSubject.toString();
          likeGroups.putIfAbsent(key, () => []).add(notification);
        } else {
          // No subject, don't group
          result.add(GroupedNotification.single(notification));
        }
      case 'repost':
        // Group reposts by reasonSubject
        if (notification.reasonSubject != null) {
          final key = notification.reasonSubject.toString();
          repostGroups.putIfAbsent(key, () => []).add(notification);
        } else {
          result.add(GroupedNotification.single(notification));
        }
      default:
        // reply, mention, etc. - don't group
        result.add(GroupedNotification.single(notification));
    }
  }

  // Second pass: create grouped notifications & interleave them chronologically
  final allGroups = <GroupedNotification>[...result];

  // Add follow groups
  if (followGroups['follows']?.isNotEmpty ?? false) {
    final follows = followGroups['follows']!
      // Sort by most recent first
      ..sort((a, b) => b.indexedAt.compareTo(a.indexedAt));
    allGroups.add(
      GroupedNotification(
        primaryNotification: follows.first,
        notifications: follows,
      ),
    );
  }

  // Add like groups
  for (final entry in likeGroups.entries) {
    final likes = entry.value
      ..sort((a, b) => b.indexedAt.compareTo(a.indexedAt));
    allGroups.add(
      GroupedNotification(
        primaryNotification: likes.first,
        notifications: likes,
      ),
    );
  }

  // Add repost groups
  for (final entry in repostGroups.entries) {
    final reposts = entry.value
      ..sort((a, b) => b.indexedAt.compareTo(a.indexedAt));
    allGroups.add(
      GroupedNotification(
        primaryNotification: reposts.first,
        notifications: reposts,
      ),
    );
  }

  // Sort all groups by most recent notification
  allGroups.sort((a, b) => b.indexedAt.compareTo(a.indexedAt));

  return allGroups;
}
