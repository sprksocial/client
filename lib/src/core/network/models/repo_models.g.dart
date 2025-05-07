// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecordResponseImpl _$$RecordResponseImplFromJson(Map<String, dynamic> json) =>
    _$RecordResponseImpl(
      uri: json['uri'] as String,
      cid: json['cid'] as String,
      value: json['value'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$RecordResponseImplToJson(
        _$RecordResponseImpl instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'cid': instance.cid,
      'value': instance.value,
    };

_$BlobResponseImpl _$$BlobResponseImplFromJson(Map<String, dynamic> json) =>
    _$BlobResponseImpl(
      blob: json['blob'] as String,
      blobRef: json['blobRef'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$BlobResponseImplToJson(_$BlobResponseImpl instance) =>
    <String, dynamic>{
      'blob': instance.blob,
      'blobRef': instance.blobRef,
    };

_$RecordsListResponseImpl _$$RecordsListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$RecordsListResponseImpl(
      records: (json['records'] as List<dynamic>)
          .map((e) => RecordItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      cursor: json['cursor'] as String?,
    );

Map<String, dynamic> _$$RecordsListResponseImplToJson(
        _$RecordsListResponseImpl instance) =>
    <String, dynamic>{
      'records': instance.records,
      'cursor': instance.cursor,
    };

_$RecordItemImpl _$$RecordItemImplFromJson(Map<String, dynamic> json) =>
    _$RecordItemImpl(
      uri: json['uri'] as String,
      cid: json['cid'] as String,
      value: json['value'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$RecordItemImplToJson(_$RecordItemImpl instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'cid': instance.cid,
      'value': instance.value,
    };
