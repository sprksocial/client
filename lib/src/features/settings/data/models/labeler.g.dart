// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'labeler.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LabelerImpl _$$LabelerImplFromJson(Map<String, dynamic> json) =>
    _$LabelerImpl(
      did: json['did'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
      labelDefinitions:
          (json['labelDefinitions'] as Map<String, dynamic>?)?.map(
                (k, e) =>
                    MapEntry(k, LabelValue.fromJson(e as Map<String, dynamic>)),
              ) ??
              const {},
    );

Map<String, dynamic> _$$LabelerImplToJson(_$LabelerImpl instance) =>
    <String, dynamic>{
      'did': instance.did,
      'displayName': instance.displayName,
      'description': instance.description,
      'avatar': instance.avatar,
      'labelDefinitions': instance.labelDefinitions,
    };
