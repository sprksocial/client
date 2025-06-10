// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'labeler_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LabelPreferenceImpl _$$LabelPreferenceImplFromJson(
  Map<String, dynamic> json,
) => _$LabelPreferenceImpl(
  value: json['value'] as String,
  blurs: $enumDecode(_$BlursEnumMap, json['blurs']),
  severity: $enumDecode(_$SeverityEnumMap, json['severity']),
  defaultSetting: $enumDecode(_$SettingEnumMap, json['defaultSetting']),
  setting: $enumDecode(_$SettingEnumMap, json['setting']),
  adultOnly: json['adultOnly'] as bool,
);

Map<String, dynamic> _$$LabelPreferenceImplToJson(
  _$LabelPreferenceImpl instance,
) => <String, dynamic>{
  'value': instance.value,
  'blurs': _$BlursEnumMap[instance.blurs]!,
  'severity': _$SeverityEnumMap[instance.severity]!,
  'defaultSetting': _$SettingEnumMap[instance.defaultSetting]!,
  'setting': _$SettingEnumMap[instance.setting]!,
  'adultOnly': instance.adultOnly,
};

const _$BlursEnumMap = {
  Blurs.content: 'content',
  Blurs.media: 'media',
  Blurs.none: 'none',
};

const _$SeverityEnumMap = {
  Severity.alert: 'alert',
  Severity.inform: 'inform',
  Severity.none: 'none',
};

const _$SettingEnumMap = {
  Setting.hide: 'hide',
  Setting.warn: 'warn',
  Setting.ignore: 'ignore',
};

_$LabelerViewImpl _$$LabelerViewImplFromJson(Map<String, dynamic> json) =>
    _$LabelerViewImpl(
      uri: const AtUriConverter().fromJson(json['uri'] as String),
      cid: json['cid'] as String,
      creator: ProfileView.fromJson(json['creator'] as Map<String, dynamic>),
      indexedAt: DateTime.parse(json['indexedAt'] as String),
      likeCount: (json['likeCount'] as num?)?.toInt(),
      lookCount: (json['lookCount'] as num?)?.toInt(),
      labelerViewer: json['labelerViewer'] == null
          ? null
          : LabelerViewerState.fromJson(
              json['labelerViewer'] as Map<String, dynamic>,
            ),
      labels: (json['labels'] as List<dynamic>?)
          ?.map((e) => Label.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$LabelerViewImplToJson(_$LabelerViewImpl instance) =>
    <String, dynamic>{
      'uri': const AtUriConverter().toJson(instance.uri),
      'cid': instance.cid,
      'creator': instance.creator.toJson(),
      'indexedAt': instance.indexedAt.toIso8601String(),
      'likeCount': instance.likeCount,
      'lookCount': instance.lookCount,
      'labelerViewer': instance.labelerViewer?.toJson(),
      'labels': instance.labels?.map((e) => e.toJson()).toList(),
    };

_$LabelerViewDetailedImpl _$$LabelerViewDetailedImplFromJson(
  Map<String, dynamic> json,
) => _$LabelerViewDetailedImpl(
  uri: const AtUriConverter().fromJson(json['uri'] as String),
  cid: json['cid'] as String,
  creator: ProfileView.fromJson(json['creator'] as Map<String, dynamic>),
  indexedAt: DateTime.parse(json['indexedAt'] as String),
  likeCount: (json['likeCount'] as num?)?.toInt(),
  lookCount: (json['lookCount'] as num?)?.toInt(),
  labelerViewer: json['labelerViewer'] == null
      ? null
      : LabelerViewerState.fromJson(
          json['labelerViewer'] as Map<String, dynamic>,
        ),
  policies: json['policies'] == null
      ? null
      : LabelerPolicies.fromJson(json['policies'] as Map<String, dynamic>),
  labels: (json['labels'] as List<dynamic>?)
      ?.map((e) => Label.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$LabelerViewDetailedImplToJson(
  _$LabelerViewDetailedImpl instance,
) => <String, dynamic>{
  'uri': const AtUriConverter().toJson(instance.uri),
  'cid': instance.cid,
  'creator': instance.creator.toJson(),
  'indexedAt': instance.indexedAt.toIso8601String(),
  'likeCount': instance.likeCount,
  'lookCount': instance.lookCount,
  'labelerViewer': instance.labelerViewer?.toJson(),
  'policies': instance.policies?.toJson(),
  'labels': instance.labels?.map((e) => e.toJson()).toList(),
};

_$LabelerViewerStateImpl _$$LabelerViewerStateImplFromJson(
  Map<String, dynamic> json,
) => _$LabelerViewerStateImpl(
  like: const AtUriConverter().fromJson(json['like'] as String),
  look: const AtUriConverter().fromJson(json['look'] as String),
);

Map<String, dynamic> _$$LabelerViewerStateImplToJson(
  _$LabelerViewerStateImpl instance,
) => <String, dynamic>{
  'like': const AtUriConverter().toJson(instance.like),
  'look': const AtUriConverter().toJson(instance.look),
};

_$LabelerPoliciesImpl _$$LabelerPoliciesImplFromJson(
  Map<String, dynamic> json,
) => _$LabelerPoliciesImpl(
  labelValues: (json['labelValues'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  labelValueDefinitions: (json['labelValueDefinitions'] as List<dynamic>?)
      ?.map((e) => LabelValueDefinition.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$LabelerPoliciesImplToJson(
  _$LabelerPoliciesImpl instance,
) => <String, dynamic>{
  'labelValues': instance.labelValues,
  'labelValueDefinitions': instance.labelValueDefinitions
      ?.map((e) => e.toJson())
      .toList(),
};
