import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'embed_input_state.freezed.dart';

@freezed
class EmbedInputState with _$EmbedInputState {
  const factory EmbedInputState({
    @Default(false) bool canSubmit,
    @Default(false) bool isPosting,
    @Default([]) List<XFile> selectedImages,
    required TextEditingController textController,
    required ImagePicker imagePicker,
  }) = _EmbedInputState;
}
