import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:spark/src/core/design_system/theme/app_theme.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/l10n/app_localization_delegates.dart';

import 'widgetbook.directories.g.dart';

Widget _appBuilder(BuildContext context, Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: appLocalizationDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      // Use the generated directories variable
      directories: directories,
      appBuilder: _appBuilder,
      addons: [
        ThemeAddon<ThemeData>(
          themes: [
            WidgetbookTheme(name: 'Light', data: AppTheme.light),
            WidgetbookTheme(name: 'Dark', data: AppTheme.dark),
          ],
          themeBuilder: (context, theme, child) => Theme(
            data: theme,
            child: SkeletonizerConfig(
              data: SkeletonizerConfigData(brightness: theme.brightness),
              child: Material(
                color: theme.scaffoldBackgroundColor,
                textStyle: theme.textTheme.bodyMedium,
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
