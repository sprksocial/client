import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/media/media_playback_gate.dart';
import 'package:spark/src/core/media/media_playback_suspension_provider.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/posting/navigation/recording_review_navigation.dart';
import 'package:spark/src/features/posting/utils/create_media_actions.dart';

const _homeRoute = 'PlaybackHomeRoute';
const _videoPath = '/recorded-video.mp4';
const _postUri = 'at://did:plc:test/app.bsky.feed.post/test';

void main() {
  testWidgets(
    'closing review releases recording suspension and resumes the feed',
    (tester) async {
      final harness = await _pumpNavigation(tester);
      expect(find.text('playing'), findsOneWidget);

      await _openReview(tester, harness.container);
      await tester.tap(find.text('Close review'));
      await tester.pumpAndSettle();

      expect(harness.router.stack.map((page) => page.name), [_homeRoute]);
      expect(harness.container.read(mediaPlaybackSuspendedProvider), isFalse);
      expect(find.text('playing'), findsOneWidget);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.iOS,
      TargetPlatform.android,
    }),
  );

  testWidgets(
    'repeated recording and review exits do not accumulate suspensions',
    (tester) async {
      final harness = await _pumpNavigation(tester);

      for (var attempt = 0; attempt < 3; attempt++) {
        await _openReview(tester, harness.container);
        await tester.tap(find.text('Close review'));
        await tester.pumpAndSettle();

        expect(
          harness.container.read(mediaPlaybackSuspendedProvider),
          isFalse,
          reason: 'Recording flow ${attempt + 1} must release its suspension',
        );
        expect(find.text('playing'), findsOneWidget);
      }
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.iOS,
      TargetPlatform.android,
    }),
  );

  testWidgets(
    'posting resumes playback and preserves the posted video destination',
    (tester) async {
      final harness = await _pumpNavigation(tester);

      await _openReview(tester, harness.container);
      await tester.tap(find.text('Post video'));
      await tester.pumpAndSettle();

      expect(harness.router.stack.map((page) => page.name), [
        _homeRoute,
        StandalonePostRoute.name,
      ]);
      expect(harness.container.read(mediaPlaybackSuspendedProvider), isFalse);
      expect(find.text('Posted video'), findsOneWidget);
      expect(find.text('playing'), findsOneWidget);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.iOS,
      TargetPlatform.android,
    }),
  );
}

Future<void> _openReview(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.tap(find.text('Create video'));
  await tester.pumpAndSettle();
  expect(container.read(mediaPlaybackSuspendedProvider), isTrue);

  await tester.tap(find.text('Review video'));
  await tester.pumpAndSettle();
  expect(find.text('Close review'), findsOneWidget);
  expect(container.read(mediaPlaybackSuspendedProvider), isTrue);
}

Future<({RootStackRouter router, ProviderContainer container})> _pumpNavigation(
  WidgetTester tester,
) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  final container = ProviderContainer();
  final router = RootStackRouter.build(
    defaultRouteType: const RouteType.adaptive(),
    routes: [
      AutoRoute(
        page: PageInfo.builder(
          _homeRoute,
          builder: (context, data) => Scaffold(
            body: Column(
              children: [
                MediaPlaybackGate(
                  isActive: true,
                  builder: (context, shouldPlay) =>
                      Text(shouldPlay ? 'playing' : 'paused'),
                ),
                TextButton(
                  onPressed: CreateMediaActions.onRecord(
                    context,
                    storyMode: false,
                  ),
                  child: const Text('Create video'),
                ),
              ],
            ),
          ),
        ),
        path: '/',
        initial: true,
      ),
      AutoRoute(
        page: PageInfo.builder(
          RecordingRoute.name,
          builder: (context, data) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  reviewRecordedVideo(context, videoPath: _videoPath),
              child: const Text('Review video'),
            ),
          ),
        ),
        path: '/recording',
      ),
      AutoRoute(
        page: PageInfo.builder(
          VideoReviewRoute.name,
          builder: (context, data) => Scaffold(
            body: Column(
              children: [
                TextButton(
                  onPressed: context.router.pop,
                  child: const Text('Close review'),
                ),
                TextButton(
                  onPressed: () {
                    final router = context.router;
                    router.popUntilRoot();
                    router.push(StandalonePostRoute(postUri: _postUri));
                  },
                  child: const Text('Post video'),
                ),
              ],
            ),
          ),
        ),
        path: '/review',
      ),
      AutoRoute(
        page: PageInfo.builder(
          StandalonePostRoute.name,
          builder: (context, data) => Scaffold(
            body: Column(
              children: [
                const Text('Posted video'),
                MediaPlaybackGate(
                  isActive: true,
                  builder: (context, shouldPlay) =>
                      Text(shouldPlay ? 'playing' : 'paused'),
                ),
              ],
            ),
          ),
        ),
        path: '/post',
      ),
    ],
  );

  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    container.dispose();
  });
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router.config()),
    ),
  );
  await tester.pumpAndSettle();
  return (router: router, container: container);
}
