import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

/// Bottom section for Story image and video editors.
///
/// Keeps contextual video controls above an Instagram-style share action.
class StoryEditorBottomSection extends StatelessWidget {
  const StoryEditorBottomSection({
    required this.onShare,
    this.contextualControl,
    super.key,
  });

  final VoidCallback onShare;
  final Widget? contextualControl;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.greyBlack,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?contextualControl,
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: AppButton(
              key: const ValueKey('story-editor-share-button'),
              label: AppLocalizations.of(context).buttonShare,
              onPressed: onShare,
              size: AppButtonSize.large,
              fullWidth: true,
              minHeight: 54,
              borderRadius: BorderRadius.circular(999),
              trailing: const Icon(Icons.arrow_forward_rounded, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
