import 'dart:io'; // Import for File

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:sparksocial/src/features/feed/data/models/comment_input_state.dart';
import 'package:sparksocial/src/features/feed/providers/comment_input_provider.dart';
import 'package:sparksocial/src/features/feed/providers/comments_tray_provider.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/images/alt_text_editor_dialog.dart';

import 'emoji_picker.dart';

class CommentInput extends ConsumerStatefulWidget {
  final String videoId;
  final String? replyingToUsername;
  // Video post info
  final String postCid;
  final String postUri;
  // For replies, parent may be different than the main post
  final String parentCid;
  final String parentUri;
  final String? rootCid;
  final String? rootUri;
  final FocusNode? focusNode;
  final bool isSprk;

  const CommentInput({
    super.key,
    required this.videoId,
    this.replyingToUsername,
    required this.postCid,
    required this.postUri,
    required this.parentCid,
    required this.parentUri,
    this.focusNode,
    required this.isSprk,
    this.rootCid,
    this.rootUri,
  });

  @override
  ConsumerState<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<CommentInput> {
  late CommentInputState _state;
  late CommentInputNotifier _notifier;
  @override
  void initState() {
    super.initState();
    final textController = TextEditingController();
    final imagePicker = ImagePicker();
    _state = ref.watch(commentInputNotifierProvider(textController, imagePicker));
    _notifier = ref.read(commentInputNotifierProvider(textController, imagePicker).notifier);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji Picker is always displayed at the top
          EmojiPicker(
            onEmojiSelected: _notifier.insertEmoji,
            isDarkMode: Theme.of(context).colorScheme.brightness == Brightness.dark,
          ),

          const SizedBox(height: 8),

          if (widget.replyingToUsername != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _ReplyingToNotice(widget: widget, inputBackgroundColor: Theme.of(context).colorScheme.surface, borderColor: Theme.of(context).colorScheme.outline, textColor: Theme.of(context).colorScheme.onSurface),
            ),

          // Updated input row with centered alignment
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(32)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _UserAvatar(textColor: Theme.of(context).colorScheme.onSurface),
                const SizedBox(width: 5),
                _AttachmentButton(state: _state, notifier: _notifier, context: context, borderColor: Theme.of(context).colorScheme.outline, textColor: Theme.of(context).colorScheme.onSurface),
                const SizedBox(width: 5),
                Expanded(
                  child: _TextField(widget: widget, state: _state, context: context, notifier: _notifier, textColor: Theme.of(context).colorScheme.onSurface, placeholderColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 128)),
                ),
              ],
            ),
          ),

          // Selected Images Preview (only show if images are selected)
          if (_state.selectedImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _SelectedImagesPreview(
                state: _state,
                notifier: _notifier,
              ),
            ),
        ],
      ),
    );
  }

}

class _ReplyingToNotice extends ConsumerWidget {
  const _ReplyingToNotice({
    required this.widget,
    required this.inputBackgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  final CommentInput widget;
  final Color inputBackgroundColor;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trayNotifier = ref.read(
      commentsTrayProvider(postUri: widget.postUri, postCid: widget.postCid, isSprk: widget.isSprk).notifier,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: inputBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(child: Text('Replying to ${widget.replyingToUsername}', style: TextStyle(color: textColor, fontSize: 13))),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: trayNotifier.cancelReply,
            icon: Icon(FluentIcons.dismiss_24_regular, size: 16, color: textColor),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({
    required this.textColor,
  });

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(color: Color(0xFF330072), shape: BoxShape.circle),
      child: const Center(child: Text('Y', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14))),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.widget,
    required this.state,
    required this.context,
    required this.notifier,
    required this.textColor,
    required this.placeholderColor,
  });

  final CommentInput widget;
  final CommentInputState state;
  final BuildContext context;
  final CommentInputNotifier notifier;
  final Color textColor;
  final Color placeholderColor;

  @override
  Widget build(BuildContext context) {
    String hint = 'Add a comment...';
    if (widget.replyingToUsername != null) {
      hint = 'Reply to ${widget.replyingToUsername}...';
    } else if (state.selectedImages.isNotEmpty && state.textController.text.isEmpty) {
      hint = 'Add a caption... (optional)';
    }

    return TextField(
      controller: state.textController,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: placeholderColor, fontSize: 14),
        filled: false,
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        suffixIcon:
            state.isPosting
                ? Container(
                  margin: const EdgeInsets.all(8),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                  ),
                )
                : IconButton(
                  icon: Icon(
                    FluentIcons.send_24_filled,
                    size: 20,
                    color: state.canSubmit ? Theme.of(context).colorScheme.primary : placeholderColor,
                  ),
                  onPressed:
                      state.canSubmit
                          ? () => notifier.submitComment(
                            parentCid: widget.parentCid,
                            parentUri: widget.parentUri,
                            isSprk: widget.isSprk,
                            rootCid: widget.rootCid,
                            rootUri: widget.rootUri,
                          )
                          : null,
                ),
      ),
      style: TextStyle(color: textColor, fontSize: 14),
      maxLines: 5,
      minLines: 1,
      textAlignVertical: TextAlignVertical.center,
      cursorColor: Theme.of(context).colorScheme.primary,
      enabled: !state.isPosting,
    );
  }
}

class _AttachmentButton extends StatelessWidget {
  const _AttachmentButton({
    required this.state,
    required this.notifier,
    required this.context,
    required this.borderColor,
    required this.textColor,
  });

  final CommentInputState state;
  final CommentInputNotifier notifier;
  final BuildContext context;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final bool canAddMoreImages = state.selectedImages.length < 4;
    final bool enabled = !state.isPosting && canAddMoreImages;

    return IconButton(
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      onPressed: enabled ? () => notifier.pickImages(context) : null,
      tooltip: enabled ? 'Add images (up to 4)' : (state.isPosting ? 'Posting...' : 'Maximum images reached'),
      icon: Icon(FluentIcons.image_24_regular, size: 24, color: Theme.of(context).colorScheme.primary),
    );
  }
}

class _SelectedImagesPreview extends StatelessWidget {
  const _SelectedImagesPreview({required this.state, required this.notifier});

  final CommentInputState state;
  final CommentInputNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.selectedImages.length,
        itemBuilder: (context, index) {
          final imageFile = state.selectedImages[index];
          final alt = state.altTexts[imageFile.path] ?? '';
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                // Image Thumbnail with rounded corners and shadow
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.5),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 26), blurRadius: 4, offset: const Offset(0, 2))],
                    image: DecorationImage(image: FileImage(File(imageFile.path)), fit: BoxFit.cover),
                  ),
                ),
                // ALT Button (bottom right)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Material(
                    color: Colors.black.withValues(alpha: 128),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () async {
                        final result = await showDialog<String>(
                          context: context,
                          builder: (context) => AltTextEditorDialog(imageFile: imageFile, initialAltText: alt),
                        );
                        if (result != null) {
                          notifier.updateAltText(imageFile.path, result.trim());
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            Icon(FluentIcons.image_alt_text_20_regular, color: Colors.white, size: 14),
                            const SizedBox(width: 2),
                            const Text('ALT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Remove Button (top right)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.black.withValues(alpha: 128),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => notifier.removeImage(index),
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        child: const Icon(FluentIcons.dismiss_16_filled, color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
