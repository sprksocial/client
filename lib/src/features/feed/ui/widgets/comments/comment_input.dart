import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/comments/emoji_picker.dart';

class CommentInput extends StatefulWidget {
  final String postUri;
  final String? replyingToUsername;
  final String? replyingToId;
  final VoidCallback onCancelReply;
  // Video post info
  final String postCid;
  // For replies, parent may be different than the main post
  final String? parentCid;
  final String? parentUri;
  // Callback when comment is posted successfully
  final Function(String)? onCommentPosted;
  // Focus node for the text field
  final FocusNode? focusNode;
  // Function to post comment
  final Future<void> Function({
    required String text,
    required String targetCid,
    required String targetUri,
    String? rootCid,
    String? rootUri,
    List<XFile>? imageFiles,
    Map<String, String>? altTexts,
  }) postComment;

  const CommentInput({
    super.key,
    required this.postUri,
    this.replyingToUsername,
    this.replyingToId,
    required this.onCancelReply,
    required this.postCid,
    this.parentCid,
    this.parentUri,
    this.onCommentPosted,
    this.focusNode,
    required this.postComment,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final _logger = GetIt.instance<LogService>().getLogger('CommentInput');
  
  List<XFile> _selectedImages = [];
  bool _canSubmit = false;
  bool _isPosting = false;
  Map<String, String> _altTexts = {};

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateSubmitState);
  }

  @override
  void dispose() {
    _textController.removeListener(_updateSubmitState);
    _textController.dispose();
    super.dispose();
  }

  void _updateSubmitState() {
    final textIsNotEmpty = _textController.text.trim().isNotEmpty;
    final imagesAreSelected = _selectedImages.isNotEmpty;
    final newCanSubmit = textIsNotEmpty || imagesAreSelected;

    if (newCanSubmit != _canSubmit) {
      setState(() {
        _canSubmit = newCanSubmit;
      });
    }
  }

  void _insertEmoji(String emoji) {
    if (_isPosting) return;

    _logger.d('Inserting emoji: $emoji');

    final currentText = _textController.text;
    final selection = _textController.selection;

    // Handle invalid selection (when text field doesn't have focus)
    if (selection.baseOffset < 0) {
      // Insert at the end of text if no valid selection
      _textController.text = currentText + emoji;
      // Move cursor to end
      _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
      return;
    }

    final newText = currentText.replaceRange(selection.start, selection.end, emoji);

    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.baseOffset + emoji.length),
    );
  }

  Future<void> _pickImages() async {
    if (_isPosting) return;

    const maxImages = 4;
    final currentImageCount = _selectedImages.length;
    
    if (currentImageCount >= maxImages) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can select up to $maxImages images.')),
      );
      return;
    }

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        limit: maxImages - currentImageCount,
      );

      if (!mounted) return;

      if (pickedFiles.isNotEmpty) {
        _logger.d('Picked ${pickedFiles.length} images');
        setState(() {
          _selectedImages.addAll(pickedFiles);
          for (final file in pickedFiles) {
            _altTexts[file.path] = '';
          }
          _updateSubmitState();
        });
      }
    } catch (e) {
      _logger.e('Error picking images', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images: $e')),
      );
    }
  }

  void _removeImage(int index) {
    if (_isPosting) return;
    
    _logger.d('Removing image at index $index');
    setState(() {
      final removed = _selectedImages.removeAt(index);
      _altTexts.remove(removed.path);
      _updateSubmitState();
    });
  }

  Future<void> _submitComment() async {
    if (!_canSubmit || _isPosting) return;

    _logger.i('Submitting comment');
    final text = _textController.text.trim();
    final imagesToUpload = List<XFile>.from(_selectedImages);
    final targetCid = widget.parentCid ?? widget.postCid;
    final targetUri = widget.parentUri ?? widget.postUri;

    setState(() {
      _isPosting = true;
    });

    try {
      await widget.postComment(
        text: text,
        targetCid: targetCid,
        targetUri: targetUri,
        rootCid: widget.parentCid != null ? widget.postCid : null,
        rootUri: widget.parentUri != null ? widget.postUri : null,
        imageFiles: imagesToUpload,
        altTexts: _altTexts,
      );

      if (!mounted) return;

      _logger.i('Comment posted successfully');
      
      // Clear text and selected images on success
      _textController.clear();
      setState(() {
        _selectedImages = [];
        _altTexts = {};
        _updateSubmitState();
      });

      if (widget.replyingToId != null) {
        widget.onCancelReply();
      }

      // Call the callback with the new comment URI
      if (widget.onCommentPosted != null) {
        widget.onCommentPosted!("comment_uri");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment posted successfully')),
      );
    } catch (e) {
      _logger.e('Error posting comment', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.surface;
    final borderColor = colorScheme.outlineVariant;
    final textColor = colorScheme.onSurface;
    final placeholderColor = colorScheme.onSurfaceVariant.withAlpha(128);
    final inputBackgroundColor = colorScheme.primary.withAlpha(77);

    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: backgroundColor, 
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          EmojiPicker(
            onEmojiSelected: _insertEmoji, 
          ),

          const SizedBox(height: 8),

          if (widget.replyingToUsername != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _ReplyingToNotice(
                username: widget.replyingToUsername!,
                onCancel: widget.onCancelReply,
                backgroundColor: inputBackgroundColor,
                borderColor: borderColor,
                textColor: textColor,
              ),
            ),

          _CommentInputBar(
            controller: _textController,
            focusNode: widget.focusNode,
            isPosting: _isPosting,
            canSubmit: _canSubmit,
            replyingToUsername: widget.replyingToUsername,
            selectedImagesCount: _selectedImages.length,
            textColor: textColor,
            placeholderColor: placeholderColor,
            onPickImages: _pickImages,
            onSubmit: _submitComment,
          ),

          if (_selectedImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0), 
              child: _SelectedImagesPreview(
                selectedImages: _selectedImages,
                altTexts: _altTexts,
                onRemoveImage: _removeImage,
                onUpdateAltText: (path, text) {
                  setState(() {
                    _altTexts[path] = text;
                  });
                },
                borderColor: borderColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _ReplyingToNotice extends StatelessWidget {
  final String username;
  final VoidCallback onCancel;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const _ReplyingToNotice({
    required this.username,
    required this.onCancel,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Replying to $username', 
              style: TextStyle(color: textColor, fontSize: 13),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onCancel,
            icon: Icon(
              FluentIcons.dismiss_24_regular, 
              size: 16, 
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isPosting;
  final bool canSubmit;
  final String? replyingToUsername;
  final int selectedImagesCount;
  final Color textColor;
  final Color placeholderColor;
  final VoidCallback onPickImages;
  final VoidCallback onSubmit;

  const _CommentInputBar({
    required this.controller,
    this.focusNode,
    required this.isPosting,
    required this.canSubmit,
    required this.replyingToUsername,
    required this.selectedImagesCount,
    required this.textColor,
    required this.placeholderColor,
    required this.onPickImages,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final bool canAddMoreImages = selectedImagesCount < 4;
    final bool enabled = !isPosting && canAddMoreImages;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _UserAvatar(),
          const SizedBox(width: 5),
          _AttachmentButton(
            enabled: enabled,
            isPosting: isPosting,
            onPickImages: onPickImages,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: _CommentTextField(
              controller: controller,
              focusNode: focusNode,
              isPosting: isPosting,
              canSubmit: canSubmit,
              textColor: textColor,
              placeholderColor: placeholderColor,
              replyingToUsername: replyingToUsername,
              selectedImagesCount: selectedImagesCount,
              onSubmit: onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: AppColors.deepPurple, 
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          // TODO: what?
          'Y', 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w500, 
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _AttachmentButton extends StatelessWidget {
  final bool enabled;
  final bool isPosting;
  final VoidCallback onPickImages;

  const _AttachmentButton({
    required this.enabled,
    required this.isPosting,
    required this.onPickImages,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      onPressed: enabled ? onPickImages : null,
      tooltip: enabled 
          ? 'Add images (up to 4)' 
          : (isPosting ? 'Posting...' : 'Maximum images reached'),
      icon: Icon(
        FluentIcons.image_24_regular, 
        size: 24, 
        color: AppColors.primary,
      ),
    );
  }
}

class _CommentTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isPosting;
  final bool canSubmit;
  final String? replyingToUsername;
  final int selectedImagesCount;
  final Color textColor;
  final Color placeholderColor;
  final VoidCallback onSubmit;

  const _CommentTextField({
    required this.controller,
    this.focusNode,
    required this.isPosting,
    required this.canSubmit,
    required this.replyingToUsername,
    required this.selectedImagesCount,
    required this.textColor,
    required this.placeholderColor,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    String hint;
    if (replyingToUsername != null) {
      hint = 'Reply to $replyingToUsername...';
    } else if (selectedImagesCount > 0 && controller.text.isEmpty) {
      hint = 'Add a caption... (optional)';
    } else {
      hint = 'Add a comment...';
    }

    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: placeholderColor, fontSize: 14),
        filled: false,
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        suffixIcon: isPosting
            ? Container(
                margin: const EdgeInsets.all(8),
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2, 
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : IconButton(
                icon: Icon(
                  FluentIcons.send_24_filled, 
                  size: 20, 
                  color: canSubmit ? AppColors.primary : placeholderColor,
                ),
                onPressed: canSubmit ? onSubmit : null,
              ),
      ),
      style: TextStyle(color: textColor, fontSize: 14),
      maxLines: 5,
      minLines: 1,
      textAlignVertical: TextAlignVertical.center,
      cursorColor: AppColors.primary,
      enabled: !isPosting,
    );
  }
}

class _SelectedImagesPreview extends StatelessWidget {
  final List<XFile> selectedImages;
  final Map<String, String> altTexts;
  final Function(int) onRemoveImage;
  final Function(String, String) onUpdateAltText;
  final Color borderColor;

  const _SelectedImagesPreview({
    required this.selectedImages,
    required this.altTexts,
    required this.onRemoveImage,
    required this.onUpdateAltText,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedImages.length,
        itemBuilder: (context, index) {
          final imageFile = selectedImages[index];
          final alt = altTexts[imageFile.path] ?? '';
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _ImagePreviewItem(
              imageFile: imageFile,
              alt: alt,
              onRemove: () => onRemoveImage(index),
              onUpdateAlt: (newAlt) => onUpdateAltText(imageFile.path, newAlt),
              borderColor: borderColor,
            ),
          );
        },
      ),
    );
  }
}

class _ImagePreviewItem extends StatelessWidget {
  final XFile imageFile;
  final String alt;
  final VoidCallback onRemove;
  final Function(String) onUpdateAlt;
  final Color borderColor;

  const _ImagePreviewItem({
    required this.imageFile,
    required this.alt,
    required this.onRemove,
    required this.onUpdateAlt,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Image Thumbnail
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26), 
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
        
        // ALT Button
        Positioned(
          bottom: 4,
          right: 4,
          child: Material(
            color: Colors.black.withAlpha(128),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => _showAltTextEditor(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      FluentIcons.image_alt_text_20_regular, 
                      color: Colors.white, 
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    const Text(
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
        
        // Remove Button
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.black.withAlpha(128),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onRemove,
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
    );
  }

  Future<void> _showAltTextEditor(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _AltTextEditorDialog(
        imageFile: imageFile,
        initialAltText: alt,
      ),
    );
    
    if (result != null) {
      onUpdateAlt(result.trim());
    }
  }
}

class _AltTextEditorDialog extends StatefulWidget {
  final XFile imageFile;
  final String initialAltText;

  const _AltTextEditorDialog({
    required this.imageFile,
    required this.initialAltText,
  });

  @override
  State<_AltTextEditorDialog> createState() => _AltTextEditorDialogState();
}

class _AltTextEditorDialogState extends State<_AltTextEditorDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAltText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(FluentIcons.image_alt_text_24_regular),
                const SizedBox(width: 8),
                Text(
                  'Add alt text', 
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Image preview
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(File(widget.imageFile.path)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Alt text input
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Alt text',
                hintText: 'Describe this image...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.router.maybePop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.router.maybePop(_controller.text),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 