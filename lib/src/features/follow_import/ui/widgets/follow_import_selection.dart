import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/atoms/user_avatar.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/follow_import/providers/follow_import_provider.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

class FollowImportSelection extends ConsumerWidget {
  const FollowImportSelection({required this.profiles, super.key, this.onSkip});

  final List<ProfileViewDetailed> profiles;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(followImportControllerProvider);
    final selectedDids = session.remainingSelectedDids;
    final allSelected = selectedDids.length == profiles.length;

    if (!session.selectionInitialized && profiles.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ref
            .read(followImportControllerProvider.notifier)
            .initializeSelection(profiles.map((profile) => profile.did));
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.onboardingFollowImportTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.onboardingFollowImportDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runAlignment: WrapAlignment.spaceBetween,
                spacing: 8,
                children: [
                  if (onSkip != null)
                    TextButton(
                      onPressed: onSkip,
                      child: Text(l10n.onboardingSkipForNow),
                    )
                  else
                    const SizedBox.shrink(),
                  TextButton(
                    onPressed: session.isSubmitting
                        ? null
                        : () => ref
                              .read(followImportControllerProvider.notifier)
                              .replaceSelection(
                                allSelected
                                    ? const <String>{}
                                    : profiles.map((profile) => profile.did),
                              ),
                    child: Text(
                      allSelected
                          ? l10n.onboardingDeselectAll
                          : l10n.onboardingSelectAll,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: profiles.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final profile = profiles[index];
              final selected = selectedDids.contains(profile.did);
              final displayName = profile.displayName?.trim();
              final name = displayName == null || displayName.isEmpty
                  ? profile.handle
                  : displayName;

              return Material(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                child: CheckboxListTile(
                  value: selected,
                  onChanged: session.isSubmitting
                      ? null
                      : (_) {
                          final updated = {...selectedDids};
                          selected
                              ? updated.remove(profile.did)
                              : updated.add(profile.did);
                          ref
                              .read(followImportControllerProvider.notifier)
                              .replaceSelection(updated);
                        },
                  secondary: UserAvatar(
                    imageUrl: profile.avatar ?? '',
                    username: name,
                    size: 44,
                  ),
                  title: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '@${profile.handle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
