import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/long_button.dart';
import 'package:spark/src/core/design_system/components/molecules/glass_input.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/shapes.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

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
    required this.descriptionController,
    required this.descriptionMaxChars,
    required this.postLabel,
    required this.onPost,
    required this.isPosting,
    required this.crossPostValue,
    required this.onCrossPostChanged,
    this.showCrossPost = true,
    this.aspectRatio = 1.0,
    this.backgroundColor,
    super.key,
  });

  final String title;
  final VoidCallback
  onBack; // Kept for API symmetry; AppLeadingButton handles back internally.
  final Widget videoPreview;
  final VoidCallback onAltEdit;
  final TextEditingController descriptionController;
  final int descriptionMaxChars;
  final bool crossPostValue;
  final ValueChanged<bool> onCrossPostChanged;
  final bool showCrossPost;
  final String postLabel;
  final VoidCallback? onPost;
  final bool isPosting;
  final double aspectRatio;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      appBar: AppBar(
        backgroundColor: backgroundColor ?? colorScheme.surface,
        elevation: 0,
        leading: AppLeadingButton(
          color: theme.textTheme.titleLarge?.color,
          tooltip: 'Back',
        ),
        title: Text(title),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                      const SizedBox(height: 20),
                      _DescriptionSection(
                        controller: descriptionController,
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
                    : LongButton(label: postLabel, onPressed: onPost),
              ),
            ),
          ],
        ),
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
    required this.controller,
    required this.maxChars,
  });

  final TextEditingController controller;
  final int maxChars;

  @override
  Widget build(BuildContext context) {
    final count = controller.text.runes.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassInput.search(
          controller: controller,
          hintText: 'Add a description... (optional)',
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$count/$maxChars',
            style: AppTypography.textSmallMedium.copyWith(
              color: Colors.white.withAlpha(160),
            ),
          ),
        ),
      ],
    );
  }
}

class _CrossPostSection extends StatelessWidget {
  const _CrossPostSection({
    required this.value,
    required this.onChanged,
  });

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
