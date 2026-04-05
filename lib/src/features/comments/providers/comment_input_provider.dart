import 'package:atproto_core/atproto_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/utils/text_formatter.dart';
import 'package:spark/src/core/utils/logging/logging.dart';
import 'package:spark/src/features/comments/providers/comment_input_state.dart';
import 'package:spark/src/features/comments/providers/comments_page_provider.dart';
import 'package:spark/src/features/posting/models/mention.dart';
import 'package:spark/src/features/posting/models/mention_controller.dart';

part 'comment_input_provider.g.dart';

@riverpod
class CommentInput extends _$CommentInput {
  @override
  CommentInputState build(ImagePicker imagePicker, {String initialText = ''}) {
    final mentionController = MentionController(text: initialText);
    final mentionTextController = mentionController.textController;
    mentionTextController.addListener(updateCanSubmit);

    ref.onDispose(() {
      mentionTextController.removeListener(updateCanSubmit);
      mentionController.dispose();
    });

    return CommentInputState(
      textController: mentionTextController,
      imagePicker: imagePicker,
      mentionController: mentionController,
      canSubmit: mentionTextController.text.trim().isNotEmpty,
    );
  }

  late final SparkLogger _logger = GetIt.instance.get<LogService>().getLogger(
    'CommentInputNotifier',
  );

  void updateCanSubmit() {
    final textIsNotEmpty = state.textController.text.trim().isNotEmpty;
    final imagesAreSelected = state.selectedImages.isNotEmpty;
    final newCanSubmit =
        textIsNotEmpty ||
        imagesAreSelected; // Can submit if text OR images exist

    if (newCanSubmit != state.canSubmit) {
      state = state.copyWith(canSubmit: newCanSubmit);
    }
  }

  void insertEmoji(String emoji) {
    if (state.isPosting) return;

    final controller = state.textController;
    final currentText = controller.text;
    final selection = controller.selection;
    final hasSelection = selection.start >= 0 && selection.end >= 0;
    final start = hasSelection ? selection.start : currentText.length;
    final end = hasSelection ? selection.end : currentText.length;
    final newText = currentText.replaceRange(start, end, emoji);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
  }

  Future<void> pickImages(BuildContext context) async {
    if (state.isPosting) return;

    const maxImages = 1;
    final currentImageCount = state.selectedImages.length;
    if (currentImageCount >= maxImages) {
      if (!context.mounted) return;
      return;
    }

    try {
      final pickedFile = await state.imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        state = state.copyWith(selectedImages: [pickedFile]);
        updateCanSubmit();
      }
    } catch (e) {
      _logger.e('Error picking image: $e');
    }
  }

  void removeImage(int index) {
    if (state.isPosting) return;
    final selectedImages = List<XFile>.from(state.selectedImages);
    final removed = selectedImages.removeAt(index);
    final altTexts = Map<String, String>.from(state.altTexts)
      ..remove(removed.path);
    state = state.copyWith(selectedImages: selectedImages, altTexts: altTexts);
    updateCanSubmit();
  }

  Future<void> submitComment({
    required String parentCid,
    required String parentUri,
    required bool isSprk,
    required String? rootCid,
    required String? rootUri,
  }) async {
    final hasContent =
        state.textController.text.trim().isNotEmpty ||
        state.selectedImages.isNotEmpty;
    if (!hasContent || state.isPosting) return;
    final trayNotifier = ref.read(
      commentsPageProvider(postUri: AtUri.parse(parentUri)).notifier,
    );
    final rawText = state.textController.text;
    final text = rawText.trim();
    final imagesToUpload = List<XFile>.from(state.selectedImages);

    state = state.copyWith(isPosting: true);

    try {
      final facets = _buildTrimmedMentionFacets(
        rawText: rawText,
        trimmedText: text,
      );
      await trayNotifier.postComment(
        text,
        parentCid,
        parentUri,
        rootCid: rootCid,
        rootUri: rootUri,
        imageFiles: imagesToUpload,
        altTexts: state.altTexts,
        facets: facets,
      );

      state.mentionController.clear();
      state = state.copyWith(
        canSubmit: false,
        isPosting: false,
        selectedImages: [],
        altTexts: {},
      );
    } catch (e) {
      // If posting fails, just reset isPosting but keep the form data
      state = state.copyWith(isPosting: false);

      // Log the error for debugging
      _logger.e('Error posting comment: $e');

      rethrow;
    }
  }

  void updateAltText(String imagePath, String altText) {
    state = state.copyWith(altTexts: {...state.altTexts, imagePath: altText});
  }

  List<Facet> _buildTrimmedMentionFacets({
    required String rawText,
    required String trimmedText,
  }) {
    if (trimmedText.isEmpty || state.mentionController.mentions.isEmpty) {
      return const [];
    }

    if (rawText == trimmedText) {
      return state.mentionController.buildFacets();
    }

    final leadingTrimmedText = rawText.trimLeft();
    final leadingTrimmedChars = rawText.length - leadingTrimmedText.length;
    final leadingTrimmedBytes = TextFormatter.charIndexToByteIndex(
      rawText,
      leadingTrimmedChars,
    );
    final trimmedByteLength = TextFormatter.byteLength(trimmedText);
    final trimmedEndByte = leadingTrimmedBytes + trimmedByteLength;

    final adjustedMentions = state.mentionController.mentions
        .where(
          (mention) =>
              mention.byteStart >= leadingTrimmedBytes &&
              mention.byteEnd <= trimmedEndByte,
        )
        .map(
          (mention) => Mention(
            handle: mention.handle,
            did: mention.did,
            byteStart: mention.byteStart - leadingTrimmedBytes,
            byteEnd: mention.byteEnd - leadingTrimmedBytes,
          ),
        )
        .toList(growable: false);

    return TextFormatter.buildMentionFacets(adjustedMentions);
  }
}
