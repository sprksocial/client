import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spark/src/features/feed/data/video_availability_client.dart';

const _videoUrl = 'https://video.example/watch/did/cid/playlist.m3u8';

void main() {
  group('VideoAvailabilityClient', () {
    test('retries processing responses until the playlist is ready', () async {
      var requests = 0;
      final httpClient = _CloseAwareClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), _videoUrl);
        requests++;
        return http.Response('', requests == 1 ? 202 : 200);
      });
      final availability = VideoAvailabilityClient(
        client: httpClient,
        retryDelay: Duration.zero,
      );

      await availability.waitUntilReady(_videoUrl);

      expect(requests, 2);
      expect(httpClient.closed, isTrue);
    });

    test('retries transient CDN failures', () async {
      final statuses = [500, 502, 503, 504, 200].iterator;
      final availability = VideoAvailabilityClient(
        client: MockClient((_) async {
          expect(statuses.moveNext(), isTrue);
          return http.Response('', statuses.current);
        }),
        retryDelay: Duration.zero,
      );

      await availability.waitUntilReady(_videoUrl);

      expect(statuses.moveNext(), isFalse);
    });

    test('fails immediately for a missing video', () async {
      var requests = 0;
      final httpClient = _CloseAwareClient((_) async {
        requests++;
        return http.Response('', 404);
      });
      final availability = VideoAvailabilityClient(client: httpClient);

      await expectLater(
        availability.waitUntilReady(_videoUrl),
        throwsA(isA<http.ClientException>()),
      );

      expect(requests, 1);
      expect(httpClient.closed, isTrue);
    });

    testWidgets('honors Retry-After and cancels delayed retries', (
      tester,
    ) async {
      var requests = 0;
      final httpClient = _CloseAwareClient((_) async {
        requests++;
        return http.Response('', 202, headers: {'retry-after': '5'});
      });
      final availability = VideoAvailabilityClient(client: httpClient);
      final check = expectLater(
        availability.waitUntilReady(_videoUrl),
        throwsStateError,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      expect(requests, 1);
      await tester.pump(const Duration(seconds: 1));
      expect(requests, 2);

      availability.close();
      await tester.pump();
      await check;
      await tester.pump(const Duration(seconds: 30));

      expect(requests, 2);
      expect(httpClient.closed, isTrue);
    });

    test('cancellation terminates an in-flight check', () async {
      final response = Completer<http.Response>();
      final httpClient = _CloseAwareClient((_) => response.future);
      final availability = VideoAvailabilityClient(client: httpClient);
      final check = expectLater(
        availability.waitUntilReady(_videoUrl),
        throwsStateError,
      );

      availability.close();
      await check;

      expect(httpClient.closed, isTrue);
      response.complete(http.Response('', 200));
    });

    testWidgets('deadline closes an in-flight request', (tester) async {
      final response = Completer<http.Response>();
      final httpClient = _CloseAwareClient((_) => response.future);
      final availability = VideoAvailabilityClient(client: httpClient);
      final check = expectLater(
        availability.waitUntilReady(_videoUrl),
        throwsA(isA<TimeoutException>()),
      );

      await tester.pump(const Duration(minutes: 2));
      await check;

      expect(httpClient.closed, isTrue);
      response.complete(http.Response('', 200));
      await tester.pump();
    });
  });
}

class _CloseAwareClient extends MockClient {
  _CloseAwareClient(super.fn);

  bool closed = false;

  @override
  void close() {
    closed = true;
    super.close();
  }
}
