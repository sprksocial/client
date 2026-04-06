import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/utils/share_urls.dart';

void main() {
  group('buildSparkShareUrl', () {
    test('builds post URLs from canonical Spark post URIs', () {
      expect(
        buildSparkShareUrl('at://did:plc:abc123/so.sprk.feed.post/postkey'),
        'https://sprk.so/post/did:plc:abc123/postkey',
      );
    });

    test('builds post URLs from short Spark post URIs', () {
      expect(
        buildSparkShareUrl('did:plc:abc123/postkey'),
        'https://sprk.so/post/did:plc:abc123/postkey',
      );
    });
  });

  group('extractCanonicalSparkPostUri', () {
    test('parses canonical Spark post URLs', () {
      expect(
        extractCanonicalSparkPostUri(
          'https://sprk.so/post/did:plc:abc123/postkey',
        ),
        'at://did:plc:abc123/so.sprk.feed.post/postkey',
      );
    });

    test('parses encoded DIDs from universal-link paths', () {
      expect(
        extractCanonicalSparkPostUri(
          'https://sprk.so/post/did%3Aplc%3Aabc123/postkey',
        ),
        'at://did:plc:abc123/so.sprk.feed.post/postkey',
      );
    });

    test('parses legacy watch URLs', () {
      expect(
        extractCanonicalSparkPostUri(
          'https://sprk.so/watch?uri=at%3A%2F%2Fdid%3Aplc%3Aabc123%2Fso.sprk.feed.post%2Fpostkey',
        ),
        'at://did:plc:abc123/so.sprk.feed.post/postkey',
      );
    });
  });

  test('parseCanonicalSparkPostUri returns did and rkey', () {
    expect(
      parseCanonicalSparkPostUri(
        'at://did:plc:abc123/so.sprk.feed.post/postkey',
      ),
      (did: 'did:plc:abc123', rkey: 'postkey'),
    );
  });
}
