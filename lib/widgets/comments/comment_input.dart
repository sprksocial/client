import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../services/actions_service.dart';

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
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _textController = TextEditingController();
  bool _canSubmit = false;
  bool _isPosting = false;

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

  Future<void> _submitComment() async {
    if (!_canSubmit || _isPosting) return;

    final text = _textController.text.trim();

    // Get the target CID and URI for the comment
    final targetCid = widget.parentCid ?? widget.postCid;
    final targetUri = widget.parentUri ?? widget.postUri;

    setState(() => _isPosting = true);

    try {
      final actionsService = Provider.of<ActionsService>(context, listen: false);

      final response = await actionsService.postComment(
        text,
        targetCid,
        targetUri,
        // If this is a reply to a comment (not the main post), we need to specify the root
        rootCid: widget.parentCid != null ? widget.postCid : null,
        rootUri: widget.parentUri != null ? widget.postUri : null,
      );

      _textController.clear();

      if (widget.replyingToId != null) {
        widget.onCancelReply();
      }

      // Call the callback with the new comment URI
      if (widget.onCommentPosted != null) {
        widget.onCommentPosted!(response.data.uri.toString());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment posted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment: ${e.toString()}')),
      );
      debugPrint('Error posting comment: $e');
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
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
        suffixIcon: _isPosting
            ? Container(
                margin: const EdgeInsets.all(10),
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : IconButton(
                icon: Icon(FluentIcons.send_24_filled, size: 20, color: _canSubmit ? AppColors.primary : placeholderColor),
                onPressed: _canSubmit ? _submitComment : null,
              ),
      ),
      style: TextStyle(color: textColor, fontSize: 14),
      maxLines: 5,
      minLines: 1,
      cursorColor: AppColors.primary,
      enabled: !_isPosting,
    );
  }

  Widget _buildAttachmentButton(Color inputBackgroundColor, Color borderColor, Color textColor) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      onPressed: _isPosting ? null : () {
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
        child: Icon(
          FluentIcons.add_24_regular,
          size: 18,
          color: _isPosting ? textColor.withOpacity(0.5) : textColor
        ),
      ),
    );
  }
}
