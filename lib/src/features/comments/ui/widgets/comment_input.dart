import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/constants.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/ui/widgets/alt_text_editor_dialog.dart';
import 'package:spark/src/core/ui/widgets/user_avatar.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/comments/providers/comment_input_provider.dart';
import 'package:spark/src/features/comments/providers/comment_input_state.dart';
import 'package:spark/src/features/comments/ui/widgets/emoji_picker.dart';
import 'package:spark/src/features/posting/ui/widgets/mention_input_field.dart';
import 'package:spark/src/features/profile/providers/profile_provider.dart';

class CommentInputWidget extends ConsumerStatefulWidget {
  const CommentInputWidget({
    required this.videoId,
    required this.postCid,
    required this.postUri,
    required this.isSprk,
    super.key,
    this.focusNode,
    this.rootCid,
    this.rootUri,
  });
  final String videoId;
  // Video post info
  final String postCid;
  final String postUri;
  // For replies, parent may be different than the main post
  final String? rootCid;
  final String? rootUri;
  final FocusNode? focusNode;
  final bool isSprk;

  @override
  ConsumerState<CommentInputWidget> createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<CommentInputWidget> {
  final imagePicker = ImagePicker();
  static const int _maxChars = AppConstants.replyMaxChars;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentInputProvider(imagePicker));
    final notifier = ref.read(commentInputProvider(imagePicker).notifier);
    final authState = ref.watch(authProvider);
    final userDid = authState.did ?? '';
    final userHandle = authState.handle ?? '';
    final inputController = state.mentionController.textController;
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji Picker is always displayed at the top
          EmojiPicker(
            onEmojiSelected: notifier.insertEmoji,
            isDarkMode:
                Theme.of(context).colorScheme.brightness == Brightness.dark,
          ),

          const SizedBox(height: 8),

          // Updated input row with centered alignment
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                UserAvatar(
                  imageUrl: ref
                      .read(profileProvider(did: userDid))
                      .when(
                        data: (profileData) =>
                            profileData.profile?.avatar?.toString() ?? '',
                        error: (error, stackTrace) => '',
                        loading: () => '',
                      ),
                  username: userHandle,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MentionInputField(
                    controller: state.mentionController,
                    onMentionsChanged: (_) {},
                    hintText: 'Add a comment...',
                    maxChars: _maxChars,
                    maxLines: 5,
                    minLines: 1,
                    focusNode: widget.focusNode,
                    enabled: !state.isPosting,
                  ),
                ),
                const SizedBox(width: 5),
                _AttachmentButton(state: state, notifier: notifier),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: inputController,
                  builder: (context, value, child) {
                    final showSendButton = state.canSubmit || state.isPosting;
                    if (!showSendButton) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: _SendButton(
                        state: state,
                        widget: widget,
                        notifier: notifier,
                        isOverLimit: value.text.runes.length > _maxChars,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Selected Images Preview (only show if images are selected)
          if (state.selectedImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _SelectedImagesPreview(state: state, notifier: notifier),
            ),

          // Character counter (show when approaching limit)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: inputController,
            builder: (context, _, child) => _CharacterCounter(
              controller: inputController,
              maxChars: _maxChars,
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterCounter extends StatelessWidget {
  const _CharacterCounter({required this.controller, required this.maxChars});

  final TextEditingController controller;
  final int maxChars;

  @override
  Widget build(BuildContext context) {
    final count = controller.text.runes.length;
    final showCounter = count >= (maxChars * 0.8);
    final isNearLimit = count >= maxChars * 0.9;
    final isOverLimit = count > maxChars;

    if (!showCounter) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          '$count/$maxChars',
          style: AppTypography.textExtraSmallMedium.copyWith(
            color: isOverLimit
                ? AppColors.red300
                : isNearLimit
                ? AppColors.rajah500
                : Theme.of(context).colorScheme.onSurface.withAlpha(160),
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.state,
    required this.widget,
    required this.notifier,
    required this.isOverLimit,
  });

  final CommentInputState state;
  final CommentInputWidget widget;
  final CommentInput notifier;
  final bool isOverLimit;

  @override
  Widget build(BuildContext context) {
    final canSend = state.canSubmit && !isOverLimit && !state.isPosting;
    final placeholderColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 128);

    if (state.isPosting) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return IconButton(
      icon: Icon(
        FluentIcons.send_24_filled,
        size: 20,
        color: canSend
            ? Theme.of(context).colorScheme.primary
            : placeholderColor,
      ),
      onPressed: canSend
          ? () {
              HapticFeedback.mediumImpact();
              // Use reply info if available, otherwise use main post info
              final parentCid = widget.postCid;
              final parentUri = widget.postUri;
              final rootCid = widget.rootCid;
              final rootUri = widget.rootUri;

              notifier.submitComment(
                parentCid: parentCid,
                parentUri: parentUri,
                isSprk: widget.isSprk,
                rootCid: rootCid,
                rootUri: rootUri,
              );
            }
          : null,
    );
  }
}

class _AttachmentButton extends StatelessWidget {
  const _AttachmentButton({required this.state, required this.notifier});

  final CommentInputState state;
  final CommentInput notifier;

  @override
  Widget build(BuildContext context) {
    final canAddMoreImages = state.selectedImages.isEmpty;
    final enabled = !state.isPosting && canAddMoreImages;

    return IconButton(
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      onPressed: enabled ? () => notifier.pickImages(context) : null,
      tooltip: enabled
          ? 'Add image (1 max)'
          : (state.isPosting ? 'Posting...' : 'Maximum images reached'),
      icon: Icon(
        FluentIcons.image_24_regular,
        size: 24,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _SelectedImagesPreview extends StatelessWidget {
  const _SelectedImagesPreview({required this.state, required this.notifier});

  final CommentInputState state;
  final CommentInput notifier;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.selectedImages.length,
        itemBuilder: (context, index) {
          final imageFile = state.selectedImages[index];
          final alt = state.altTexts[imageFile.path];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                // Image Thumbnail with rounded corners and shadow
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 26),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    image: DecorationImage(
                      image: FileImage(File(imageFile.path)),
                      fit: BoxFit.cover,
                    ),
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
                          builder: (context) => AltTextEditorDialog(
                            imageFile: imageFile.path,
                            initialAltText: alt ?? '',
                          ),
                        );
                        if (result != null) {
                          notifier.updateAltText(imageFile.path, result.trim());
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FluentIcons.image_alt_text_20_regular,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'ALT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                        child: const Icon(
                          FluentIcons.dismiss_16_filled,
                          color: Colors.white,
                          size: 12,
                        ),
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
