// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchStateImpl _$$SearchStateImplFromJson(Map<String, dynamic> json) =>
    _$SearchStateImpl(
      isLoading: json['isLoading'] as bool? ?? false,
      searchResults: (json['searchResults'] as List<dynamic>?)
              ?.map((e) => ProfileView.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      error: json['error'] as String?,
      query: json['query'] as String? ?? '',
    );

Map<String, dynamic> _$$SearchStateImplToJson(_$SearchStateImpl instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'searchResults': instance.searchResults,
      'error': instance.error,
      'query': instance.query,
    };
