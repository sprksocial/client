// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IdentityInfoImpl _$$IdentityInfoImplFromJson(Map<String, dynamic> json) =>
    _$IdentityInfoImpl(
      did: json['did'] as String,
      handle: json['handle'] as String,
      didDocument: json['didDocument'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$IdentityInfoImplToJson(_$IdentityInfoImpl instance) =>
    <String, dynamic>{
      'did': instance.did,
      'handle': instance.handle,
      'didDocument': instance.didDocument,
    };
