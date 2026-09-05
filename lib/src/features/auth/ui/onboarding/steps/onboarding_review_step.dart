import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/default_profile_avatar.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

class OnboardingReviewStep extends StatelessWidget {
  const OnboardingReviewStep({
    required this.displayName,
    required this.description,
    required this.selectedFollowCount,
    this.avatarImageProvider,
    super.key,
  });

  final String displayName;
  final String description;
  final int selectedFollowCount;
  final ImageProvider<Object>? avatarImageProvider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      child: Column(
        children: [
          Text(
            l10n.onboardingReviewTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingReviewDescription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: avatarImageProvider,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: avatarImageProvider == null
                      ? const DefaultProfileAvatar(size: 96)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          if (selectedFollowCount > 0) ...[
            const SizedBox(height: 16),
            Text(
              l10n.onboardingReviewFollowCount(selectedFollowCount),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
