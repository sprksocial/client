import 'dart:io';

import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/long_button.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/components/molecules/glass_input.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/shapes.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

/// Design-only template for the Image Review flow.
///
/// The template composes page chrome & common sections with the design system.
/// Content-heavy areas (image pager and description) are provided as slots.
class ImageReviewPageTemplate extends StatelessWidget {
  const ImageReviewPageTemplate({
    required this.title,
    required this.onBack,
    required this.imagePaths,
    required this.currentPage,
    required this.onPageChanged,
    required this.onTapEditImage,
    required this.onAltEdit,
    required this.onRemoveImage,
    required this.showAddMore,
    required this.canAddMore,
    required this.imagesCount,
    required this.maxImages,
    required this.onAddMore,
    required this.descriptionController,
    required this.descriptionMaxChars,
    required this.postLabel,
    required this.onPost,
    required this.isPosting,
    required this.crossPostValue,
    required this.onCrossPostChanged,
    super.key,
    this.showCrossPostWarning = false,
    this.backgroundColor,
  });

  final String title;
  final VoidCallback onBack;
  final List<String> imagePaths;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onTapEditImage;
  final ValueChanged<int> onAltEdit;
  final ValueChanged<int> onRemoveImage;
  final bool showAddMore;
  final bool canAddMore;
  final int imagesCount;
  final int maxImages;
  final VoidCallback onAddMore;
  final TextEditingController descriptionController;
  final int descriptionMaxChars;
  final bool crossPostValue;
  final ValueChanged<bool> onCrossPostChanged;
  final bool showCrossPostWarning;
  final String postLabel;
  final VoidCallback? onPost;
  final bool isPosting;
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
        title: Text(
          title,
        ),
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
                      _ImagePager(
                        imagePaths: imagePaths,
                        onTapEditImage: onTapEditImage,
                        onAltEdit: onAltEdit,
                        onRemoveImage: onRemoveImage,
                        currentPage: currentPage,
                        onPageChanged: onPageChanged,
                      ),
                      if (showAddMore) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: LongButton(
                            label: canAddMore
                                ? 'Add More Images ($imagesCount/$maxImages)'
                                : 'Image Limit Reached',
                            onPressed: canAddMore ? onAddMore : null,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _DescriptionSection(
                        controller: descriptionController,
                        maxChars: descriptionMaxChars,
                      ),
                      const SizedBox(height: 20),
                      _CrossPostSection(
                        value: crossPostValue,
                        onChanged: onCrossPostChanged,
                        showWarning: showCrossPostWarning,
                      ),
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

class _ImagePager extends StatelessWidget {
  const _ImagePager({
    required this.imagePaths,
    required this.currentPage,
    required this.onPageChanged,
    required this.onTapEditImage,
    required this.onAltEdit,
    required this.onRemoveImage,
  });

  final List<String> imagePaths;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onTapEditImage;
  final ValueChanged<int> onAltEdit;
  final ValueChanged<int> onRemoveImage;

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) return const SizedBox.shrink();
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
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: ShapeDecoration(shape: shape),
        child: Material(
          color: Colors.transparent,
          shape: RoundedSuperellipseBorder(borderRadius: radius),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView.builder(
                itemCount: imagePaths.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  final path = imagePaths[index];
                  return GestureDetector(
                    onTap: () => onTapEditImage(index),
                    child: Stack(
                      children: [
                        // Image content fills the clipped shape
                        Positioned.fill(
                          child: Image(
                            image: FileImage(File(path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(150),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.white.withAlpha(38),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.edit,
                                  color: AppColors.greyWhite,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Tap to edit',
                                  style: AppTypography.textSmallBold.copyWith(
                                    color: AppColors.greyWhite,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ALT text editor chip
                              GestureDetector(
                                onTap: () => onAltEdit(index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(100),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(38),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'ALT',
                                        style: AppTypography.textSmallBold
                                            .copyWith(
                                              color: AppColors.greyWhite,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Remove image
                              GestureDetector(
                                onTap: () => onRemoveImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withAlpha(100),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(38),
                                    ),
                                  ),
                                  child: AppIcons.cancel(
                                    size: 18,
                                    color: AppColors.greyWhite,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (imagePaths.length > 1)
                Positioned(
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withAlpha(38)),
                    ),
                    child: Text(
                      '${currentPage + 1} / ${imagePaths.length}',
                      style: AppTypography.textExtraSmallMedium.copyWith(
                        color: AppColors.greyWhite,
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
    required this.showWarning,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showWarning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tileColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.5,
    );
    final borderColor = colorScheme.outline.withValues(alpha: 0.6);
    final titleColor = colorScheme.onSurface;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 2,
            ),
            title: Text(
              'Post to Bluesky',
              style: AppTypography.textMediumBold.copyWith(
                color: titleColor,
              ),
            ),
            trailing: Switch(value: value, onChanged: onChanged),
            onTap: () => onChanged(!value),
          ),
        ),
        if (showWarning) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.rajah500.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.rajah500.withAlpha(64)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.rajah500,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bluesky supports a maximum of 4 images. '
                    'Your Bluesky post will link to the Spark post instead.',
                    style: AppTypography.textSmallMedium.copyWith(
                      color: AppColors.rajah500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
