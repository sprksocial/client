import 'package:flutter/material.dart';
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
    debugPrint('Submitting comment: $text');
    if (widget.replyingToId != null) {
      debugPrint('Replying to user: ${widget.replyingToUsername} (${widget.replyingToId})');
    }

    _textController.clear();

    if (widget.replyingToId != null) {
      widget.onCancelReply();
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
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(color: backgroundColor, border: Border(top: BorderSide(color: borderColor, width: 0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Expanded(
            child: Text(
              'Replying to ${widget.replyingToUsername}',
              style: TextStyle(color: textColor, fontStyle: FontStyle.italic, fontSize: 13),
            ),
          ),
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
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        hintText: widget.replyingToUsername != null ? 'Reply to ${widget.replyingToUsername}...' : 'Add a comment...',
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
        suffixIcon: IconButton(
          icon: Icon(FluentIcons.send_24_filled, size: 20, color: _canSubmit ? AppColors.primary : placeholderColor),
          onPressed: _canSubmit ? _submitComment : null,
        ),
      ),
      style: TextStyle(color: textColor, fontSize: 14),
      maxLines: 5,
      minLines: 1,
      cursorColor: AppColors.primary,
    );
  }

  Widget _buildAttachmentButton(Color inputBackgroundColor, Color borderColor, Color textColor) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      onPressed: () {
        debugPrint('Open attachment options');
      },
      icon: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: inputBackgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Icon(FluentIcons.add_24_regular, size: 18, color: textColor),
      ),
    );
  }
}
