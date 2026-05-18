import 'package:flutter/material.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/ui/widgets/default_profile_avatar.dart';

class OnboardingAvatarStep extends StatefulWidget {
  const OnboardingAvatarStep({
    this.hasImportedBskyProfile = false,
    this.avatarImageProvider,
    this.hasLocalAvatar = false,
    this.hasInitialAvatar = false,
    this.isAvatarActive = false,
    this.onPickAvatar,
    this.onRevertAvatar,
    this.onClearAvatar,
    super.key,
  });

  final bool hasImportedBskyProfile;
  final ImageProvider<Object>? avatarImageProvider;
  final bool hasLocalAvatar;
  final bool hasInitialAvatar;
  final bool isAvatarActive;
  final VoidCallback? onPickAvatar;
  final VoidCallback? onRevertAvatar;
  final VoidCallback? onClearAvatar;

  @override
  State<OnboardingAvatarStep> createState() => _OnboardingAvatarStepState();
}

class _OnboardingAvatarStepState extends State<OnboardingAvatarStep> {
  bool _isAvatarPressed = false;

  void _setAvatarPressed(bool value) {
    if (_isAvatarPressed == value) return;
    setState(() => _isAvatarPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.hasImportedBskyProfile) ...[
              Text(
                l10n.onboardingBskyAutofill,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            ],
            GestureDetector(
              onTap: widget.onPickAvatar,
              onTapDown: (_) => _setAvatarPressed(true),
              onTapCancel: () => _setAvatarPressed(false),
              onTapUp: (_) => _setAvatarPressed(false),
              child: AnimatedScale(
                scale: _isAvatarPressed ? 0.97 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                child: CircleAvatar(
                  radius: 104,
                  backgroundImage: widget.avatarImageProvider,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: widget.avatarImageProvider == null
                      ? const DefaultProfileAvatar(size: 208)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: widget.onPickAvatar,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(l10n.buttonAdd),
                ),
                if (widget.hasLocalAvatar)
                  TextButton.icon(
                    onPressed: widget.onRevertAvatar,
                    icon: const Icon(Icons.undo),
                    label: Text(l10n.tooltipRevert),
                  ),
                if (widget.isAvatarActive)
                  TextButton.icon(
                    onPressed: widget.onClearAvatar,
                    icon: const Icon(Icons.close),
                    label: Text(l10n.buttonRemove),
                  ),
                if (!widget.isAvatarActive && widget.hasInitialAvatar)
                  TextButton.icon(
                    onPressed: widget.onRevertAvatar,
                    icon: const Icon(Icons.undo),
                    label: Text(l10n.onboardingUseBskyAvatar),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
