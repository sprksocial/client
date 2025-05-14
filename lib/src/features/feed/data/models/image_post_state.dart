import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_post_state.freezed.dart';
part 'image_post_state.g.dart';

@freezed
class ImagePostState with _$ImagePostState {
  const factory ImagePostState({
    required int index,
    required List<String> imageUrls,
    required List<String> imageAlts,
    required String username,
    required String description,
    @Default([]) List<String> hashtags,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    @Default(0) int bookmarkCount,
    @Default(0) int shareCount,
    String? profileImageUrl,
    required String authorDid,
    @Default(false) bool isLiked,
    @Default(false) bool isSprk,
    required String postUri,
    required String postCid,
    @Default(false) bool isVisible,
    @Default(false) bool disableBackgroundBlur,
    @Default(false) bool isDescriptionExpanded,
    @Default(0) int currentCarouselIndex,
    @Default(false) bool showComments,
  }) = _ImagePostState;

  factory ImagePostState.fromJson(Map<String, dynamic> json) => _$ImagePostStateFromJson(json);
} 