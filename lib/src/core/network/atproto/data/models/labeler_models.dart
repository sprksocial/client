import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sprk_poptart/so/sprk/labeler/defs.dart' as labeler_defs;

part 'labeler_models.freezed.dart';
part 'labeler_models.g.dart';

typedef LabelerView = labeler_defs.LabelerView;
typedef LabelerViewDetailed = labeler_defs.LabelerViewDetailed;
typedef LabelerViewerState = labeler_defs.LabelerViewerState;
typedef LabelerPolicies = labeler_defs.LabelerPolicies;

const defaultLabels = [
  '!hide',
  '!no-promote',
  '!warn',
  '!no-unauthenticated',
  'dmca-violation',
  'doxxing',
  'porn',
  'sexual',
  'nudity',
  'nsfl',
  'gore',
];

enum Blurs {
  content('content'),
  media('media'),
  none('none');

  final String value;
  const Blurs(this.value);

  static Blurs fromValue(String value) {
    if (Blurs.values.any((e) => e.value == value)) {
      return Blurs.values.firstWhere((e) => e.value == value);
    }
    throw Exception('Invalid blur: $value');
  }
}

enum Severity {
  alert('alert'),
  inform('inform'),
  none('none');

  final String value;
  const Severity(this.value);

  static Severity fromValue(String value) {
    if (Severity.values.any((e) => e.value == value)) {
      return Severity.values.firstWhere((e) => e.value == value);
    }
    throw Exception('Invalid severity: $value');
  }
}

enum Setting {
  hide('hide'),
  warn('warn'),
  ignore('ignore');

  final String value;
  const Setting(this.value);

  static Setting fromValue(String value) {
    if (Setting.values.any((e) => e.value == value)) {
      return Setting.values.firstWhere((e) => e.value == value);
    }
    throw Exception('Invalid default setting: $value');
  }
}

@freezed
abstract class LabelPreference with _$LabelPreference {
  @JsonSerializable(explicitToJson: true)
  factory LabelPreference({
    required String value,
    required Blurs blurs,
    required Severity severity,
    required Setting defaultSetting,
    required Setting setting,
    required bool adultOnly,
  }) = _LabelPreference;
  const LabelPreference._();

  factory LabelPreference.fromJson(Map<String, dynamic> json) =>
      _$LabelPreferenceFromJson(json);
}
