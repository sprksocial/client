import 'dart:io'; // Import for File

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:provider/provider.dart';

import '../../services/actions_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/image/alt_text_editor_dialog.dart';
import 'emoji_picker.dart';

class CommentInput extends StatefulWidget {
  final String videoId;
  final String? replyingToUsername;
  final String? replyingToId;
  final VoidCallback onCancelReply;
  final bool isDarkMode;
  // Video post info
  final String postCid;
  final String postUri;
  // For replies, parent may be different than the main post
  final String? parentCid;
  final String? parentUri;
  // Callback when comment is posted successfully
  final Function(String)? onCommentPosted;
  // Focus node for the text field
  final FocusNode? focusNode;

  const CommentInput({
    super.key,
    required this.videoId,
    this.replyingToUsername,
    this.replyingToId,
    required this.onCancelReply,
    required this.isDarkMode,
    required this.postCid,
    required this.postUri,
    this.parentCid,
    this.parentUri,
    this.onCommentPosted,
    this.focusNode,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker(); // Add ImagePicker instance
  List<XFile> _selectedImages = []; // State for selected images
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
    final newCanSubmit = textIsNotEmpty || imagesAreSelected; // Can submit if text OR images exist

    if (newCanSubmit != _canSubmit) {
      setState(() {
        _canSubmit = newCanSubmit;
      });
    }
  }

  // Method to insert emoji at current cursor position
  void _insertEmoji(String emoji) {
    if (_isPosting) return;

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

  // Function to pick images
  Future<void> _pickImages() async {
    if (_isPosting) return; // Don't allow picking while posting

    // Limit the number of images that can be selected (e.g., 4)
    const maxImages = 4;
    final currentImageCount = _selectedImages.length;
    if (currentImageCount >= maxImages) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You can select up to $maxImages images.')));
      return;
    }

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        limit: maxImages - currentImageCount, // Limit selection based on remaining slots
      );

      if (!mounted) return;

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles);
          for (final file in pickedFiles) {
            _altTexts[file.path] = '';
          }
          _updateSubmitState(); // Re-check if can submit
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick images: ${e.toString()}')));
    }
  }

  // Function to remove a selected image
  void _removeImage(int index) {
    if (_isPosting) return;
    setState(() {
      final removed = _selectedImages.removeAt(index);
      _altTexts.remove(removed.path);
      _updateSubmitState(); // Re-check if can submit
    });
  }

  Future<void> _submitComment() async {
    // Check if can submit and not already posting
    if (!_canSubmit || _isPosting) return;

    final text = _textController.text.trim();
    final imagesToUpload = List<XFile>.from(_selectedImages); // Copy list
    final actionsService = Provider.of<ActionsService>(context, listen: false);

    // Get the target String and URI for the comment
    final targetCid = widget.parentCid ?? widget.postCid;
    final targetUri = widget.parentUri ?? widget.postUri;

    setState(() {
      _isPosting = true; // Set posting state (covers text + image upload)
    });

    try {
      // Pass text and selected images to the service method
      final response = await actionsService.postComment(
        text,
        targetCid,
        targetUri,
        rootCid: widget.parentCid != null ? widget.postCid : null,
        rootUri: widget.parentUri != null ? widget.postUri : null,
        imageFiles: imagesToUpload,
        altTexts: _altTexts,
      );

      if (!mounted) return;

      // Clear text and selected images on success
      _textController.clear();
      setState(() {
        _selectedImages = [];
        _altTexts = {};
        _updateSubmitState(); // Update submit state after clearing
      });

      if (widget.replyingToId != null) {
        widget.onCancelReply();
      }

      // Call the callback with the new comment URI
      if (widget.onCommentPosted != null) {
        widget.onCommentPosted!(response.data.uri.toString());
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comment posted successfully')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to post comment: ${e.toString()}')));
      debugPrint('Error posting comment: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(_) {
    final backgroundColor = widget.isDarkMode ? AppColors.nearBlack : Colors.white;
    final borderColor = widget.isDarkMode ? AppColors.darkPurple : AppColors.lightLavender;
    final textColor = widget.isDarkMode ? AppColors.textLight : AppColors.textPrimary;
    final placeholderColor =
        widget.isDarkMode ? AppColors.textLight.withValues(alpha: 128) : AppColors.textSecondary.withValues(alpha: 179);
    final inputBackgroundColor = widget.isDarkMode ? AppColors.deepPurple : AppColors.lightLavender.withValues(alpha: 77);

    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 16,
      ),
      decoration: BoxDecoration(color: backgroundColor, border: Border(top: BorderSide(color: borderColor, width: 0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji Picker is always displayed at the top
          EmojiPicker(onEmojiSelected: _insertEmoji, isDarkMode: widget.isDarkMode),

          const SizedBox(height: 8),

          if (widget.replyingToUsername != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildReplyingToNotice(inputBackgroundColor, borderColor, textColor),
            ),

          // Updated input row with centered alignment
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? const Color(0xFF171619) : const Color(0xFFE8E8EA),
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildUserAvatar(textColor),
                const SizedBox(width: 5),
                _buildAttachmentButton(borderColor, textColor),
                const SizedBox(width: 5),
                Expanded(child: _buildTextField(textColor, placeholderColor)),
              ],
            ),
          ),

          // Selected Images Preview (only show if images are selected)
          if (_selectedImages.isNotEmpty)
            Padding(padding: const EdgeInsets.only(top: 8.0), child: _buildSelectedImagesPreview(borderColor)),
        ],
      ),
    );
  }

  Widget _buildReplyingToNotice(Color inputBackgroundColor, Color borderColor, Color textColor) {
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
            onPressed: widget.onCancelReply,
            icon: Icon(FluentIcons.dismiss_24_regular, size: 16, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(Color textColor) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(color: Color(0xFF330072), shape: BoxShape.circle),
      child: const Center(child: Text('Y', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14))),
    );
  }

  Widget _buildTextField(Color textColor, Color placeholderColor) {
    String hint = 'Add a comment...';
    if (widget.replyingToUsername != null) {
      hint = 'Reply to ${widget.replyingToUsername}...';
    } else if (_selectedImages.isNotEmpty && _textController.text.isEmpty) {
      hint = 'Add a caption... (optional)';
    }

    return TextField(
      controller: _textController,
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
            _isPosting
                ? Container(
                  margin: const EdgeInsets.all(8),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
                )
                : IconButton(
                  icon: Icon(FluentIcons.send_24_filled, size: 20, color: _canSubmit ? AppColors.primary : placeholderColor),
                  onPressed: _canSubmit ? _submitComment : null,
                ),
      ),
      style: TextStyle(color: textColor, fontSize: 14),
      maxLines: 5,
      minLines: 1,
      textAlignVertical: TextAlignVertical.center,
      cursorColor: AppColors.primary,
      enabled: !_isPosting,
    );
  }

  Widget _buildAttachmentButton(Color borderColor, Color textColor) {
    final bool canAddMoreImages = _selectedImages.length < 4;
    final bool enabled = !_isPosting && canAddMoreImages;

    return IconButton(
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      onPressed: enabled ? _pickImages : null,
      tooltip: enabled ? 'Add images (up to 4)' : (_isPosting ? 'Posting...' : 'Maximum images reached'),
      icon: Icon(FluentIcons.image_24_regular, size: 24, color: AppColors.primary),
    );
  }

  // New widget to display selected image thumbnails
  Widget _buildSelectedImagesPreview(Color borderColor) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          final imageFile = _selectedImages[index];
          final alt = _altTexts[imageFile.path] ?? '';
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
                    border: Border.all(color: borderColor, width: 0.5),
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
                          setState(() {
                            _altTexts[imageFile.path] = result.trim();
                          });
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
                      onTap: () => _removeImage(index),
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
