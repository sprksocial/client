import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/utils/did_utils.dart';

void main() {
  group('DidUtils', () {
    group('buildDidDocumentUrl', () {
      test('builds plc directory URL for did:plc', () {
        final uri = DidUtils.buildDidDocumentUrl('did:plc:abc123');
        expect(uri.toString(), 'https://plc.directory/did:plc:abc123');
      });

      test('builds well-known URL for did:web with domain only', () {
        final uri = DidUtils.buildDidDocumentUrl('did:web:example.com');
        expect(uri.toString(), 'https://example.com/.well-known/did.json');
      });

      test('builds path-based URL for did:web with path segments', () {
        final uri = DidUtils.buildDidDocumentUrl(
          'did:web:example.com:user:alice',
        );
        expect(uri.toString(), 'https://example.com/user/alice/did.json');
      });

      test('handles did:web with percent-encoded domain (port number)', () {
        final uri = DidUtils.buildDidDocumentUrl('did:web:example%3A8080');
        expect(uri.toString(), 'https://example:8080/.well-known/did.json');
      });

      test('builds path-based URL for did:web with deep path', () {
        final uri = DidUtils.buildDidDocumentUrl(
          'did:web:example.com:org:department:team',
        );
        expect(
          uri.toString(),
          'https://example.com/org/department/team/did.json',
        );
      });

      test('defaults to plc directory for unknown DID methods', () {
        final uri = DidUtils.buildDidDocumentUrl('did:key:z6MkhaXg...');
        expect(uri.toString(), 'https://plc.directory/did:key:z6MkhaXg...');
      });

      test('throws ArgumentError for empty did:web domain', () {
        expect(
          () => DidUtils.buildDidDocumentUrl('did:web:'),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for did:web with only colons', () {
        expect(
          () => DidUtils.buildDidDocumentUrl('did:web:::'),
          throwsArgumentError,
        );
      });
    });
  });
}
