// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoPostImpl _$$VideoPostImplFromJson(Map<String, dynamic> json) =>
    _$VideoPostImpl(
      type: json[r'$type'] as String,
      text: json['text'] as String? ?? '',
      embed: VideoEmbed.fromJson(json['embed'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String,
      langs:
          (json['langs'] as List<dynamic>?)?.map((e) => e as String).toList(),
      labels: (json['labels'] as List<dynamic>?)
          ?.map((e) => LabelDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      facets: (json['facets'] as List<dynamic>?)
          ?.map((e) => Facet.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$VideoPostImplToJson(_$VideoPostImpl instance) =>
    <String, dynamic>{
      r'$type': instance.type,
      'text': instance.text,
      'embed': instance.embed,
      'createdAt': instance.createdAt,
      'langs': instance.langs,
      'labels': instance.labels,
      'tags': instance.tags,
      'facets': instance.facets,
    };
