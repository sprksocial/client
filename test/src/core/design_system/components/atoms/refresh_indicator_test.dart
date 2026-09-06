import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/refresh_indicator.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

void main() {
  for (final useTopInset in [false, true]) {
    testWidgets('insets only the loader when opted in: $useTopInset', (
      tester,
    ) async {
      final refresh = Completer<void>();
      final key = GlobalKey<DSRefreshIndicatorState>();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: const EdgeInsets.only(top: 59),
              viewPadding: const EdgeInsets.only(top: 59),
            ),
            child: child!,
          ),
          home: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(),
            body: Builder(
              builder: (context) => DSRefreshIndicator(
                key: key,
                edgeOffset: useTopInset ? MediaQuery.paddingOf(context).top : 0,
                onRefresh: () => refresh.future,
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [SizedBox(height: 1200)],
                ),
              ),
            ),
          ),
        ),
      );

      final inset = useTopInset ? 59 + kToolbarHeight : 0.0;
      final gesture = await tester.startGesture(const Offset(200, 200));
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      final indicator = find.descendant(
        of: find.byType(DSRefreshIndicator),
        matching: find.byWidgetPredicate(
          (widget) => widget is CustomPaint && widget.painter != null,
        ),
      );
      expect(tester.getTopLeft(indicator).dy, greaterThanOrEqualTo(inset));
      await gesture.moveBy(const Offset(0, 370));
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.getTopLeft(indicator).dy, inset + 12);
      expect(tester.getTopLeft(find.byType(ListView)).dy, 0);

      refresh.complete();
      await tester.pumpAndSettle();
    });
  }

  for (final physics in <ScrollPhysics>[
    const ClampingScrollPhysics(),
    const BouncingScrollPhysics(),
  ]) {
    testWidgets(
      'pull holds its endpoint then continues loading with $physics',
      (tester) async {
        final refresh = Completer<void>();
        await tester.pumpWidget(
          _TestApp(physics: physics, onRefresh: () => refresh.future),
        );
        final gesture = await tester.startGesture(const Offset(200, 100));
        await gesture.moveBy(const Offset(0, 30));
        await tester.pump();
        final earlyPull = _paintedDots(tester);

        await gesture.moveBy(const Offset(0, 50));
        await tester.pump();
        expect(_paintedDots(tester), isNot(equals(earlyPull)));

        await gesture.moveBy(const Offset(0, 300));
        await tester.pump(const Duration(milliseconds: 200));
        final armed = _paintedDots(tester);
        for (final (shape, color) in armed) {
          expect(shape.width, shape.height);
          expect(shape.width, armed.first.$1.width);
          expect(shape.center.dy, armed.first.$1.center.dy);
          expect(color, armed.first.$2);
          expect(color.a, 1);
        }
        await gesture.moveBy(const Offset(0, 35));
        await tester.pump();
        final beforeRelease = _paintedDots(tester);
        expect(beforeRelease, equals(armed));

        await gesture.moveBy(const Offset(0, 150));
        await tester.pump();
        expect(_paintedDots(tester), equals(armed));

        await gesture.up();
        await tester.pump();
        expect(_paintedDots(tester), equals(beforeRelease));

        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 150));
        final loading = _paintedDots(tester);
        expect(loading, isNot(equals(beforeRelease)));

        refresh.complete();
        await tester.pump();
        expect(_paintedDots(tester), equals(loading));
        await tester.pumpAndSettle();
      },
    );

    testWidgets('refreshes only after releasing a pull with $physics', (
      tester,
    ) async {
      final refresh = Completer<void>();
      var refreshCount = 0;
      await tester.pumpWidget(
        _TestApp(
          physics: physics,
          onRefresh: () {
            refreshCount += 1;
            return refresh.future;
          },
        ),
      );
      final l10n = AppLocalizations.of(
        tester.element(find.byType(DSRefreshIndicator)),
      );

      final gesture = await tester.startGesture(const Offset(200, 100));
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      expect(find.bySemanticsLabel(l10n.refreshIndicatorPull), findsOneWidget);
      await gesture.moveBy(const Offset(0, 370));
      await tester.pump(const Duration(milliseconds: 300));

      expect(refreshCount, 0);
      expect(
        find.bySemanticsLabel(l10n.refreshIndicatorRelease),
        findsOneWidget,
      );
      expect(find.byType(RefreshProgressIndicator), findsNothing);

      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(refreshCount, 1);
      expect(
        find.bySemanticsLabel(l10n.refreshIndicatorRefreshing),
        findsOneWidget,
      );

      refresh.complete();
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(l10n.refreshIndicatorRefreshing),
        findsNothing,
      );
      expect(refreshCount, 1);
    });
  }

  testWidgets('a short pull cancels without refreshing', (tester) async {
    var refreshCount = 0;
    await tester.pumpWidget(_TestApp(onRefresh: () async => refreshCount += 1));

    await tester.drag(find.byType(ListView), const Offset(0, 40));
    await tester.pumpAndSettle();

    expect(refreshCount, 0);
    expect(find.byType(RefreshProgressIndicator), findsNothing);
  });

  testWidgets('concurrent programmatic refreshes share one operation', (
    tester,
  ) async {
    final key = GlobalKey<DSRefreshIndicatorState>();
    final refresh = Completer<void>();
    var refreshCount = 0;
    await tester.pumpWidget(
      _TestApp(
        indicatorKey: key,
        onRefresh: () {
          refreshCount += 1;
          return refresh.future;
        },
      ),
    );

    final first = key.currentState!.show();
    final second = key.currentState!.show();
    var completed = false;
    final allRefreshes = Future.wait([first, second]).then((_) {
      completed = true;
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(refreshCount, 1);
    expect(completed, isFalse);

    refresh.complete();
    await tester.pumpAndSettle();
    await allRefreshes;
    expect(completed, isTrue);
    expect(refreshCount, 1);
  });

  testWidgets('refresh can complete after the indicator is unmounted', (
    tester,
  ) async {
    final key = GlobalKey<DSRefreshIndicatorState>();
    final refresh = Completer<void>();
    await tester.pumpWidget(
      _TestApp(indicatorKey: key, onRefresh: () => refresh.future),
    );
    unawaited(key.currentState!.show());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.pumpWidget(const SizedBox.shrink());
    refresh.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion keeps loading readable without repeated frames', (
    tester,
  ) async {
    final key = GlobalKey<DSRefreshIndicatorState>();
    final refresh = Completer<void>();
    await tester.pumpWidget(
      _TestApp(
        indicatorKey: key,
        disableAnimations: true,
        onRefresh: () => refresh.future,
      ),
    );
    final l10n = AppLocalizations.of(
      tester.element(find.byType(DSRefreshIndicator)),
    );

    final pending = key.currentState!.show();
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(l10n.refreshIndicatorRefreshing),
      findsOneWidget,
    );
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(find.byType(RefreshProgressIndicator), findsNothing);

    refresh.complete();
    await tester.pumpAndSettle();
    await pending;
  });
}

List<(RRect, Color)> _paintedDots(WidgetTester tester) {
  final painting = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(DSRefreshIndicator),
      matching: find.byWidgetPredicate(
        (widget) => widget is CustomPaint && widget.painter != null,
      ),
    ),
  );
  final dots = <(RRect, Color)>[];
  expect(
    (Canvas canvas) => painting.painter!.paint(canvas, const Size(64, 36)),
    paints..everything((method, arguments) {
      if (method == #drawRRect) {
        final [RRect shape, Paint paint] = arguments;
        dots.add((shape, paint.color));
      }
      return true;
    }),
  );
  expect(dots, hasLength(3));
  return dots;
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.onRefresh,
    this.indicatorKey,
    this.physics = const ClampingScrollPhysics(),
    this.disableAnimations = false,
  });

  final Future<void> Function() onRefresh;
  final GlobalKey<DSRefreshIndicatorState>? indicatorKey;
  final ScrollPhysics physics;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: Scaffold(
        body: DSRefreshIndicator(
          key: indicatorKey,
          onRefresh: onRefresh,
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(parent: physics),
            children: const [SizedBox(height: 1200, child: Text('Feed'))],
          ),
        ),
      ),
    );
  }
}
