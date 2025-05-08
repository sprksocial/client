import 'package:freezed_annotation/freezed_annotation.dart';

part 'label_models.freezed.dart';
part 'label_models.g.dart';

@freezed
class LabelValue with _$LabelValue {
  const factory LabelValue({
    required String value,
    required String identifier,
    required String blurs,
    required String severity,
    required String defaultSetting,
    @Default(false) bool adultOnly,
    required List<LabelLocale> locales,
  }) = _LabelValue;

  factory LabelValue.fromJson(Map<String, dynamic> json) => _$LabelValueFromJson(json);
}

@freezed
class LabelLocale with _$LabelLocale {
  const factory LabelLocale({
    required String lang,
    required String name,
    required String description,
  }) = _LabelLocale;

  factory LabelLocale.fromJson(Map<String, dynamic> json) => _$LabelLocaleFromJson(json);
}

@freezed
class LabelInfo with _$LabelInfo {
  const factory LabelInfo({
    required String did,
    String? displayName,
    String? description,
    String? avatar,
  }) = _LabelInfo;

  factory LabelInfo.fromJson(Map<String, dynamic> json) => _$LabelInfoFromJson(json);
}

@freezed
class LabelValueListResponse with _$LabelValueListResponse {
  const factory LabelValueListResponse({
    required List<String> values,
  }) = _LabelValueListResponse;

  factory LabelValueListResponse.fromJson(Map<String, dynamic> json) => _$LabelValueListResponseFromJson(json);
}

@freezed
class LabelValueDefinitionsResponse with _$LabelValueDefinitionsResponse {
  const factory LabelValueDefinitionsResponse({
    required List<LabelValue> definitions,
  }) = _LabelValueDefinitionsResponse;

  factory LabelValueDefinitionsResponse.fromJson(Map<String, dynamic> json) => _$LabelValueDefinitionsResponseFromJson(json);
}

@freezed
class LabelerInfoResponse with _$LabelerInfoResponse {
  const factory LabelerInfoResponse({
    required String did,
    String? displayName,
    String? description,
    String? avatar,
  }) = _LabelerInfoResponse;

  factory LabelerInfoResponse.fromJson(Map<String, dynamic> json) => _$LabelerInfoResponseFromJson(json);
}

@freezed
class LabelDetail with _$LabelDetail {
  const factory LabelDetail({
    required String val,
    required String uri,
    String? cid,
    String? src,
    DateTime? cts,
    DateTime? exp,
  }) = _LabelDetail;

  factory LabelDetail.fromJson(Map<String, dynamic> json) => _$LabelDetailFromJson(json);
}

@freezed
class QueryLabelsResponse with _$QueryLabelsResponse {
  const factory QueryLabelsResponse({
    required List<LabelDetail> labels,
    String? cursor,
  }) = _QueryLabelsResponse;

  factory QueryLabelsResponse.fromJson(Map<String, dynamic> json) => _$QueryLabelsResponseFromJson(json);
} 