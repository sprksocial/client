// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UploadTaskImpl _$$UploadTaskImplFromJson(Map<String, dynamic> json) =>
    _$UploadTaskImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      status: $enumDecodeNullable(_$UploadStatusEnumMap, json['status']) ??
          UploadStatus.idle,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$UploadTaskImplToJson(_$UploadTaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'status': _$UploadStatusEnumMap[instance.status]!,
      'errorMessage': instance.errorMessage,
    };

const _$UploadStatusEnumMap = {
  UploadStatus.idle: 'idle',
  UploadStatus.uploading: 'uploading',
  UploadStatus.completed: 'completed',
  UploadStatus.error: 'error',
};
