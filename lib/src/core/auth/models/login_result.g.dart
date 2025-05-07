// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginResultImpl _$$LoginResultImplFromJson(Map<String, dynamic> json) =>
    _$LoginResultImpl(
      status: $enumDecode(_$LoginStatusEnumMap, json['status']),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$LoginResultImplToJson(_$LoginResultImpl instance) =>
    <String, dynamic>{
      'status': _$LoginStatusEnumMap[instance.status]!,
      'error': instance.error,
    };

const _$LoginStatusEnumMap = {
  LoginStatus.success: 'success',
  LoginStatus.failed: 'failed',
  LoginStatus.codeRequired: 'codeRequired',
};
