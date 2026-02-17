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
  String get buttonDelete => 'Delete';

  @override
  String get buttonBlock => 'Block';

  @override
  String get buttonUnblock => 'Unblock';

  @override
  String get buttonReport => 'Report';

  @override
  String get buttonReportProfile => 'Report Profile';

  @override
  String get buttonClose => 'Close';

  @override
  String get inputErrorRequired => 'This field is required';

  @override
  String get inputErrorEmail => 'Please enter a valid email address';

  @override
  String get loading => 'Loading...';

  @override
  String get searchPlaceholder => 'Search...';
}
