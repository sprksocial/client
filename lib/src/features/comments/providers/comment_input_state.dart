import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spark/src/features/posting/models/mention_controller.dart';

part 'comment_input_state.freezed.dart';

@freezed
abstract class CommentInputState with _$CommentInputState {
  const factory CommentInputState({
    required TextEditingController textController,
    required ImagePicker imagePicker,
    required MentionController mentionController,
    @Default(false) bool canSubmit,
    @Default(false) bool isPosting,
    @Default([]) List<XFile> selectedImages,
    @Default({}) Map<String, String> altTexts,
  }) = _CommentInputState;
}
