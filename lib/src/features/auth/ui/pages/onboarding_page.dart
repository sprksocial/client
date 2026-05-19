import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_leading_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/auth/providers/onboarding_notifier.dart';
import 'package:spark/src/features/auth/providers/onboarding_providers.dart';
import 'package:spark/src/features/auth/ui/onboarding/onboarding_sequence.dart';
import 'package:spark/src/features/auth/ui/onboarding/onboarding_step.dart';
import 'package:spark/src/features/auth/ui/onboarding/steps/onboarding_avatar_step.dart';
import 'package:spark/src/features/auth/ui/onboarding/steps/onboarding_bio_step.dart';
import 'package:spark/src/features/auth/ui/onboarding/steps/onboarding_display_name_step.dart';
import 'package:spark/src/features/auth/ui/onboarding/steps/onboarding_welcome_step.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

@RoutePage()
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _displayNameStepKey = GlobalKey<OnboardingDisplayNameStepState>();
  final _bioStepKey = GlobalKey<OnboardingBioStepState>();
  bool _isLoading = false;

  Future<void> _handleCompleteOnboarding() async {
    final displayNameState = _displayNameStepKey.currentState;
    final bioState = _bioStepKey.currentState;
    final isValid =
        (displayNameState?.validate() ?? false) &&
        (bioState?.validate() ?? false);
    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      final onboardingState = ref.read(onboardingStateProvider.notifier);
      final currentState = ref.read(onboardingProvider).value;

      Object? avatarToUse;
      if (currentState?.localAvatarBytes != null) {
        avatarToUse = currentState!.localAvatarBytes;
      } else if (currentState?.removeInitialAvatar != true &&
          currentState?.bskyProfileRecord?.avatar != null) {
        avatarToUse = currentState!.bskyProfileRecord!.avatar;
      }

      await onboardingState.createCustomProfile(
        displayName: displayNameState!.displayName.trim(),
        description: bioState!.description.trim(),
        avatar: avatarToUse,
      );

      if (!mounted) return;

      await ref.read(settingsProvider.notifier).syncPreferencesFromServer();

      if (!mounted) return;

      context.router.replaceAll([const MainRoute()]);
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onboardingStateAsync = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(l10n.pageTitleCompleteProfile),
        leading: AppLeadingButton(tooltip: l10n.buttonBack),
      ),
      body: onboardingStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${l10n.errorGeneric}: $err'),
              const SizedBox(height: 8),
              AppButton(
                label: l10n.buttonRetry,
                onPressed: notifier.reloadProfile,
                size: AppButtonSize.compact,
              ),
            ],
          ),
        ),
        data: (state) {
          ImageProvider<Object>? avatarImageProvider;
          if (state.localAvatarBytes != null) {
            avatarImageProvider = MemoryImage(state.localAvatarBytes!);
          } else if (notifier.currentAvatarDisplayUrl != null) {
            avatarImageProvider = NetworkImage(
              notifier.currentAvatarDisplayUrl!,
            );
          }

          final hasLocalAvatar = state.localAvatarBytes != null;
          final hasInitialAvatar =
              (state.initialAvatarUrl?.isNotEmpty ?? false) ||
              (state.initialAvatarCid?.isNotEmpty ?? false);
          final isAvatarActive =
              hasLocalAvatar || notifier.currentAvatarDisplayUrl != null;

          final steps = <OnboardingStep>[
            OnboardingStep(
              title: l10n.onboardingIntroStepTitle,
              builder: (context) => const OnboardingWelcomeStep(),
            ),
            OnboardingStep(
              title: l10n.onboardingAvatarStepTitle,
              builder: (context) => OnboardingAvatarStep(
                hasImportedBskyProfile: state.bskyProfileRecord != null,
                avatarImageProvider: avatarImageProvider,
                hasLocalAvatar: hasLocalAvatar,
                hasInitialAvatar: hasInitialAvatar,
                isAvatarActive: isAvatarActive,
                onPickAvatar: notifier.pickAvatar,
                onRevertAvatar: notifier.revertAvatarToInitial,
                onClearAvatar: notifier.clearAvatarSelection,
              ),
            ),
            OnboardingStep(
              title: l10n.onboardingNameStepTitle,
              builder: (context) => OnboardingDisplayNameStep(
                key: _displayNameStepKey,
                initialDisplayName: state.displayName,
                onUndoDisplayName:
                    (state.bskyProfileRecord?.displayName != null &&
                        state.displayName !=
                            (state.bskyProfileRecord?.displayName ?? ''))
                    ? notifier.resetDisplayName
                    : null,
              ),
              canProceed: () =>
                  _displayNameStepKey.currentState?.validate() ?? false,
            ),
            OnboardingStep(
              title: l10n.onboardingBioStepTitle,
              builder: (context) => OnboardingBioStep(
                key: _bioStepKey,
                initialDescription: state.description,
                onUndoDescription:
                    (state.bskyProfileRecord?.description != null &&
                        state.description !=
                            (state.bskyProfileRecord?.description ?? ''))
                    ? notifier.resetDescription
                    : null,
              ),
              canProceed: () => _bioStepKey.currentState?.validate() ?? false,
            ),
          ];

          return OnboardingSequence(
            steps: steps,
            isCompleteLoading: _isLoading,
            onComplete: _handleCompleteOnboarding,
          );
        },
      ),
    );
  }
}
