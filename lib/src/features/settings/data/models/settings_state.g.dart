// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettingsStateImpl _$$SettingsStateImplFromJson(Map<String, dynamic> json) =>
    _$SettingsStateImpl(
      feedBlurEnabled: json['feedBlurEnabled'] as bool? ?? false,
      hideAdultContent: json['hideAdultContent'] as bool? ?? true,
      followedLabelers: (json['followedLabelers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      labelPreferences:
          (json['labelPreferences'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, Map<String, String>.from(e as Map)),
              ) ??
              const {},
      isLoading: json['isLoading'] as bool? ?? false,
      followingFeedEnabled: json['followingFeedEnabled'] as bool? ?? true,
      forYouFeedEnabled: json['forYouFeedEnabled'] as bool? ?? true,
      latestFeedEnabled: json['latestFeedEnabled'] as bool? ?? true,
      selectedFeedType: json['selectedFeedType'] == null
          ? FeedType.forYou
          : _feedTypeFromJson((json['selectedFeedType'] as num).toInt()),
    );

Map<String, dynamic> _$$SettingsStateImplToJson(_$SettingsStateImpl instance) =>
    <String, dynamic>{
      'feedBlurEnabled': instance.feedBlurEnabled,
      'hideAdultContent': instance.hideAdultContent,
      'followedLabelers': instance.followedLabelers,
      'labelPreferences': instance.labelPreferences,
      'isLoading': instance.isLoading,
      'followingFeedEnabled': instance.followingFeedEnabled,
      'forYouFeedEnabled': instance.forYouFeedEnabled,
      'latestFeedEnabled': instance.latestFeedEnabled,
      'selectedFeedType': _feedTypeToJson(instance.selectedFeedType),
    };
