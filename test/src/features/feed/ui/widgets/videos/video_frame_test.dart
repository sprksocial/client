import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_frame.dart';

void main() {
  for (final aspectRatio in <double?>[null, 9 / 16]) {
    testWidgets('hides a processing thumbnail error for ratio $aspectRatio', (
      tester,
    ) async {
      debugNetworkImageHttpClientProvider = () => _ProcessingThumbnailClient();
      addTearDown(() => debugNetworkImageHttpClientProvider = null);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FeedVideoThumbnailFrame(
            thumbnail: 'https://video.example/thumbnail-$aspectRatio.jpg',
            videoAspectRatio: aspectRatio,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(find.byType(ColoredBox), findsOneWidget);
      debugNetworkImageHttpClientProvider = null;
    });
  }

  group('feedVideoFitForAspectRatio', () {
    test('covers vertical full-screen video ratios', () {
      expect(feedVideoFitForAspectRatio(9 / 16), BoxFit.cover);
    });

    test('contains horizontal and unknown video ratios', () {
      expect(feedVideoFitForAspectRatio(16 / 9), BoxFit.contain);
      expect(feedVideoFitForAspectRatio(null), BoxFit.contain);
    });
  });

  group('feedVideoThumbnailFitForAspectRatio', () {
    test(
      'shows unknown-ratio thumbnails immediately with old contain behavior',
      () {
        expect(feedVideoThumbnailFitForAspectRatio(null), BoxFit.contain);
      },
    );

    test('covers thumbnails once a frame ratio is known', () {
      expect(feedVideoThumbnailFitForAspectRatio(9 / 16), BoxFit.cover);
      expect(feedVideoThumbnailFitForAspectRatio(16 / 9), BoxFit.cover);
    });
  });

  group('feedVideoFrameSize', () {
    test('derives aspect ratio only from valid player sizes', () {
      expect(feedVideoAspectRatioFromSize(const Size(1920, 1080)), 16 / 9);
      expect(feedVideoAspectRatioFromSize(Size.zero), isNull);
      expect(feedVideoAspectRatioFromSize(const Size(1920, 0)), isNull);
      expect(feedVideoAspectRatioFromSize(null), isNull);
    });

    test('uses player-reported video size before aspect ratio fallback', () {
      expect(
        feedVideoFrameSize(
          videoSize: const Size(1920, 1080),
          aspectRatio: 9 / 16,
        ),
        const Size(1920, 1080),
      );
    });

    test('falls back to an aspect-ratio frame when no size is available', () {
      expect(feedVideoFrameSize(aspectRatio: 9 / 16), const Size(9 / 16, 1));
    });

    test('stays unknown for missing or invalid dimensions', () {
      expect(feedVideoFrameSize(), isNull);
      expect(feedVideoFrameSize(aspectRatio: 0), isNull);
      expect(
        feedVideoFrameSize(videoSize: Size.zero, aspectRatio: null),
        isNull,
      );
    });
  });
}

class _ProcessingThumbnailClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _ProcessingThumbnailRequest();
}

class _ProcessingThumbnailRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _ProcessingThumbnailResponse();
}

class _ProcessingThumbnailResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 202;

  @override
  Future<E> drain<E>([E? futureValue]) =>
      const Stream<List<int>>.empty().drain<E>(futureValue);
}
