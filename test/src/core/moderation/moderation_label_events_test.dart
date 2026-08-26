import 'package:flutter_test/flutter_test.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/moderation/moderation_label_events.dart';

void main() {
  final now = DateTime.utc(2026, 8, 20, 12);

  Label label({
    required String value,
    required DateTime createdAt,
    String source = 'did:plc:moderator',
    String uri = 'at://did:plc:author/app.bsky.feed.post/record',
    bool? negated,
    DateTime? expiresAt,
  }) {
    return Label(
      src: source,
      uri: uri,
      val: value,
      neg: negated,
      cts: createdAt,
      exp: expiresAt,
    );
  }

  group('mergeLatestLabelEvents', () {
    test('reconciles each identity while preserving identity order', () {
      final original = label(
        value: 'sexual',
        createdAt: now.subtract(const Duration(minutes: 3)),
      );
      final otherValue = label(
        value: 'gore',
        createdAt: now.subtract(const Duration(minutes: 2)),
      );
      final replacement = label(
        value: 'sexual',
        createdAt: now.subtract(const Duration(minutes: 1)),
      );
      final otherSource = label(
        value: 'sexual',
        source: 'did:plc:other-moderator',
        createdAt: now,
      );

      final result = mergeLatestLabelEvents(
        existing: [original, otherValue],
        incoming: [replacement, otherSource],
        now: now,
      );

      expect(result, [replacement, otherValue, otherSource]);
    });

    test('keeps an inactive event over an equal-time assertion', () {
      final assertion = label(value: 'sexual', createdAt: now);
      final negation = label(value: 'sexual', createdAt: now, negated: true);

      expect(
        mergeLatestLabelEvents(
          existing: [assertion],
          incoming: [negation],
          now: now,
        ),
        [negation],
      );
      expect(
        mergeLatestLabelEvents(
          existing: [negation],
          incoming: [assertion],
          now: now,
        ),
        [negation],
      );
    });
  });

  group('label activity', () {
    test('uses one negation and expiry boundary', () {
      final active = label(
        value: 'active',
        createdAt: now,
        expiresAt: now.add(const Duration(seconds: 1)),
      );
      final negated = label(value: 'negated', createdAt: now, negated: true);
      final expired = label(value: 'expired', createdAt: now, expiresAt: now);

      expect(isLabelActiveAt(active, now: now), isTrue);
      expect(isLabelActiveAt(negated, now: now), isFalse);
      expect(isLabelActiveAt(expired, now: now), isFalse);
      expect(activeLabelsFromEvents([active, negated, expired], now: now), [
        active,
      ]);
    });
  });
}
