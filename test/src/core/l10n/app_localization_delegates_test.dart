import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spark/src/core/design_system/theme/app_theme.dart';
import 'package:spark/src/core/l10n/app_localization_delegates.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'app delegates support date selection in the $brightness theme',
      (tester) async {
        final theme = brightness == Brightness.light
            ? AppTheme.light
            : AppTheme.dark;
        DateTime? selectedDate;

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            localizationsDelegates: appLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2026, 9, 15),
                      firstDate: DateTime(2026, 9),
                      lastDate: DateTime(2026, 9, 30),
                    );
                  },
                  child: Text(AppLocalizations.of(context).buttonEdit),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Edit'), findsOneWidget);
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        final dialogContext = tester.element(find.byType(DatePickerDialog));
        final materialLocalizations = MaterialLocalizations.of(dialogContext);
        expect(
          find.text(materialLocalizations.datePickerHelpText),
          findsOneWidget,
        );
        expect(
          find.text(materialLocalizations.cancelButtonLabel),
          findsOneWidget,
        );
        expect(AppLocalizations.of(dialogContext).buttonEdit, 'Edit');
        expect(Theme.of(dialogContext).brightness, brightness);
        expect(Theme.of(dialogContext).colorScheme, theme.colorScheme);

        await tester.tap(find.text('16'));
        await tester.pump();
        await tester.tap(find.text(materialLocalizations.okButtonLabel));
        await tester.pumpAndSettle();

        expect(selectedDate, DateTime(2026, 9, 16));
        expect(find.byType(DatePickerDialog), findsNothing);
        expect(find.text('Edit'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
