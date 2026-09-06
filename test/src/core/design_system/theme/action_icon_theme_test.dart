import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/theme/app_theme.dart' as design;
import 'package:spark/src/core/ui/theme/data/models/app_theme.dart' as legacy;

void main() {
  final themes = <String, ThemeData>{
    'design light': design.AppTheme.light,
    'design dark': design.AppTheme.dark,
    'legacy light': legacy.AppTheme.lightTheme,
    'legacy dark': legacy.AppTheme.darkTheme,
  };

  for (final entry in themes.entries) {
    for (final direction in TextDirection.values) {
      testWidgets('${entry.key} uses Spark navigation icons in $direction', (
        tester,
      ) async {
        final navigatorKey = GlobalKey<NavigatorState>();
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            theme: entry.value,
            builder: (context, child) =>
                Directionality(textDirection: direction, child: child!),
            home: const Scaffold(body: Text('Home')),
          ),
        );

        for (final fullscreenDialog in <bool>[false, true]) {
          navigatorKey.currentState!.push<void>(
            MaterialPageRoute<void>(
              fullscreenDialog: fullscreenDialog,
              builder: (context) => Scaffold(appBar: AppBar()),
            ),
          );
          await tester.pumpAndSettle();

          final icon = tester.widget<AppIcon>(find.byType(AppIcon));
          expect(
            icon.icon,
            fullscreenDialog
                ? AppIconData.cancel
                : direction == TextDirection.rtl
                ? AppIconData.chevronRight
                : AppIconData.chevronLeft,
          );
          expect(find.byType(Icon), findsNothing);

          await tester.tap(
            find.byType(fullscreenDialog ? CloseButton : BackButton),
          );
          await tester.pumpAndSettle();
          expect(find.text('Home'), findsOneWidget);
          expect(navigatorKey.currentState!.canPop(), isFalse);
        }
      });
    }
  }
}
