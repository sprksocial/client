import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';

void main() {
  testWidgets('content-width button does not fill a wide parent', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            child: AppButton(label: 'Tap', onPressed: () {}),
          ),
        ),
      ),
    );

    final pressableSize = tester.getSize(find.byType(InteractivePressable));

    expect(pressableSize.width, lessThan(300));
  });

  testWidgets('full-width button fills a wide parent', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            child: AppButton(label: 'Tap', onPressed: () {}, fullWidth: true),
          ),
        ),
      ),
    );

    final pressableSize = tester.getSize(find.byType(InteractivePressable));

    expect(pressableSize.width, 300);
  });
}
