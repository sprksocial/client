import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/network/atproto/data/services/appview_labeler_headers.dart';

void main() {
  group('AppViewLabelerHeaders', () {
    test('keeps the required default and normalizes subscriptions', () {
      final headers = AppViewLabelerHeaders(
        defaultLabelerDid: 'did:plc:default#labeler',
      )..configure([' did:plc:custom ', 'did:plc:default', 'did:plc:custom']);

      expect(headers.labelerDids, ['did:plc:default', 'did:plc:custom']);
      expect(headers.forAppView('did:web:appview.test'), {
        'atproto-proxy': 'did:web:appview.test',
        atprotoAcceptLabelersHeader: 'did:plc:default,did:plc:custom',
      });
    });

    test('limits the accepted labelers to the protocol maximum', () {
      final headers = AppViewLabelerHeaders(
        defaultLabelerDid: 'did:plc:default',
      )..configure([for (var index = 0; index < 30; index++) 'did:plc:$index']);

      expect(headers.labelerDids, hasLength(AppViewLabelerHeaders.maxLabelers));
      expect(headers.labelerDids.first, 'did:plc:default');
      expect(headers.labelerDids.last, 'did:plc:18');
    });

    test('can override one request without mutating configured labelers', () {
      final headers = AppViewLabelerHeaders(
        defaultLabelerDid: 'did:plc:default',
      )..configure(['did:plc:configured']);

      expect(
        headers.forAppView(
          'did:web:appview.test',
          labelerDids: ['did:plc:override'],
        )[atprotoAcceptLabelersHeader],
        'did:plc:default,did:plc:override',
      );
      expect(headers.labelerDids, ['did:plc:default', 'did:plc:configured']);
    });
  });
}
