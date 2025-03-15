import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../utils/app_colors.dart';

class CommentInput extends StatefulWidget {
  final String videoId;
  final String? replyingToUsername;
  final String? replyingToId;
  final VoidCallback onCancelReply;
  final bool isDarkMode;

  const CommentInput({
    super.key,
    required this.videoId,
    this.replyingToUsername,
    this.replyingToId,
    required this.onCancelReply,
    required this.isDarkMode,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _textController = TextEditingController();
  bool _canSubmit = false;

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
    final newCanSubmit = _textController.text.trim().isNotEmpty;
    if (newCanSubmit != _canSubmit) {
      setState(() {
        _canSubmit = newCanSubmit;
      });
    }
  }

  void _submitComment() {
    if (!_canSubmit) return;
    
    final text = _textController.text.trim();
    // Here you would handle the comment submission
    debugPrint('Submitting comment: $text');
    if (widget.replyingToId != null) {
      debugPrint('Replying to user: ${widget.replyingToUsername} (${widget.replyingToId})');
    }
    
    // Clear the input field after submission
    _textController.clear();
    
    // If this was a reply, cancel the reply mode
    if (widget.replyingToId != null) {
      widget.onCancelReply();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isDarkMode ? AppColors.nearBlack : Colors.white;
    final borderColor = widget.isDarkMode ? AppColors.darkPurple : AppColors.lightLavender;
    final textColor = widget.isDarkMode ? AppColors.textLight : AppColors.textPrimary;
    final placeholderColor = widget.isDarkMode 
        ? AppColors.textLight.withAlpha(128) 
        : AppColors.textSecondary.withAlpha(179);
    final inputBackgroundColor = widget.isDarkMode 
        ? AppColors.deepPurple.withAlpha(128) 
        : AppColors.lightLavender.withAlpha(77);

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reply preview if replying to someone
          if (widget.replyingToUsername != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: inputBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Replying to ${widget.replyingToUsername}',
                      style: TextStyle(
                        color: textColor,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    onPressed: widget.onCancelReply,
                    child: Icon(
                      FluentIcons.dismiss_24_regular,
                      size: 16,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Comment input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end, // Align items to bottom
            children: [
              // User avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isDarkMode ? AppColors.deepPurple : AppColors.lightLavender,
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Y', // Current user's initial
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Text input field
              Expanded(
                child: CupertinoTextField(
                  controller: _textController,
                  placeholder: widget.replyingToUsername != null 
                      ? 'Reply to ${widget.replyingToUsername}...'
                      : 'Add a comment...',
                  placeholderStyle: TextStyle(
                    color: placeholderColor,
                    fontSize: 14,
                  ),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                  decoration: BoxDecoration(
                    color: inputBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  maxLines: 5,
                  minLines: 1,
                  cursorColor: AppColors.primary,
                  suffix: CupertinoButton(
                    padding: const EdgeInsets.only(right: 12),
                    minSize: 0,
                    onPressed: _canSubmit ? _submitComment : null,
                    child: Icon(
                      FluentIcons.send_24_filled,
                      size: 20,
                      color: _canSubmit ? AppColors.primary : placeholderColor,
                    ),
                  ),
                ),
              ),
              
              // Attachment button
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: () {
                  // Show attachment options (photo/video)
                  debugPrint('Open attachment options');
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: inputBackgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                  child: Icon(
                    FluentIcons.add_24_regular,
                    size: 18,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 