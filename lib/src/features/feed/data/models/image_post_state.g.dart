// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_post_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImagePostStateImpl _$$ImagePostStateImplFromJson(Map<String, dynamic> json) =>
    _$ImagePostStateImpl(
      index: (json['index'] as num).toInt(),
      imageUrls:
          (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      imageAlts:
          (json['imageAlts'] as List<dynamic>).map((e) => e as String).toList(),
      username: json['username'] as String,
      description: json['description'] as String,
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      profileImageUrl: json['profileImageUrl'] as String?,
      authorDid: json['authorDid'] as String,
      isLiked: json['isLiked'] as bool? ?? false,
      isSprk: json['isSprk'] as bool? ?? false,
      postUri: json['postUri'] as String,
      postCid: json['postCid'] as String,
      isVisible: json['isVisible'] as bool? ?? false,
      disableBackgroundBlur: json['disableBackgroundBlur'] as bool? ?? false,
      isDescriptionExpanded: json['isDescriptionExpanded'] as bool? ?? false,
      currentCarouselIndex:
          (json['currentCarouselIndex'] as num?)?.toInt() ?? 0,
      showComments: json['showComments'] as bool? ?? false,
    );

Map<String, dynamic> _$$ImagePostStateImplToJson(
        _$ImagePostStateImpl instance) =>
    <String, dynamic>{
      'index': instance.index,
      'imageUrls': instance.imageUrls,
      'imageAlts': instance.imageAlts,
      'username': instance.username,
      'description': instance.description,
      'hashtags': instance.hashtags,
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'bookmarkCount': instance.bookmarkCount,
      'shareCount': instance.shareCount,
      'profileImageUrl': instance.profileImageUrl,
      'authorDid': instance.authorDid,
      'isLiked': instance.isLiked,
      'isSprk': instance.isSprk,
      'postUri': instance.postUri,
      'postCid': instance.postCid,
      'isVisible': instance.isVisible,
      'disableBackgroundBlur': instance.disableBackgroundBlur,
      'isDescriptionExpanded': instance.isDescriptionExpanded,
      'currentCarouselIndex': instance.currentCarouselIndex,
      'showComments': instance.showComments,
    };
