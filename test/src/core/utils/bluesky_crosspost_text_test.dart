import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/utils/bluesky_crosspost_text.dart';

void main() {
  group('buildBlueskyCrosspostText', () {
    test('uses only the link when source text is empty', () {
      const linkUrl = 'https://sprk.so/post/did:plc:abc123/postkey';

      final result = buildBlueskyCrosspostText(text: '', linkUrl: linkUrl);

      expect(result.text, linkUrl);
      expect(result.facetTextByteEnd, 0);
      expect(result.linkByteStart, 0);
    });

    test('adds the link after a paragraph break', () {
      const text = 'hello spark';
      const linkUrl = 'https://sprk.so/post/did:plc:abc123/postkey';

      final result = buildBlueskyCrosspostText(text: text, linkUrl: linkUrl);

      expect(result.text, '$text\n\n$linkUrl');
      expect(result.facetTextByteEnd, utf8.encode(text).length);
      expect(result.linkByteStart, utf8.encode('$text\n\n').length);
    });

    test('uses a byte offset for non-ascii text before the link', () {
      const text = 'spark sun';
      const decoratedText = '$text \u2600';
      const linkUrl = 'https://sprk.so/post/did:plc:abc123/postkey';

      final result = buildBlueskyCrosspostText(
        text: decoratedText,
        linkUrl: linkUrl,
      );

      expect(result.text, '$decoratedText\n\n$linkUrl');
      expect(result.facetTextByteEnd, utf8.encode(decoratedText).length);
      expect(result.linkByteStart, utf8.encode('$decoratedText\n\n').length);
      expect(result.linkByteStart, isNot(result.text.indexOf(linkUrl)));
    });

    test('truncates long source text while preserving the link', () {
      final text = 'a' * 400;
      const linkUrl = 'https://sprk.so/post/did:plc:abc123/postkey';

      final result = buildBlueskyCrosspostText(text: text, linkUrl: linkUrl);

      expect(result.text.length, 300);
      expect(result.text, endsWith('\n\n$linkUrl'));
      expect(result.text, contains('...'));
      expect(
        result.facetTextByteEnd,
        utf8.encode(result.text.split('...').first).length,
      );
      expect(
        result.linkByteStart,
        utf8.encode(result.text.split(linkUrl).first).length,
      );
    });
  });
}
