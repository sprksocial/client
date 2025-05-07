// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'label_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LabelValueImpl _$$LabelValueImplFromJson(Map<String, dynamic> json) =>
    _$LabelValueImpl(
      value: json['value'] as String,
      identifier: json['identifier'] as String,
      blurs: json['blurs'] as String,
      severity: json['severity'] as String,
      defaultSetting: json['defaultSetting'] as String,
      adultOnly: json['adultOnly'] as bool? ?? false,
      locales: (json['locales'] as List<dynamic>)
          .map((e) => LabelLocale.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$LabelValueImplToJson(_$LabelValueImpl instance) =>
    <String, dynamic>{
      'value': instance.value,
      'identifier': instance.identifier,
      'blurs': instance.blurs,
      'severity': instance.severity,
      'defaultSetting': instance.defaultSetting,
      'adultOnly': instance.adultOnly,
      'locales': instance.locales,
    };

_$LabelLocaleImpl _$$LabelLocaleImplFromJson(Map<String, dynamic> json) =>
    _$LabelLocaleImpl(
      lang: json['lang'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$$LabelLocaleImplToJson(_$LabelLocaleImpl instance) =>
    <String, dynamic>{
      'lang': instance.lang,
      'name': instance.name,
      'description': instance.description,
    };

_$LabelInfoImpl _$$LabelInfoImplFromJson(Map<String, dynamic> json) =>
    _$LabelInfoImpl(
      did: json['did'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$$LabelInfoImplToJson(_$LabelInfoImpl instance) =>
    <String, dynamic>{
      'did': instance.did,
      'displayName': instance.displayName,
      'description': instance.description,
      'avatar': instance.avatar,
    };

_$LabelValueListResponseImpl _$$LabelValueListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$LabelValueListResponseImpl(
      values:
          (json['values'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$LabelValueListResponseImplToJson(
        _$LabelValueListResponseImpl instance) =>
    <String, dynamic>{
      'values': instance.values,
    };

_$LabelValueDefinitionsResponseImpl
    _$$LabelValueDefinitionsResponseImplFromJson(Map<String, dynamic> json) =>
        _$LabelValueDefinitionsResponseImpl(
          definitions: (json['definitions'] as List<dynamic>)
              .map((e) => LabelValue.fromJson(e as Map<String, dynamic>))
              .toList(),
        );

Map<String, dynamic> _$$LabelValueDefinitionsResponseImplToJson(
        _$LabelValueDefinitionsResponseImpl instance) =>
    <String, dynamic>{
      'definitions': instance.definitions,
    };

_$LabelerInfoResponseImpl _$$LabelerInfoResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$LabelerInfoResponseImpl(
      did: json['did'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$$LabelerInfoResponseImplToJson(
        _$LabelerInfoResponseImpl instance) =>
    <String, dynamic>{
      'did': instance.did,
      'displayName': instance.displayName,
      'description': instance.description,
      'avatar': instance.avatar,
    };

_$LabelDetailImpl _$$LabelDetailImplFromJson(Map<String, dynamic> json) =>
    _$LabelDetailImpl(
      val: json['val'] as String,
      uri: json['uri'] as String,
      cid: json['cid'] as String?,
      src: json['src'] as String?,
      cts: json['cts'] == null ? null : DateTime.parse(json['cts'] as String),
      exp: json['exp'] == null ? null : DateTime.parse(json['exp'] as String),
    );

Map<String, dynamic> _$$LabelDetailImplToJson(_$LabelDetailImpl instance) =>
    <String, dynamic>{
      'val': instance.val,
      'uri': instance.uri,
      'cid': instance.cid,
      'src': instance.src,
      'cts': instance.cts?.toIso8601String(),
      'exp': instance.exp?.toIso8601String(),
    };

_$QueryLabelsResponseImpl _$$QueryLabelsResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$QueryLabelsResponseImpl(
      labels: (json['labels'] as List<dynamic>)
          .map((e) => LabelDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      cursor: json['cursor'] as String?,
    );

Map<String, dynamic> _$$QueryLabelsResponseImplToJson(
        _$QueryLabelsResponseImpl instance) =>
    <String, dynamic>{
      'labels': instance.labels,
      'cursor': instance.cursor,
    };
