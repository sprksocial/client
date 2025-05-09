// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FacetImpl _$$FacetImplFromJson(Map<String, dynamic> json) => _$FacetImpl(
      index: FacetIndex.fromJson(json['index'] as Map<String, dynamic>),
      features: (json['features'] as List<dynamic>)
          .map((e) => FacetFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$FacetImplToJson(_$FacetImpl instance) =>
    <String, dynamic>{
      'index': instance.index,
      'features': instance.features,
    };

_$FacetIndexImpl _$$FacetIndexImplFromJson(Map<String, dynamic> json) =>
    _$FacetIndexImpl(
      byteStart: (json['byteStart'] as num).toInt(),
      byteEnd: (json['byteEnd'] as num).toInt(),
    );

Map<String, dynamic> _$$FacetIndexImplToJson(_$FacetIndexImpl instance) =>
    <String, dynamic>{
      'byteStart': instance.byteStart,
      'byteEnd': instance.byteEnd,
    };

_$MentionFeatureImpl _$$MentionFeatureImplFromJson(Map<String, dynamic> json) =>
    _$MentionFeatureImpl(
      did: json['did'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$MentionFeatureImplToJson(
        _$MentionFeatureImpl instance) =>
    <String, dynamic>{
      'did': instance.did,
      'runtimeType': instance.$type,
    };

_$LinkFeatureImpl _$$LinkFeatureImplFromJson(Map<String, dynamic> json) =>
    _$LinkFeatureImpl(
      uri: json['uri'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$LinkFeatureImplToJson(_$LinkFeatureImpl instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'runtimeType': instance.$type,
    };

_$TagFeatureImpl _$$TagFeatureImplFromJson(Map<String, dynamic> json) =>
    _$TagFeatureImpl(
      tag: json['tag'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$TagFeatureImplToJson(_$TagFeatureImpl instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'runtimeType': instance.$type,
    };
