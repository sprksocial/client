import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/toggles/app_toggle.dart';

void main() {
  testWidgets('requests the inverse value and waits for the parent to update', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    final changes = <bool>[];

    Future<void> showToggle(bool value) => tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: AppToggle(
            value: value,
            onChanged: changes.add,
            semanticLabel: 'Notifications',
          ),
        ),
      ),
    );

    await showToggle(false);
    await tester.tap(find.byType(AppToggle));
    await tester.pumpAndSettle();

    expect(changes, <bool>[true]);
    expect(
      tester
          .getSemantics(find.byType(AppToggle))
          .flagsCollection
          .isToggled
          .toBoolOrNull(),
      isFalse,
    );

    await showToggle(true);
    await tester.pumpAndSettle();
    expect(
      tester
          .getSemantics(find.byType(AppToggle))
          .flagsCollection
          .isToggled
          .toBoolOrNull(),
      isTrue,
    );
    await tester.tap(find.byType(AppToggle));

    expect(changes, <bool>[true, false]);
    semanticsHandle.dispose();
  });

  testWidgets('exposes a labeled toggle with an accessible tap action', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    bool? changedValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: AppToggle(
            value: true,
            onChanged: (value) => changedValue = value,
            semanticLabel: 'Notifications',
          ),
        ),
      ),
    );

    final node = tester.getSemantics(find.byType(AppToggle));
    expect(node.label, 'Notifications');
    expect(node.flagsCollection.isToggled.toBoolOrNull(), isTrue);
    expect(node.flagsCollection.isEnabled.toBoolOrNull(), isTrue);
    expect(node.flagsCollection.isButton, isFalse);
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

    tester.semantics.tap(find.semantics.byLabel('Notifications'));
    expect(changedValue, isFalse);
    semanticsHandle.dispose();
  });

  testWidgets(
    'supports tab focus, space and enter, and skips disabled toggles',
    (tester) async {
      final changes = <bool>[];
      var value = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: StatefulBuilder(
              builder: (context, setState) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppToggle(
                    value: false,
                    onChanged: null,
                    semanticLabel: 'Disabled',
                  ),
                  AppToggle(
                    value: value,
                    semanticLabel: 'Enabled',
                    onChanged: (nextValue) {
                      changes.add(nextValue);
                      setState(() => value = nextValue);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(changes, <bool>[true, false]);
    },
  );

  testWidgets(
    'disabling a focused toggle removes activation and tap semantics',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      final changes = <bool>[];

      Future<void> showToggle({required bool enabled}) => tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: AppToggle(
              value: true,
              onChanged: enabled ? changes.add : null,
              semanticLabel: 'Notifications',
            ),
          ),
        ),
      );

      await showToggle(enabled: true);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await showToggle(enabled: false);
      await tester.tap(find.byType(AppToggle));
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(changes, isEmpty);
      final node = tester.getSemantics(find.byType(AppToggle));
      expect(node.label, 'Notifications');
      expect(node.flagsCollection.isToggled.toBoolOrNull(), isTrue);
      expect(node.flagsCollection.isEnabled.toBoolOrNull(), isFalse);
      expect(node.flagsCollection.isButton, isFalse);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      semanticsHandle.dispose();
    },
  );

  for (final direction in TextDirection.values) {
    testWidgets(
      'mirrors its thumb in $direction and honors reduced motion immediately',
      (tester) async {
        var value = false;
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Directionality(
                textDirection: direction,
                child: Center(
                  child: StatefulBuilder(
                    builder: (context, setState) => AppToggle(
                      value: value,
                      onChanged: (nextValue) =>
                          setState(() => value = nextValue),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final toggle = find.byType(AppToggle);
        final thumb = find.descendant(
          of: toggle,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).shape == BoxShape.circle,
          ),
        );
        final centerX = tester.getCenter(toggle).dx;
        final offX = tester.getCenter(thumb).dx;
        final targetSize = tester.getSize(toggle);
        expect(targetSize.width, greaterThanOrEqualTo(48));
        expect(targetSize.height, greaterThanOrEqualTo(48));
        expect(
          offX,
          direction == TextDirection.ltr
              ? lessThan(centerX)
              : greaterThan(centerX),
        );

        await tester.tap(toggle);
        await tester.pump();

        final onX = tester.getCenter(thumb).dx;
        expect(
          onX,
          direction == TextDirection.ltr
              ? greaterThan(centerX)
              : lessThan(centerX),
        );
        expect(onX - centerX, closeTo(centerX - offX, 0.01));
      },
    );
  }
}
