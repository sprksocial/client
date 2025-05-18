import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

part 'image_review_state.freezed.dart';

@freezed
class ImageReviewState with _$ImageReviewState {
  const factory ImageReviewState({
    required List<XFile> imageFiles,
    required Map<String, String> altTexts,
    required int currentPage,
    @Default('') String description,
    @Default(false) bool isPosting,
  }) = _ImageReviewState;

  factory ImageReviewState.initial(List<XFile> initialImages) {
    final Map<String, String> initialAltTexts = {};
    for (final image in initialImages) {
      initialAltTexts[image.path] = '';
    }
    
    return ImageReviewState(
      imageFiles: List<XFile>.from(initialImages),
      altTexts: initialAltTexts,
      currentPage: 0,
    );
  }
} 