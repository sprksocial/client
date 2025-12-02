import 'package:atproto/atproto.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/actor_models.dart';

part 'labeler_models.freezed.dart';
part 'labeler_models.g.dart';

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

  factory LabelPreference.fromJson(Map<String, dynamic> json) => _$LabelPreferenceFromJson(json);
}

@freezed
abstract class LabelerView with _$LabelerView {
  @JsonSerializable(explicitToJson: true)
  factory LabelerView({
    @AtUriConverter() required AtUri uri,
    required String cid,
    required ProfileView creator,
    required DateTime indexedAt,
    int? likeCount,
    LabelerViewerState? labelerViewer,
    List<Label>? labels,
  }) = _LabelerView;
  const LabelerView._();

  factory LabelerView.fromJson(Map<String, dynamic> json) => _$LabelerViewFromJson(json);
}

@freezed
abstract class LabelerViewDetailed with _$LabelerViewDetailed {
  @JsonSerializable(explicitToJson: true)
  factory LabelerViewDetailed({
    @AtUriConverter() required AtUri uri,
    required String cid,
    required ProfileView creator,
    required DateTime indexedAt,
    int? likeCount,
    LabelerViewerState? labelerViewer,
    LabelerPolicies? policies,
    List<Label>? labels,
  }) = _LabelerViewDetailed;
  const LabelerViewDetailed._();

  factory LabelerViewDetailed.fromJson(Map<String, dynamic> json) => _$LabelerViewDetailedFromJson(json);
}

@freezed
abstract class LabelerViewerState with _$LabelerViewerState {
  @JsonSerializable(explicitToJson: true)
  factory LabelerViewerState({@AtUriConverter() required AtUri like}) = _LabelerViewerState;
  const LabelerViewerState._();

  factory LabelerViewerState.fromJson(Map<String, dynamic> json) => _$LabelerViewerStateFromJson(json);
}

@freezed
abstract class LabelerPolicies with _$LabelerPolicies {
  @JsonSerializable(explicitToJson: true)
  factory LabelerPolicies({
    required List<String>
    labelValues, // knownValues (array of strings, optional): a set of suggested or common values for this field. Values are not limited to this set (aka, not a closed enum).
    List<LabelValueDefinition>? labelValueDefinitions,
  }) = _LabelerPolicies;
  const LabelerPolicies._();

  factory LabelerPolicies.fromJson(Map<String, dynamic> json) => _$LabelerPoliciesFromJson(json);
}
