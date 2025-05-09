// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blob_reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BlobReferenceImpl _$$BlobReferenceImplFromJson(Map<String, dynamic> json) =>
    _$BlobReferenceImpl(
      type: json[r'$type'] as String,
      mimeType: json['mimeType'] as String,
      size: (json['size'] as num).toInt(),
      ref: json['ref'] as String,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$$BlobReferenceImplToJson(_$BlobReferenceImpl instance) =>
    <String, dynamic>{
      r'$type': instance.type,
      'mimeType': instance.mimeType,
      'size': instance.size,
      'ref': instance.ref,
      'createdAt': instance.createdAt,
    };
