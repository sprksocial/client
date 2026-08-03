import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/circle_icon_button.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/pro_image_editor/ui/widgets/story_editor_toolbar.dart';

/// Shared Story-profile chrome for image and video editors.
class StoryEditorTopSection extends StatelessWidget {
  const StoryEditorTopSection({
    required this.onClose,
    required this.onPaint,
    required this.onText,
    required this.onFilter,
    required this.onBlur,
    required this.onEmoji,
    required this.onStickers,
    this.onMention,
    super.key,
  });

  final VoidCallback onClose;
  final Future<void> Function()? onMention;
  final VoidCallback onPaint;
  final VoidCallback onText;
  final VoidCallback onFilter;
  final VoidCallback onBlur;
  final VoidCallback onEmoji;
  final VoidCallback onStickers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleIconButton(
              key: const ValueKey('story-editor-close'),
              onPressed: onClose,
              size: 40,
              backgroundColor: AppColors.grey900.withAlpha(150),
              icon: const Icon(Icons.close_rounded, size: 24),
              iconColor: AppColors.greyWhite,
              semanticLabel: l10n.buttonClose,
            ),
            const Spacer(),
            StoryEditorToolbar(
              onMention: onMention,
              onPaint: onPaint,
              onText: onText,
              onFilter: onFilter,
              onBlur: onBlur,
              onEmoji: onEmoji,
              onStickers: onStickers,
            ),
          ],
        ),
      ),
    );
  }
}
