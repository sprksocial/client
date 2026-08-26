import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/surfaces/app_surface.dart';
import 'package:spark/src/core/design_system/tokens/shadows.dart';

void main() {
  testWidgets('owns outlined and raised surface treatments', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppSurface(child: Text('Outlined')),
              AppSurface(
                variant: AppSurfaceVariant.raised,
                child: Text('Raised'),
              ),
            ],
          ),
        ),
      ),
    );

    final decorations = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((widget) => widget.decoration)
        .whereType<BoxDecoration>()
        .where((decoration) => decoration.border != null)
        .toList();

    expect(decorations, hasLength(2));
    expect(decorations[0].boxShadow, isNull);
    expect(decorations[1].boxShadow, const [AppShadows.shadowXs]);
  });
}
