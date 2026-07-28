import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/components/atoms/tab_item.dart';
import 'package:spark/src/core/design_system/components/atoms/toggles/toggle_button.dart';

void main() {
  testWidgets('InteractivePressable calls onTap for pointer activation', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: InteractivePressable(
            onTap: () => tapCount++,
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InteractivePressable));

    expect(tapCount, 1);
  });

  testWidgets('InteractivePressable exposes disabled button semantics', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: InteractivePressable(
            semanticLabel: 'Disabled action',
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
      ),
    );

    final node = tester.getSemantics(find.byType(InteractivePressable));
    final bool? isEnabled = node.flagsCollection.isEnabled.toBoolOrNull();
    expect(node.flagsCollection.isButton, isTrue);
    expect(isEnabled, isNotNull);
    expect(isEnabled, isFalse);

    semanticsHandle.dispose();
  });

  testWidgets('InteractivePressable activates with keyboard focus', (
    tester,
  ) async {
    final focusNode = FocusNode();
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: InteractivePressable(
            focusNode: focusNode,
            onTap: () => tapCount++,
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
      ),
    );

    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);

    expect(tapCount, 1);

    focusNode.dispose();
  });

  testWidgets('AppTabItem fills available width and calls onTap', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            child: Row(
              children: [
                AppTabItem(
                  activeChild: const Text('Selected'),
                  inactiveChild: const Text('Unselected'),
                  isSelected: true,
                  onTap: () => tapCount++,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(InteractivePressable)).width, 300);

    await tester.tap(find.byType(InteractivePressable));

    expect(tapCount, 1);
  });

  testWidgets('AppTabItem keeps selected indicator outside press feedback', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            child: Row(
              children: [
                AppTabItem(
                  activeChild: const Text('Selected'),
                  inactiveChild: const Text('Unselected'),
                  isSelected: true,
                  onTap: () {},
                  indicatorColor: Colors.red,
                  indicatorWidth: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final indicatorFinder = find.byWidgetPredicate(
      (widget) => widget is ColoredBox && widget.color == Colors.red,
    );

    expect(indicatorFinder, findsOneWidget);
    expect(tester.getSize(indicatorFinder), const Size(24, 2));
    expect(
      find.ancestor(
        of: indicatorFinder,
        matching: find.byType(InteractivePressable),
      ),
      findsNothing,
    );
  });

  testWidgets('ToggleButton calls onChanged with inverse selected value', (
    tester,
  ) async {
    bool? changedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ToggleButton(
            isSelected: true,
            selectedLabel: 'Unfollow',
            unselectedLabel: 'Follow',
            onChanged: (value) => changedValue = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ToggleButton));

    expect(changedValue, isFalse);
  });
}
