import 'package:atproto_core/atproto_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/messages/data/models/message_models.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/messages/providers/conversation_provider.dart';
import 'package:sparksocial/src/features/messages/providers/embed_input_state.dart';

part 'embed_input_provider.g.dart';

@riverpod
class EmbedInput extends _$EmbedInput {
  late String did;

  @override
  EmbedInputState build(TextEditingController textController, ImagePicker imagePicker, String otherDid) {
    did = otherDid;
    ref.onDispose(() {
      textController.dispose();
    });
    textController.addListener(() {
      updateCanSubmit();
    });
    return EmbedInputState(textController: textController, imagePicker: imagePicker);
  }

  late final _logger = GetIt.instance.get<LogService>().getLogger('EmbedInputNotifier');

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

  Future<void> pickMedia(BuildContext context) async {
    if (state.isPosting) return;

    const maxImages = 4;
    final currentImageCount = state.selectedImages.length;
    if (currentImageCount >= maxImages) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You can select up to $maxImages files.')));
      return;
    }

    try {
      final List<XFile> pickedFiles = await state.imagePicker.pickMultipleMedia(limit: maxImages - currentImageCount);
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
    state.selectedImages.removeAt(index);
    updateCanSubmit();
  }

  Future<Message> submitMessage({
    required String otherDid,
    required String message, // this should be optional
    List<Embed>? embeds, // this should be a single embed or null
  }) async {
    if (!state.canSubmit || state.isPosting) throw Exception('Cannot submit message: either not ready or already posting');

    state = state.copyWith(isPosting: true);

    try {
      final response = await ref.read(conversationProvider(did).notifier).sendMessage(otherDid, message, embed: embeds);

      state.textController.clear();
      updateCanSubmit();
      state = state.copyWith(isPosting: false, selectedImages: []);
      return response;
    } catch (e) {
      // If posting fails, just reset isPosting but keep the form data
      state = state.copyWith(isPosting: false);

      // Log the error for debugging
      _logger.e('Error posting embed: $e');

      rethrow;
    }
  }
}
