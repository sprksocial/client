import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/templates/post_review_page_template.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/posting/models/mention_controller.dart';

class VideoReviewPageTemplate extends StatelessWidget {
  const VideoReviewPageTemplate({
    required this.title,
    required this.onBack,
    required this.videoPreview,
    required this.descriptionMaxChars,
    required this.postLabel,
    required this.onPost,
    required this.isPosting,
    required this.crossPostValue,
    required this.onCrossPostChanged,
    this.descriptionController,
    this.mentionController,
    this.showCaption = true,
    this.showCrossPost = true,
    this.aspectRatio = 1.0,
    this.backgroundColor,
    this.isOverLimit = false,
    this.uploadProgress,
    this.uploadStatusLabel,
    this.uploadIndeterminate = false,
    this.hasUploadError = false,
    this.onUploadRetry,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final Widget videoPreview;
  final TextEditingController? descriptionController;
  final MentionController? mentionController;
  final int descriptionMaxChars;
  final bool crossPostValue;
  final ValueChanged<bool> onCrossPostChanged;
  final bool showCaption;
  final bool showCrossPost;
  final String postLabel;
  final VoidCallback? onPost;
  final bool isPosting;
  final double aspectRatio;
  final Color? backgroundColor;
  final bool isOverLimit;
  final double? uploadProgress;
  final String? uploadStatusLabel;
  final bool uploadIndeterminate;
  final bool hasUploadError;
  final VoidCallback? onUploadRetry;

  @override
  Widget build(BuildContext context) {
    final previewHeight = (MediaQuery.sizeOf(context).height * 0.34).clamp(
      196.0,
      300.0,
    );
    return PostReviewPageTemplate(
      title: title,
      onBack: onBack,
      backgroundColor: backgroundColor,
      media: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: previewHeight),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: aspectRatio.isFinite && aspectRatio > 0
                    ? aspectRatio
                    : 1,
                child: ColoredBox(color: Colors.black, child: videoPreview),
              ),
            ),
          ),
        ),
      ),
      caption: showCaption
          ? PostReviewCaption(
              controller: descriptionController,
              mentionController: mentionController,
              maxChars: descriptionMaxChars,
              enabled: !isPosting,
            )
          : const SizedBox.shrink(),
      options: [
        if (showCrossPost)
          PostReviewCrossPost(
            value: crossPostValue,
            onChanged: onCrossPostChanged,
          ),
      ],
      status: uploadStatusLabel == null
          ? null
          : _UploadStatus(
              label: uploadStatusLabel!,
              progress: uploadProgress,
              isIndeterminate: uploadIndeterminate,
              hasError: hasUploadError,
              onRetry: isPosting ? null : onUploadRetry,
            ),
      postLabel: postLabel,
      isPosting: isPosting,
      onPost: isOverLimit ? null : onPost,
    );
  }
}

class _UploadStatus extends StatelessWidget {
  const _UploadStatus({
    required this.label,
    required this.progress,
    required this.isIndeterminate,
    required this.hasError,
    required this.onRetry,
  });

  final String label;
  final double? progress;
  final bool isIndeterminate;
  final bool hasError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final value = progress?.clamp(0.0, 1.0);
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: hasError ? colors.error : colors.onSurfaceVariant,
                  ),
                ),
              ),
              if (!hasError && !isIndeterminate && value != null && value < 1)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12),
                  child: Text('${(value * 100).round()}%'),
                ),
            ],
          ),
          if (!hasError &&
              (isIndeterminate || (value != null && value < 1))) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: isIndeterminate ? null : value,
              minHeight: 3,
              borderRadius: BorderRadius.circular(2),
              color: colors.primary,
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ],
          if (hasError && onRetry != null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onRetry,
                child: Text(AppLocalizations.of(context).buttonTryAgain),
              ),
            ),
        ],
      ),
    );
  }
}
