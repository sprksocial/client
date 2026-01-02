// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get buttonSave => 'Save';

  @override
  String get inputErrorRequired => 'This field is required';

  @override
  String get inputErrorEmail => 'Please enter a valid email address';

  @override
  String get loading => 'Loading...';

  @override
  String get searchPlaceholder => 'Search...';

  @override
  String get optionsPanelDelete => 'Delete';

  @override
  String get optionsPanelBlock => 'Block';

  @override
  String get optionsPanelUnblock => 'Unblock';

  @override
  String get optionsPanelReport => 'Report';

  @override
  String get optionsPanelReportProfile => 'Report Profile';

  @override
  String get optionsPanelClose => 'Close';
}
