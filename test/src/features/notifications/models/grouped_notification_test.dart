import 'package:poptart/poptart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';
import 'package:spark/src/core/network/atproto/data/models/notification_models.dart';
import 'package:spark/src/features/notifications/models/grouped_notification.dart';

Notification _makeNotification({
  required String did,
  required String reason,
  bool isRead = false,
  DateTime? indexedAt,
  AtUri? reasonSubject,
  AtUri? following,
}) {
  return Notification(
    uri: reasonSubject ?? AtUri('at://did:plc:test/so.sprk.feed.post/test'),
    cid: 'test-cid',
    author: ProfileView(
      did: did,
      handle: '$did.handle',
      viewer: ViewerState(following: following),
    ),
    reason: NotificationReason.valueOf(reason)!,
    record: {},
    isRead: isRead,
    indexedAt: indexedAt ?? DateTime(2026, 1, 1),
    reasonSubject: reasonSubject,
  );
}

void main() {
  group('groupNotifications', () {
    test('returns empty list for empty input', () {
      expect(groupNotifications([]), isEmpty);
    });

    test('groups follows together', () {
      final results = groupNotifications([
        _makeNotification(
          did: 'did:plc:alice',
          reason: 'follow',
          indexedAt: DateTime(2026, 1, 3),
        ),
        _makeNotification(
          did: 'did:plc:bob',
          reason: 'follow',
          indexedAt: DateTime(2026, 1, 2),
        ),
      ]);

      expect(results, hasLength(1));
      expect(results.first.reason, 'follow');
      expect(results.first.actorCount, 2);
      expect(results.first.primaryNotification.author.did, 'did:plc:alice');
    });

    test('separates follow-backs from regular follows', () {
      final results = groupNotifications([
        _makeNotification(
          did: 'did:plc:alice',
          reason: 'follow',
          indexedAt: DateTime(2026, 1, 3),
        ),
        _makeNotification(
          did: 'did:plc:bob',
          reason: 'follow',
          following: AtUri('at://did:plc:bob/app.bsky.graph.follow/xyz'),
          indexedAt: DateTime(2026, 1, 2),
        ),
      ]);

      expect(results, hasLength(2));
    });

    test('groups likes by reasonSubject', () {
      final subject = AtUri('at://did:plc:author/so.sprk.feed.post/123');
      final results = groupNotifications([
        _makeNotification(
          did: 'did:plc:alice',
          reason: 'like',
          reasonSubject: subject,
          indexedAt: DateTime(2026, 1, 3),
        ),
        _makeNotification(
          did: 'did:plc:bob',
          reason: 'like',
          reasonSubject: subject,
          indexedAt: DateTime(2026, 1, 2),
        ),
      ]);

      expect(results, hasLength(1));
      expect(results.first.actorCount, 2);
    });

    test('separates likes on different posts', () {
      final subject1 = AtUri('at://did:plc:author/so.sprk.feed.post/1');
      final subject2 = AtUri('at://did:plc:author/so.sprk.feed.post/2');
      final results = groupNotifications([
        _makeNotification(
          did: 'did:plc:alice',
          reason: 'like',
          reasonSubject: subject1,
          indexedAt: DateTime(2026, 1, 3),
        ),
        _makeNotification(
          did: 'did:plc:bob',
          reason: 'like',
          reasonSubject: subject2,
          indexedAt: DateTime(2026, 1, 2),
        ),
      ]);

      expect(results, hasLength(2));
    });

    test('does not group likes without reasonSubject', () {
      final results = groupNotifications([
        _makeNotification(did: 'did:plc:alice', reason: 'like'),
        _makeNotification(did: 'did:plc:bob', reason: 'like'),
      ]);

      expect(results, hasLength(2));
    });

    test('groups reposts by reasonSubject', () {
      final subject = AtUri('at://did:plc:author/so.sprk.feed.post/123');
      final results = groupNotifications([
        _makeNotification(
          did: 'did:plc:alice',
          reason: 'repost',
          reasonSubject: subject,
        ),
        _makeNotification(
          did: 'did:plc:bob',
          reason: 'repost',
          reasonSubject: subject,
        ),
      ]);

      expect(results, hasLength(1));
      expect(results.first.actorCount, 2);
    });

    test('groups likes via repost by reasonSubject', () {
      final subject = AtUri('at://did:plc:author/so.sprk.feed.repost/123');
      final results = groupNotifications([
        _makeNotification(
          did: 'did:plc:alice',
          reason: 'like-via-repost',
          reasonSubject: subject,
        ),
        _makeNotification(
          did: 'did:plc:bob',
          reason: 'like-via-repost',
          reasonSubject: subject,
        ),
      ]);

      expect(results, hasLength(1));
      expect(results.first.reason, 'like-via-repost');
      expect(results.first.actorCount, 2);
    });

    test('groups reposts via repost by reasonSubject', () {
      final subject = AtUri('at://did:plc:author/so.sprk.feed.repost/123');
      final results = groupNotifications([
        _makeNotification(
          did: 'did:plc:alice',
          reason: 'repost-via-repost',
          reasonSubject: subject,
        ),
        _makeNotification(
          did: 'did:plc:bob',
          reason: 'repost-via-repost',
          reasonSubject: subject,
        ),
      ]);

      expect(results, hasLength(1));
      expect(results.first.reason, 'repost-via-repost');
      expect(results.first.actorCount, 2);
    });

    test('does not merge different reaction reasons for the same subject', () {
      final subject = AtUri('at://did:plc:author/so.sprk.feed.repost/123');
      final results = groupNotifications([
        _makeNotification(
          did: 'did:plc:alice',
          reason: 'like-via-repost',
          reasonSubject: subject,
        ),
        _makeNotification(
          did: 'did:plc:bob',
          reason: 'repost-via-repost',
          reasonSubject: subject,
        ),
      ]);

      expect(results, hasLength(2));
      expect(
        results.map((result) => result.reason),
        containsAll(['like-via-repost', 'repost-via-repost']),
      );
    });

    test('does not group replies', () {
      final results = groupNotifications([
        _makeNotification(did: 'did:plc:alice', reason: 'reply'),
        _makeNotification(did: 'did:plc:bob', reason: 'reply'),
      ]);

      expect(results, hasLength(2));
    });

    test('does not group mentions', () {
      final results = groupNotifications([
        _makeNotification(did: 'did:plc:alice', reason: 'mention'),
        _makeNotification(did: 'did:plc:bob', reason: 'mention'),
      ]);

      expect(results, hasLength(2));
    });

    test('groups mixed types and sorts them by most recent notification', () {
      final subject = AtUri('at://did:plc:author/so.sprk.feed.post/123');
      final results = groupNotifications([
        _makeNotification(
          did: 'did:plc:bob',
          reason: 'like',
          reasonSubject: subject,
          indexedAt: DateTime(2026, 1, 1),
        ),
        _makeNotification(
          did: 'did:plc:alice',
          reason: 'follow',
          indexedAt: DateTime(2026, 1, 5),
        ),
        _makeNotification(
          did: 'did:plc:dave',
          reason: 'follow',
          indexedAt: DateTime(2026, 1, 4),
        ),
        _makeNotification(
          did: 'did:plc:carol',
          reason: 'reply',
          indexedAt: DateTime(2026, 1, 3),
        ),
      ]);

      expect(results.map((group) => group.reason), ['follow', 'reply', 'like']);
      expect(results.map((group) => group.actorCount), [2, 1, 1]);
      expect(results.map((group) => group.primaryNotification.author.did), [
        'did:plc:alice',
        'did:plc:carol',
        'did:plc:bob',
      ]);
    });
  });
}
