import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/long_button.dart';
import 'package:spark/src/core/design_system/components/molecules/input_field.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/shapes.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/posting/models/mention_controller.dart';
import 'package:spark/src/features/posting/ui/widgets/mention_input_field.dart';

/// Design-only template for the Video Review flow.
///
/// Mirrors ImageReviewPageTemplate styling and sections while accepting a
/// provided [videoPreview] widget and [aspectRatio] to render the media.
class VideoReviewPageTemplate extends StatelessWidget {
  const VideoReviewPageTemplate({
    required this.title,
    required this.onBack,
    required this.videoPreview,
    required this.onAltEdit,
    required this.descriptionMaxChars,
    required this.postLabel,
    required this.onPost,
    required this.isPosting,
    required this.crossPostValue,
    required this.onCrossPostChanged,
    this.descriptionController,
    this.mentionController,
    this.onMentionsChanged,
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
  final VoidCallback
  onBack; // Kept for API symmetry; AppLeadingButton handles back internally.
  final Widget videoPreview;
  final VoidCallback onAltEdit;
  final TextEditingController? descriptionController;
  final MentionController? mentionController;
  final ValueChanged<List<dynamic>>? onMentionsChanged;
  final int descriptionMaxChars;
  final bool crossPostValue;
  final ValueChanged<bool> onCrossPostChanged;
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      appBar: AppBar(
        backgroundColor: backgroundColor ?? colorScheme.surface,
        elevation: 0,
        leading: AppLeadingButton(
          color: theme.textTheme.titleLarge?.color,
          tooltip: l10n.buttonBack,
        ),
        title: Text(title),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _VideoPreview(
                        aspectRatio: aspectRatio <= 0 ? 1 : aspectRatio,
                        onAltEdit: onAltEdit,
                        child: videoPreview,
                      ),
                      if (uploadStatusLabel != null) ...[
                        const SizedBox(height: 16),
                        _UploadStatusSection(
                          progress: uploadProgress ?? 0,
                          label: uploadStatusLabel!,
                          isIndeterminate: uploadIndeterminate,
                          hasError: hasUploadError,
                          onRetry: onUploadRetry,
                        ),
                      ],
                      const SizedBox(height: 20),
                      _DescriptionSection(
                        controller: descriptionController,
                        mentionController: mentionController,
                        onMentionsChanged: onMentionsChanged,
                        maxChars: descriptionMaxChars,
                      ),
                      if (showCrossPost) ...[
                        const SizedBox(height: 20),
                        _CrossPostSection(
                          value: crossPostValue,
                          onChanged: onCrossPostChanged,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: isPosting
                    ? Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary500.withAlpha(128),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.greyWhite,
                          ),
                        ),
                      )
                    : LongButton(
                        label: postLabel,
                        onPressed: isOverLimit ? null : onPost,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadStatusSection extends StatelessWidget {
  const _UploadStatusSection({
    required this.progress,
    required this.label,
    required this.isIndeterminate,
    required this.hasError,
    this.onRetry,
  });

  final double progress;
  final String label;
  final bool isIndeterminate;
  final bool hasError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final clampedProgress = progress.clamp(0, 1).toDouble();
    final percent = (clampedProgress * 100).round();
    final accent = hasError ? AppColors.red300 : AppColors.primary500;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.textMediumBold.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (!isIndeterminate)
                Text(
                  '$percent%',
                  style: AppTypography.textSmallBold.copyWith(color: accent),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: isIndeterminate ? null : clampedProgress,
              minHeight: 6,
              backgroundColor: colorScheme.outline.withValues(alpha: 0.18),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          if (hasError && onRetry != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRetry,
                child: Text(AppLocalizations.of(context).buttonTryAgain),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VideoPreview extends StatelessWidget {
  const _VideoPreview({
    required this.aspectRatio,
    required this.child,
    required this.onAltEdit,
  });

  final double aspectRatio;
  final Widget child;
  final VoidCallback onAltEdit;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadiusGeometry.circular(AppShapes.squircleRadius);
    final side = BorderSide(
      width: AppShapes.squircleBorderWidth,
      color: Colors.white.withAlpha(AppShapes.squircleBorderAlpha),
    );
    final ShapeBorder shape = RoundedSuperellipseBorder(
      side: side,
      borderRadius: radius,
    );

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: DecoratedBox(
        decoration: ShapeDecoration(shape: shape),
        child: Material(
          color: Colors.transparent,
          shape: RoundedSuperellipseBorder(borderRadius: radius),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(child: child),
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onAltEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withAlpha(38)),
                    ),
                    child: Text(
                      'ALT',
                      style: AppTypography.textSmallBold.copyWith(
                        color: AppColors.greyWhite,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({
    this.controller,
    this.mentionController,
    this.onMentionsChanged,
    required this.maxChars,
  });

  final TextEditingController? controller;
  final MentionController? mentionController;
  final ValueChanged<List<dynamic>>? onMentionsChanged;
  final int maxChars;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textController = mentionController?.textController ?? controller;
    final count = textController?.text.runes.length ?? 0;
    final showCounter = count >= (maxChars * 0.8);
    final isNearLimit = count >= maxChars * 0.9;
    final isOverLimit = count > maxChars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mentionController != null)
          MentionInputField(
            controller: mentionController!,
            onMentionsChanged: onMentionsChanged ?? (_) {},
            hintText: l10n.hintAddDescription,
          )
        else if (controller != null)
          InputField.search(
            controller: controller!,
            hintText: l10n.hintAddDescription,
            maxLines: 5,
            minLines: 1,
          ),
        if (showCounter) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$count/$maxChars',
              style: AppTypography.textSmallMedium.copyWith(
                color: isOverLimit
                    ? AppColors.red300
                    : isNearLimit
                    ? AppColors.rajah500
                    : Colors.white.withAlpha(160),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CrossPostSection extends StatelessWidget {
  const _CrossPostSection({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.6)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        title: Text(
          'Post to Bluesky',
          style: AppTypography.textMediumBold.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        trailing: Switch(value: value, onChanged: onChanged),
        onTap: () => onChanged(!value),
      ),
    );
  }
}
