import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/posting/models/content_warning_selection.dart';
import 'package:spark/src/features/posting/ui/widgets/content_warning_selector.dart';

void main() {
  testWidgets('adult warning is exclusive and graphic media is independent', (
    tester,
  ) async {
    final key = GlobalKey<_HostState>();
    await tester.pumpWidget(_app(_Host(key: key)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('content-warning-sexual')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('content-warning-graphic-media')));
    await tester.pump();

    expect(key.currentState!.selection.values, ['sexual', 'graphic-media']);

    await tester.tap(find.byKey(const Key('content-warning-nudity')));
    await tester.pump();

    expect(key.currentState!.selection.values, ['nudity', 'graphic-media']);
    expect(find.text('For example, artistic nudes.'), findsOneWidget);
  });

  testWidgets('selected adult warning can be cleared', (tester) async {
    final key = GlobalKey<_HostState>();
    await tester.pumpWidget(_app(_Host(key: key)));
    await tester.pumpAndSettle();

    final suggestive = find.byKey(const Key('content-warning-sexual'));
    await tester.tap(suggestive);
    await tester.pump();
    await tester.tap(suggestive);
    await tester.pump();

    expect(key.currentState!.selection.values, isEmpty);
  });
}

Widget _app(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

class _Host extends StatefulWidget {
  const _Host({super.key});

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  ContentWarningSelection selection = const ContentWarningSelection();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ContentWarningSelector(
        value: selection,
        onChanged: (value) => setState(() => selection = value),
      ),
    );
  }
}
