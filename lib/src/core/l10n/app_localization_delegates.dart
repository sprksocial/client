import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' as editor_material;
import 'package:spark/src/core/l10n/app_localizations.dart';

/// Supports both Spark's SDK widgets and the editor's standalone UI packages.
const appLocalizationDelegates = <LocalizationsDelegate<dynamic>>[
  ...AppLocalizations.localizationsDelegates,
  ...editor_material.GlobalMaterialLocalizations.delegates,
];
