import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/notifications/notification_navigation.dart';

void main() {
  group('notificationRecordUri', () {
    test('prefers canonical uri over legacy recordUri', () {
      expect(
        notificationRecordUri({
          'uri': 'at://did:plc:reply/so.sprk.feed.reply/123',
          'recordUri': 'at://did:plc:root/so.sprk.feed.post/456',
        }),
        'at://did:plc:reply/so.sprk.feed.reply/123',
      );
    });

    test('falls back to legacy recordUri', () {
      expect(
        notificationRecordUri({
          'recordUri': 'at://did:plc:reply/so.sprk.feed.reply/123',
        }),
        'at://did:plc:reply/so.sprk.feed.reply/123',
      );
    });

    test('ignores blank and non-string payload values', () {
      expect(notificationRecordUri({'uri': '', 'recordUri': 123}), isNull);
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
        'reasonSubject': 'at://did:plc:root/so.sprk.feed.post/456',
      });

      expect(target?.postUri, 'at://did:plc:root/so.sprk.feed.post/456');
      expect(
        target?.highlightedReplyUri,
        'at://did:plc:reply/so.sprk.feed.reply/123',
      );
    });
  });
}
