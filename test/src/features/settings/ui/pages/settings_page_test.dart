import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/settings/ui/pages/settings_page.dart';

void main() {
  testWidgets('groups moderation controls under a dedicated destination', (
    tester,
  ) async {
    await _pumpSettingsPage(tester);

    expect(find.text('Moderation'), findsOneWidget);
    expect(find.text('Show adult content'), findsNothing);
    expect(find.text('Labelers'), findsNothing);
  });

  testWidgets('offers Bluesky follow import as a persistent settings entry', (
    tester,
  ) async {
    await _pumpSettingsPage(tester);

    expect(find.byKey(const Key('settings-follow-import')), findsOneWidget);
    expect(find.text('Connections'), findsOneWidget);
    expect(
      tester
          .widget<ListTile>(find.byKey(const Key('settings-follow-import')))
          .subtitle,
      isNull,
    );
  });
}

Future<void> _pumpSettingsPage(WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
