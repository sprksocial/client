import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/settings/ui/pages/settings_page.dart';

void main() {
  testWidgets('groups moderation controls under a dedicated destination', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SettingsPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Moderation'), findsOneWidget);
    expect(find.text('Show adult content'), findsNothing);
    expect(find.text('Labelers'), findsNothing);
  });
}
