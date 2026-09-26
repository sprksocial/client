import 'package:material_ui/material_ui.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

/// App translations and the standalone Material, Cupertino, and widget delegates.
const appLocalizationDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];
