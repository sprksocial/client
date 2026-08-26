import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/components/molecules/app_choice_group.dart';

void main() {
  testWidgets('renders equal-width choices and reports the selected value', (
    tester,
  ) async {
    String? changedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: AppChoiceGroup<String>(
              value: 'warn',
              options: const [
                AppChoiceOption(value: 'off', label: 'Off'),
                AppChoiceOption(value: 'warn', label: 'Warn'),
                AppChoiceOption(value: 'hide', label: 'Hide'),
              ],
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      ),
    );

    final choiceMaterials = find.descendant(
      of: find.byType(AppChoiceGroup<String>),
      matching: find.byType(Material),
    );
    expect(choiceMaterials, findsNWidgets(3));
    final row = tester.widget<Row>(
      find.descendant(
        of: find.byType(AppChoiceGroup<String>),
        matching: find.byType(Row),
      ),
    );
    expect(row.spacing, 6);
    expect(
      tester.getSize(choiceMaterials.at(0)).width,
      tester.getSize(choiceMaterials.at(1)).width,
    );
    expect(
      tester.getSize(choiceMaterials.at(1)).width,
      tester.getSize(choiceMaterials.at(2)).width,
    );
    expect(tester.widget<Material>(choiceMaterials.at(1)).elevation, 2);
    expect(tester.widget<Material>(choiceMaterials.at(0)).elevation, 0);

    await tester.tap(
      find
          .descendant(
            of: find.byType(AppChoiceGroup<String>),
            matching: find.byType(InteractivePressable),
          )
          .at(2),
    );
    await tester.pump();

    expect(changedValue, 'hide');
  });

  testWidgets('exposes mutually-exclusive selection semantics', (tester) async {
    final semanticsHandle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppChoiceGroup<String>(
            value: 'warn',
            options: const [
              AppChoiceOption(value: 'off', label: 'Off'),
              AppChoiceOption(value: 'warn', label: 'Warn'),
            ],
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final warnSemantics = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == 'Warn',
    );
    final node = tester.getSemantics(warnSemantics);

    expect(node.flagsCollection.isButton, isTrue);
    expect(node.flagsCollection.isSelected.toBoolOrNull(), isTrue);
    expect(node.flagsCollection.isInMutuallyExclusiveGroup, isTrue);

    semanticsHandle.dispose();
  });

  testWidgets('does not report changes when disabled', (tester) async {
    String? changedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppChoiceGroup<String>(
            value: 'off',
            enabled: false,
            options: const [
              AppChoiceOption(value: 'off', label: 'Off'),
              AppChoiceOption(value: 'warn', label: 'Warn'),
            ],
            onChanged: (value) => changedValue = value,
          ),
        ),
      ),
    );

    await tester.tap(
      find
          .descendant(
            of: find.byType(AppChoiceGroup<String>),
            matching: find.byType(InteractivePressable),
          )
          .at(1),
    );
    await tester.pump();

    expect(changedValue, isNull);
    expect(find.byType(InteractivePressable), findsNWidgets(2));
  });
}
