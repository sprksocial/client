// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_embed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoEmbedImpl _$$VideoEmbedImplFromJson(Map<String, dynamic> json) =>
    _$VideoEmbedImpl(
      type: json[r'$type'] as String,
      video: BlobReference.fromJson(json['video'] as Map<String, dynamic>),
      alt: json['alt'] as String?,
    );

Map<String, dynamic> _$$VideoEmbedImplToJson(_$VideoEmbedImpl instance) =>
    <String, dynamic>{
      r'$type': instance.type,
      'video': instance.video,
      'alt': instance.alt,
    };
