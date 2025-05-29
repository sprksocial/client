import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/comments/providers/comment_input_state.dart';
import 'package:sparksocial/src/features/comments/providers/comments_tray_provider.dart';

part 'comment_input_provider.g.dart';

@riverpod
class CommentInput extends _$CommentInput {
  @override
  CommentInputState build(TextEditingController textController, ImagePicker imagePicker) {
    ref.onDispose(() {
      textController.dispose();
    });
    textController.addListener(() {
      updateCanSubmit();
    });
    return CommentInputState(textController: textController, imagePicker: imagePicker);
  }

  late final _logger = GetIt.instance.get<LogService>().getLogger('CommentInputNotifier');

  void updateCanSubmit() {
    final textIsNotEmpty = state.textController.text.trim().isNotEmpty;
    final imagesAreSelected = state.selectedImages.isNotEmpty;
    final newCanSubmit = textIsNotEmpty || imagesAreSelected; // Can submit if text OR images exist

    if (newCanSubmit != state.canSubmit) {
      state = state.copyWith(canSubmit: newCanSubmit);
    }
  }

  void insertEmoji(String emoji) {
    if (state.isPosting) return;

    final currentText = state.textController.text;
    final selection = state.textController.selection;

    if (selection.baseOffset < 0) {
      state.textController.text = currentText + emoji;
      state.textController.selection = TextSelection.collapsed(offset: currentText.length + emoji.length);
    } else {
      state.textController.text = currentText.replaceRange(selection.start, selection.end, emoji);
    }

    final newText = currentText.replaceRange(selection.start, selection.end, emoji);
    state.textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.baseOffset + emoji.length),
    );
  }

  Future<void> pickImages(BuildContext context) async {
    if (state.isPosting) return;

    const maxImages = 4;
    final currentImageCount = state.selectedImages.length;
    if (currentImageCount >= maxImages) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You can select up to $maxImages images.')));
      return;
    }

    try {
      final List<XFile> pickedFiles = await state.imagePicker.pickMultiImage(limit: maxImages - currentImageCount);
      if (pickedFiles.isNotEmpty) {
        state = state.copyWith(selectedImages: [...state.selectedImages, ...pickedFiles]);
        updateCanSubmit();
      }
    } catch (e) {
      _logger.e('Error picking images: $e');
    }
  }

  void removeImage(int index) {
    if (state.isPosting) return;
    final removed = state.selectedImages.removeAt(index);
    state.altTexts.remove(removed.path);
    updateCanSubmit();
  }

  Future<void> submitComment({
    required String parentCid,
    required String parentUri,
    required bool isSprk,
    required String? rootCid,
    required String? rootUri,
  }) async {
    if (!state.canSubmit || state.isPosting) return;
    final trayNotifier = ref.read(commentsTrayProvider(postUri: parentUri, postCid: parentCid, isSprk: isSprk).notifier);
    final text = state.textController.text.trim();
    final imagesToUpload = List<XFile>.from(state.selectedImages);

    state = state.copyWith(isPosting: true);

    trayNotifier.postComment(
      text,
      parentCid,
      parentUri,
      rootCid: rootCid,
      rootUri: rootUri,
      imageFiles: imagesToUpload,
      altTexts: state.altTexts,
    );

    state.textController.clear();
    state.selectedImages.clear();
    state.altTexts.clear();
    updateCanSubmit();
    state = state.copyWith(isPosting: false);
    trayNotifier.cancelReply();
  }

  void updateAltText(String imagePath, String altText) {
    state = state.copyWith(altTexts: {...state.altTexts, imagePath: altText});
  }
}
