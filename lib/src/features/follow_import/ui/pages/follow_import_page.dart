import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/follow_import/providers/follow_import_provider.dart';
import 'package:spark/src/features/follow_import/ui/widgets/follow_import_selection.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

@RoutePage()
class FollowImportPage extends ConsumerStatefulWidget {
  const FollowImportPage({super.key});

  @override
  ConsumerState<FollowImportPage> createState() => _FollowImportPageState();
}

class _FollowImportPageState extends ConsumerState<FollowImportPage> {
  bool _isFinishing = false;

  Future<void> _importSelected() async {
    await ref.read(followImportControllerProvider.notifier).importSelected();
  }

  void _finish() {
    final session = ref.read(followImportControllerProvider);
    if (session.isSubmitting || _isFinishing) return;
    _isFinishing = true;
    ref.invalidate(followImportMatchesProvider);
    Navigator.of(context).pop(session.importedDids.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bskyProfile = ref.watch(followImportBskyProfileProvider);
    final session = ref.watch(followImportControllerProvider);

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: AppLeadingButton(onPressed: _finish),
          title: Text(l10n.pageTitleFollowImport),
          centerTitle: true,
        ),
        body: bskyProfile.when(
          loading: () =>
              _LoadingState(message: l10n.followImportLoadingProfile),
          error: (_, _) => _MessageState(
            icon: AppIconData.offline,
            title: l10n.followImportProfileCheckFailedTitle,
            description: l10n.followImportProfileCheckFailedDescription,
            actionLabel: l10n.buttonRetry,
            onAction: () => ref.invalidate(followImportBskyProfileProvider),
          ),
          data: (profile) {
            if (profile == null) {
              return _MessageState(
                icon: AppIconData.person,
                title: l10n.followImportNoProfileTitle,
                description: l10n.followImportNoProfileDescription,
                actionLabel: l10n.buttonDone,
                onAction: _finish,
              );
            }

            return ref
                .watch(followImportMatchesProvider)
                .when(
                  loading: () => _LoadingState(
                    message: l10n.onboardingFollowImportLoading,
                  ),
                  error: (_, _) => _MessageState(
                    icon: AppIconData.offline,
                    title: l10n.followImportDiscoveryFailedTitle,
                    description: l10n.followImportDiscoveryFailedDescription,
                    actionLabel: l10n.buttonRetry,
                    onAction: () => ref.invalidate(followImportMatchesProvider),
                  ),
                  data: (profiles) => _buildMatches(context, profiles, session),
                );
          },
        ),
      ),
    );
  }

  Widget _buildMatches(
    BuildContext context,
    List<ProfileViewDetailed> profiles,
    FollowImportSessionState session,
  ) {
    final l10n = AppLocalizations.of(context);
    if (session.isComplete) {
      return _MessageState(
        icon: AppIconData.check,
        title: l10n.followImportSuccessTitle(session.importedDids.length),
        description: l10n.followImportSuccessDescription,
        actionLabel: l10n.buttonDone,
        onAction: _finish,
      );
    }

    final remainingProfiles = profiles
        .where((profile) => !session.importedDids.contains(profile.did))
        .toList();
    if (remainingProfiles.isEmpty && session.importedDids.isEmpty) {
      return _MessageState(
        icon: AppIconData.people,
        title: l10n.followImportNoMatchesTitle,
        description: l10n.followImportNoMatchesDescription,
        actionLabel: l10n.buttonDone,
        onAction: _finish,
      );
    }

    final remainingSelected = session.remainingSelectedDids;

    return Column(
      children: [
        if (session.hasPartialFailure)
          MaterialBanner(
            content: Text(l10n.followImportPartialFailure),
            actions: [
              TextButton(
                onPressed: _finish,
                child: Text(l10n.buttonFinishForNow),
              ),
            ],
          ),
        Expanded(child: FollowImportSelection(profiles: remainingProfiles)),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: AppButton(
            label: l10n.onboardingFollowImportAction(remainingSelected.length),
            onPressed: session.isSubmitting || remainingSelected.isEmpty
                ? null
                : _importSelected,
            fullWidth: true,
          ),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final AppIconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(icon, size: 52, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              AppButton(
                label: actionLabel,
                onPressed: onAction,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
