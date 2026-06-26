import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/messages/data/models/message_models.dart';

void main() {
  group('UnsupportedMessageView', () {
    test('returns null when unknown raw message lacks common fields', () {
      expect(
        UnsupportedMessageView.tryFromRaw(const {
          r'$type': 'chat.sprk.convo.defs#futureMessageView',
          'payload': {'kind': 'future'},
        }),
        isNull,
      );
    });

    test('preserves unknown raw message with common fields', () {
      final message = UnsupportedMessageView.tryFromRaw(const {
        r'$type': 'chat.sprk.convo.defs#futureMessageView',
        'id': 'message-1',
        'rev': 'rev-1',
        'sender': {'did': 'did:plc:test'},
        'sentAt': '2026-04-11T10:00:00.000Z',
      });

      expect(message, isNotNull);
      expect(message!.id, 'message-1');
      expect(message.sender.did, 'did:plc:test');
    });

    test(
      'ChatMessageView unsupported factory fails for unrepresentable raw',
      () {
        expect(
          () => ChatMessageView.unsupportedFromRaw(const {
            r'$type': 'chat.sprk.convo.defs#futureMessageView',
            'payload': {'kind': 'future'},
          }),
          throwsFormatException,
        );
      },
    );
  });
}
