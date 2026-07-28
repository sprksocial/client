import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/notifications/notification_navigation.dart';

void main() {
  group('notificationRecordUri', () {
    test('uses canonical uri', () {
      expect(
        notificationRecordUri({
          'uri': 'at://did:plc:reply/so.sprk.feed.reply/123',
          'recordUri': 'at://did:plc:root/so.sprk.feed.post/456',
        }),
        'at://did:plc:reply/so.sprk.feed.reply/123',
      );
    });

    test('does not read legacy recordUri', () {
      expect(
        notificationRecordUri({
          'recordUri': 'at://did:plc:reply/so.sprk.feed.reply/123',
        }),
        isNull,
      );
    });

    test('ignores blank and non-string payload values', () {
      expect(notificationRecordUri({'uri': '', 'recordUri': 123}), isNull);
    });
  });

  group('notificationRecordAuthorDid', () {
    test('extracts the author did from a push uri', () {
      expect(
        notificationRecordAuthorDid(
          'at://did:plc:author/app.bsky.graph.follow/123',
        ),
        'did:plc:author',
      );
    });
  });

  group('replyNotificationTarget', () {
    test('uses reasonSubject as the displayed post or parent thread', () {
      final target = replyNotificationTarget(
        replyUri: 'at://did:plc:reply/so.sprk.feed.reply/123',
        reasonSubject: 'at://did:plc:root/so.sprk.feed.post/456',
      );

      expect(target.postUri, 'at://did:plc:root/so.sprk.feed.post/456');
      expect(
        target.highlightedReplyUri,
        'at://did:plc:reply/so.sprk.feed.reply/123',
      );
    });

    test('falls back to the reply uri when no subject is present', () {
      final target = replyNotificationTarget(
        replyUri: 'at://did:plc:reply/so.sprk.feed.reply/123',
      );

      expect(target.postUri, 'at://did:plc:reply/so.sprk.feed.reply/123');
      expect(
        target.highlightedReplyUri,
        'at://did:plc:reply/so.sprk.feed.reply/123',
      );
    });
  });

  group('replyNotificationTargetFromPayload', () {
    test('builds a target from push payload fields', () {
      final target = replyNotificationTargetFromPayload({
        'uri': 'at://did:plc:reply/so.sprk.feed.reply/123',
        'subject': 'at://did:plc:root/so.sprk.feed.post/456',
      });

      expect(target?.postUri, 'at://did:plc:root/so.sprk.feed.post/456');
      expect(
        target?.highlightedReplyUri,
        'at://did:plc:reply/so.sprk.feed.reply/123',
      );
    });
  });

  group('notificationPostRouteUri', () {
    test('uses embedded subject post for via-repost notifications', () {
      expect(
        notificationPostRouteUri(
          reason: 'like-via-repost',
          reasonSubject: 'at://did:plc:user/so.sprk.feed.repost/123',
          record: {
            'subject': {'uri': 'at://did:plc:author/so.sprk.feed.post/456'},
          },
        ),
        'at://did:plc:author/so.sprk.feed.post/456',
      );
    });

    test('does not route via-repost notifications to the repost record', () {
      expect(
        notificationPostRouteUri(
          reason: 'repost-via-repost',
          reasonSubject: 'at://did:plc:user/so.sprk.feed.repost/123',
          recordUri: 'at://did:plc:actor/app.bsky.feed.like/456',
        ),
        isNull,
      );
    });

    test('uses push subject for via-repost payloads', () {
      expect(
        notificationPostRouteUri(
          reason: 'like-via-repost',
          reasonSubject: 'at://did:plc:user/so.sprk.feed.repost/123',
          payload: {'subject': 'at://did:plc:author/so.sprk.feed.post/456'},
        ),
        'at://did:plc:author/so.sprk.feed.post/456',
      );
    });

    test('keeps routing normal reactions by reasonSubject', () {
      expect(
        notificationPostRouteUri(
          reason: 'like',
          reasonSubject: 'at://did:plc:author/so.sprk.feed.post/456',
        ),
        'at://did:plc:author/so.sprk.feed.post/456',
      );
    });

    test('falls back to routeable record uri for mentions', () {
      expect(
        notificationPostRouteUri(
          reason: 'mention',
          recordUri: 'at://did:plc:author/so.sprk.feed.post/456',
        ),
        'at://did:plc:author/so.sprk.feed.post/456',
      );
    });
  });
}
