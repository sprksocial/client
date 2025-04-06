import 'dart:io'; // Import for File

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:provider/provider.dart';

import '../../services/actions_service.dart';
import '../../utils/app_colors.dart';
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
  bool _isUploadingImages = false; // State for image upload phase

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You can select up to $maxImages images.')));
      return;
    }

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        limit: maxImages - currentImageCount, // Limit selection based on remaining slots
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles);
          _updateSubmitState(); // Re-check if can submit
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick images: ${e.toString()}')));
    }
  }

  // Function to remove a selected image
  void _removeImage(int index) {
    if (_isPosting) return;
    setState(() {
      _selectedImages.removeAt(index);
      _updateSubmitState(); // Re-check if can submit
    });
  }

  Future<void> _submitComment() async {
    // Check if can submit and not already posting
    if (!_canSubmit || _isPosting) return;

    final text = _textController.text.trim();
    final imagesToUpload = List<XFile>.from(_selectedImages); // Copy list

    // Get the target CID and URI for the comment
    final targetCid = widget.parentCid ?? widget.postCid;
    final targetUri = widget.parentUri ?? widget.postUri;

    setState(() {
      _isPosting = true; // Set posting state (covers text + image upload)
      _isUploadingImages = imagesToUpload.isNotEmpty; // Specifically track image upload phase
    });

    try {
      final actionsService = Provider.of<ActionsService>(context, listen: false);

      // Pass text and selected images to the service method
      final response = await actionsService.postComment(
        text,
        targetCid,
        targetUri,
        rootCid: widget.parentCid != null ? widget.postCid : null,
        rootUri: widget.parentUri != null ? widget.postUri : null,
        imageFiles: imagesToUpload, // Pass the image files
      );

      // Clear text and selected images on success
      _textController.clear();
      setState(() {
        _selectedImages = [];
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to post comment: ${e.toString()}')));
      debugPrint('Error posting comment: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
          _isUploadingImages = false; // Ensure this is reset
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isDarkMode ? AppColors.nearBlack : Colors.white;
    final borderColor = widget.isDarkMode ? AppColors.darkPurple : AppColors.lightLavender;
    final textColor = widget.isDarkMode ? AppColors.textLight : AppColors.textPrimary;
    final placeholderColor = widget.isDarkMode ? AppColors.textLight.withAlpha(128) : AppColors.textSecondary.withAlpha(179);
    final inputBackgroundColor = widget.isDarkMode ? AppColors.deepPurple.withAlpha(128) : AppColors.lightLavender.withAlpha(77);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: backgroundColor, border: Border(top: BorderSide(color: borderColor, width: 0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji Picker is always displayed at the top
          EmojiPicker(onEmojiSelected: _insertEmoji, isDarkMode: widget.isDarkMode),

          const SizedBox(height: 8),

          if (widget.replyingToUsername != null) _buildReplyingToNotice(inputBackgroundColor, borderColor, textColor),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildUserAvatar(borderColor),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(inputBackgroundColor, borderColor, textColor, placeholderColor)),
              const SizedBox(width: 8),
              _buildAttachmentButton(inputBackgroundColor, borderColor, textColor),
            ],
          ),

          // Selected Images Preview (only show if images are selected)
          if (_selectedImages.isNotEmpty) _buildSelectedImagesPreview(borderColor),
        ],
      ),
    );
  }

  Widget _buildReplyingToNotice(Color inputBackgroundColor, Color borderColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
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

  Widget _buildUserAvatar(Color borderColor) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        border: Border.all(color: widget.isDarkMode ? AppColors.deepPurple : AppColors.lightLavender, width: 1),
      ),
      child: const Center(
        child: Text(
          'Y', // Current user's initial
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTextField(Color inputBackgroundColor, Color borderColor, Color textColor, Color placeholderColor) {
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
        hintText: hint, // Updated hint logic
        hintStyle: TextStyle(color: placeholderColor, fontSize: 14),
        filled: true,
        fillColor: inputBackgroundColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: borderColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: borderColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: borderColor, width: 0.5),
        ),
        suffixIcon:
            _isPosting // Show progress if posting OR specifically uploading images
                ? Container(
                  margin: const EdgeInsets.all(10),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary), // Use valueColor
                  ),
                )
                : IconButton(
                  icon: Icon(FluentIcons.send_24_filled, size: 20, color: _canSubmit ? AppColors.primary : placeholderColor),
                  onPressed: _canSubmit ? _submitComment : null, // Controlled by _canSubmit
                ),
      ),
      style: TextStyle(color: textColor, fontSize: 14),
      maxLines: 5,
      minLines: 1,
      cursorColor: AppColors.primary,
      enabled: !_isPosting, // Disable field while posting
    );
  }

  Widget _buildAttachmentButton(Color inputBackgroundColor, Color borderColor, Color textColor) {
    final bool canAddMoreImages = _selectedImages.length < 4; // Example limit
    final bool enabled = !_isPosting && canAddMoreImages;

    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      onPressed: enabled ? _pickImages : null, // Trigger image picker
      tooltip: enabled ? 'Add images (up to 4)' : (_isPosting ? 'Posting...' : 'Maximum images reached'),
      icon: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: inputBackgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Icon(
          // Change icon based on state if desired, e.g., FluentIcons.image_add_24_regular
          FluentIcons.add_24_regular,
          size: 18,
          color: enabled ? textColor : textColor.withOpacity(0.5), // Dim if disabled
        ),
      ),
    );
  }

  // New widget to display selected image thumbnails
  Widget _buildSelectedImagesPreview(Color borderColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, left: 44), // Align with text field start
      child: SizedBox(
        height: 64, // Adjust height as needed
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _selectedImages.length,
          itemBuilder: (context, index) {
            final imageFile = _selectedImages[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  // Image Thumbnail
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor, width: 0.5),
                      image: DecorationImage(image: FileImage(File(imageFile.path)), fit: BoxFit.cover),
                    ),
                  ),
                  // Remove Button
                  Material(
                    color: Colors.black.withOpacity(0.5),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
