import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/utils/text_formatter.dart';

void main() {
  group('TextFormatter', () {
    group('formatCount', () {
      test('returns 0 for null and unexpected types', () {
        expect(TextFormatter.formatCount(null), '0');
        expect(TextFormatter.formatCount(3.14), '0');
        expect(TextFormatter.formatCount('abc'), '0');
      });

      test('formats plain numbers as-is', () {
        expect(TextFormatter.formatCount(0), '0');
        expect(TextFormatter.formatCount(42), '42');
        expect(TextFormatter.formatCount(999), '999');
      });

      test('formats thousands with K suffix', () {
        expect(TextFormatter.formatCount(1000), '1K');
        expect(TextFormatter.formatCount(1500), '1.5K');
        expect(TextFormatter.formatCount(999000), '999K');
      });

      test('formats millions with M suffix', () {
        expect(TextFormatter.formatCount(1000000), '1M');
        expect(TextFormatter.formatCount(1500000), '1.5M');
        expect(TextFormatter.formatCount(2300000), '2.3M');
      });

      test('handles string input', () {
        expect(TextFormatter.formatCount('42'), '42');
        expect(TextFormatter.formatCount('1000'), '1K');
      });
    });

    group('findUsernameMatches', () {
      test('finds @username matches', () {
        final matches = TextFormatter.findUsernameMatches('hello @alice world');
        expect(matches.length, 1);
        expect(matches.first.group(1), 'alice');
      });

      test('finds @handle.domain matches', () {
        final matches = TextFormatter.findUsernameMatches(
          'check @alice.bsky.social',
        );
        expect(matches.length, 1);
        expect(matches.first.group(0), '@alice.bsky.social');
      });

      test('finds multiple @mentions', () {
        final matches = TextFormatter.findUsernameMatches('@alice and @bob');
        expect(matches.length, 2);
      });

      test('returns empty list when no mentions', () {
        expect(TextFormatter.findUsernameMatches('no mentions here'), isEmpty);
      });

      test('does not match @ alone', () {
        expect(TextFormatter.findUsernameMatches('hello @ world'), isEmpty);
      });
    });

    group('extractUrls', () {
      test('extracts https URLs', () {
        final urls = TextFormatter.extractUrls(
          'visit https://example.com for more',
        );
        expect(urls, contains('https://example.com'));
      });

      test('extracts http URLs', () {
        final urls = TextFormatter.extractUrls(
          'visit http://example.com for more',
        );
        expect(urls, contains('http://example.com'));
      });

      test('does not extract emails as URLs', () {
        expect(TextFormatter.extractUrls('contact user@example.com'), isEmpty);
      });

      test('returns empty list for text without URLs', () {
        expect(TextFormatter.extractUrls('no urls here'), isEmpty);
      });

      test('extracts known-TLD domains without http prefix', () {
        final urls = TextFormatter.extractUrls('visit example.com today');
        expect(urls, contains('example.com'));
      });
    });

    group('charIndexToByteIndex / byteIndexToCharIndex', () {
      test('round-trips correctly for ASCII', () {
        const text = 'hello world';
        for (int i = 0; i <= text.length; i++) {
          final byteIndex = TextFormatter.charIndexToByteIndex(text, i);
          final charIndex = TextFormatter.byteIndexToCharIndex(text, byteIndex);
          expect(charIndex, i);
        }
      });

      test('round-trips correctly for multi-byte text', () {
        const text = 'café';
        // c=0, a=1, f=2, é=3 (char indices) → 0,1,2,4 (byte indices)
        for (final i in [0, 1, 2, 3, 4]) {
          final byteIndex = TextFormatter.charIndexToByteIndex(text, i);
          final charIndex = TextFormatter.byteIndexToCharIndex(text, byteIndex);
          expect(charIndex, i);
        }
      });

      test('handles boundary conditions', () {
        expect(TextFormatter.charIndexToByteIndex('hello', -1), 0);
        expect(TextFormatter.charIndexToByteIndex('hello', 100), 5);
        expect(TextFormatter.byteIndexToCharIndex('hello', -1), 0);
        expect(TextFormatter.byteIndexToCharIndex('hello', 0), 0);
        expect(TextFormatter.byteIndexToCharIndex('hello', 100), 5);
        expect(TextFormatter.charIndexToByteIndex('', 0), 0);
      });
    });

    group('byteLength', () {
      test('returns correct byte length for ASCII, multi-byte, and empty', () {
        expect(TextFormatter.byteLength('hello'), 5);
        expect(TextFormatter.byteLength('café'), 5);
        expect(TextFormatter.byteLength('🎉'), 4);
        expect(TextFormatter.byteLength(''), 0);
      });
    });
  });
}
