import 'dart:io';

import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/templates/post_review_page_template.dart';
import 'package:spark/src/core/design_system/tokens/shapes.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/posting/models/mention_controller.dart';

class ImageReviewPageTemplate extends StatelessWidget {
  const ImageReviewPageTemplate({
    required this.title,
    required this.onBack,
    required this.imagePaths,
    required this.onTapEditImage,
    required this.onRemoveImage,
    required this.showAddMore,
    required this.canAddMore,
    required this.onAddMore,
    required this.descriptionMaxChars,
    required this.postLabel,
    required this.onPost,
    required this.isPosting,
    required this.crossPostValue,
    required this.onCrossPostChanged,
    super.key,
    this.selectedSoundTitle,
    this.selectedSoundSubtitle,
    this.onAddSound,
    this.onRemoveSound,
    this.descriptionController,
    this.mentionController,
    this.showCaption = true,
    this.showCrossPost = true,
    this.showCrossPostWarning = false,
    this.backgroundColor,
    this.isOverLimit = false,
  });

  final String title;
  final VoidCallback onBack;
  final List<String> imagePaths;
  final ValueChanged<int> onTapEditImage;
  final ValueChanged<int> onRemoveImage;
  final bool showAddMore;
  final bool canAddMore;
  final VoidCallback onAddMore;
  final TextEditingController? descriptionController;
  final MentionController? mentionController;
  final int descriptionMaxChars;
  final bool showCaption;
  final bool showCrossPost;
  final bool crossPostValue;
  final ValueChanged<bool> onCrossPostChanged;
  final bool showCrossPostWarning;
  final String? selectedSoundTitle;
  final String? selectedSoundSubtitle;
  final VoidCallback? onAddSound;
  final VoidCallback? onRemoveSound;
  final String postLabel;
  final VoidCallback? onPost;
  final bool isPosting;
  final Color? backgroundColor;
  final bool isOverLimit;

  @override
  Widget build(BuildContext context) {
    return PostReviewPageTemplate(
      title: title,
      onBack: onBack,
      backgroundColor: backgroundColor,
      media: _PhotoStrip(
        imagePaths: imagePaths,
        onTapEditImage: onTapEditImage,
        onRemoveImage: onRemoveImage,
        showAddMore: showAddMore,
        canAddMore: canAddMore,
        onAddMore: onAddMore,
        enabled: !isPosting,
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
        if (onAddSound != null)
          _SoundSection(
            title: selectedSoundTitle,
            subtitle: selectedSoundSubtitle,
            onAddSound: isPosting ? null : onAddSound,
            onRemoveSound: isPosting ? null : onRemoveSound,
          ),
        if (onAddSound != null && showCrossPost) const Divider(height: 24),
        if (showCrossPost)
          PostReviewCrossPost(
            value: crossPostValue,
            onChanged: onCrossPostChanged,
            showWarning: showCrossPostWarning,
          ),
      ],
      postLabel: postLabel,
      onPost: isPosting || isOverLimit || imagePaths.isEmpty ? null : onPost,
      isPosting: isPosting,
    );
  }
}

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({
    required this.imagePaths,
    required this.onTapEditImage,
    required this.onRemoveImage,
    required this.showAddMore,
    required this.canAddMore,
    required this.onAddMore,
    required this.enabled,
  });

  final List<String> imagePaths;
  final ValueChanged<int> onTapEditImage;
  final ValueChanged<int> onRemoveImage;
  final bool showAddMore;
  final bool canAddMore;
  final VoidCallback onAddMore;
  final bool enabled;

  void _showPhotoActions(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: AppIcon(
              AppIconData.delete,
              color: Theme.of(sheetContext).colorScheme.error,
            ),
            title: Text(l10n.buttonRemove),
            onTap: () {
              Navigator.of(sheetContext).pop();
              onRemoveImage(index);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppShapes.squircleRadius);

    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: imagePaths.length + (showAddMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == imagePaths.length) {
            return Semantics(
              label: canAddMore
                  ? l10n.reviewAddPhotos
                  : l10n.reviewImageLimitReached,
              button: true,
              enabled: enabled && canAddMore,
              child: Tooltip(
                message: canAddMore
                    ? l10n.reviewAddPhotos
                    : l10n.reviewImageLimitReached,
                child: SizedBox(
                  width: 112,
                  child: Material(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: radius,
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: enabled && canAddMore ? onAddMore : null,
                      child: Center(
                        child: AppIcon(
                          AppIconData.add,
                          size: 28,
                          color: enabled && canAddMore
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.38),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return Semantics(
            label: l10n.reviewEditPhoto(index + 1),
            button: true,
            enabled: enabled,
            onLongPressHint: showAddMore || imagePaths.length > 1
                ? l10n.reviewRemovePhoto(index + 1)
                : null,
            child: SizedBox(
              width: 112,
              child: Material(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: radius,
                clipBehavior: Clip.antiAlias,
                child: Ink.image(
                  image: FileImage(File(imagePaths[index])),
                  fit: BoxFit.cover,
                  child: InkWell(
                    onTap: enabled ? () => onTapEditImage(index) : null,
                    onLongPress:
                        enabled && (showAddMore || imagePaths.length > 1)
                        ? () => _showPhotoActions(context, index)
                        : null,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SoundSection extends StatelessWidget {
  const _SoundSection({
    required this.title,
    required this.subtitle,
    required this.onAddSound,
    required this.onRemoveSound,
  });

  final String? title;
  final String? subtitle;
  final VoidCallback? onAddSound;
  final VoidCallback? onRemoveSound;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasSound = title != null && title!.trim().isNotEmpty;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const AppIcon(AppIconData.music),
      title: Text(
        hasSound ? title! : l10n.buttonAddSound,
        maxLines: hasSound ? 1 : null,
        overflow: hasSound ? TextOverflow.ellipsis : null,
      ),
      subtitle: hasSound && subtitle != null && subtitle!.isNotEmpty
          ? Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      trailing: hasSound
          ? IconButton(
              tooltip: l10n.buttonRemove,
              icon: const AppIcon(AppIconData.cancel),
              onPressed: onRemoveSound,
            )
          : const AppIcon(AppIconData.chevronRight, size: 20),
      enabled: onAddSound != null,
      onTap: onAddSound,
    );
  }
}
