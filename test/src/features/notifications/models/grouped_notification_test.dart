import 'package:atproto_core/atproto_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';
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
    author: ProfileViewBasic(
      did: did,
      handle: '$did.handle',
      viewer: ActorViewer(following: following),
    ),
    reason: reason,
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

    test('sorts groups by most recent notification', () {
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
          did: 'did:plc:carol',
          reason: 'reply',
          indexedAt: DateTime(2026, 1, 3),
        ),
      ]);

      expect(results.first.reason, 'follow');
    });

    test('handles mixed notification types', () {
      final likeSubject = AtUri('at://did:plc:author/so.sprk.feed.post/1');
      final results = groupNotifications([
        _makeNotification(
          did: 'did:plc:alice',
          reason: 'follow',
          indexedAt: DateTime(2026, 1, 5),
        ),
        _makeNotification(
          did: 'did:plc:bob',
          reason: 'follow',
          indexedAt: DateTime(2026, 1, 4),
        ),
        _makeNotification(
          did: 'did:plc:carol',
          reason: 'like',
          reasonSubject: likeSubject,
          indexedAt: DateTime(2026, 1, 3),
        ),
        _makeNotification(
          did: 'did:plc:dave',
          reason: 'reply',
          indexedAt: DateTime(2026, 1, 2),
        ),
      ]);

      expect(results, hasLength(3));
    });
  });
}
