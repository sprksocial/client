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
import 'package:spark/src/features/auth/ui/onboarding/steps/onboarding_review_step.dart';
import 'package:spark/src/features/auth/ui/onboarding/steps/onboarding_welcome_step.dart';
import 'package:spark/src/features/follow_import/providers/follow_import_provider.dart';
import 'package:spark/src/features/follow_import/ui/widgets/follow_import_selection.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';

@RoutePage()
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _displayNameStepKey = GlobalKey<OnboardingDisplayNameStepState>();
  final _bioStepKey = GlobalKey<OnboardingBioStepState>();
  bool _isCompleting = false;
  bool _profileCreated = false;
  bool _skipFollowImport = false;
  bool _continueWithoutFailedFollows = false;

  void _handleStepChanged(OnboardingStepId stepId) {
    if (stepId == OnboardingStepId.bio && _skipFollowImport) {
      setState(() {
        _skipFollowImport = false;
      });
      ref.read(followImportControllerProvider.notifier).resetSelection();
    }
    if (stepId == OnboardingStepId.followImport &&
        _continueWithoutFailedFollows) {
      setState(() => _continueWithoutFailedFollows = false);
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  Future<void> _handleCompleteOnboarding() async {
    if (_isCompleting) return;

    final displayNameState = _displayNameStepKey.currentState;
    final bioState = _bioStepKey.currentState;
    final isValid =
        (displayNameState?.validate() ?? false) &&
        (bioState?.validate() ?? false);
    if (!isValid) return;

    setState(() => _isCompleting = true);

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

      if (!_profileCreated) {
        await onboardingState.createCustomProfile(
          displayName: displayNameState!.displayName.trim(),
          description: bioState!.description.trim(),
          avatar: avatarToUse,
        );
        _profileCreated = true;
      }

      if (!mounted) return;

      if (!_skipFollowImport && !_continueWithoutFailedFollows) {
        final followImport = ref.read(followImportControllerProvider.notifier);
        if (ref
            .read(followImportControllerProvider)
            .remainingSelectedDids
            .isNotEmpty) {
          final imported = await followImport.importSelected();
          if (!imported) {
            if (!mounted) return;
            final l10n = AppLocalizations.of(context);
            final messenger = ScaffoldMessenger.of(context);
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(l10n.onboardingFollowImportFailed),
                  action: SnackBarAction(
                    label: l10n.onboardingContinueWithoutFollows,
                    onPressed: _completeWithoutRemainingFollows,
                  ),
                ),
              );
            return;
          }
        }
      }

      if (!mounted) return;

      await ref.read(settingsProvider.notifier).preparePostOnboardingFeed();

      if (!mounted) return;

      context.router.replaceAll([const MainRoute()]);
    } catch (_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _profileCreated
                  ? AppLocalizations.of(context).onboardingFeedSetupFailed
                  : AppLocalizations.of(context).onboardingProfileSaveFailed,
            ),
            action: SnackBarAction(
              label: AppLocalizations.of(context).buttonRetry,
              onPressed: _handleCompleteOnboarding,
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  void _completeWithoutRemainingFollows() {
    if (_isCompleting) return;
    setState(() => _continueWithoutFailedFollows = true);
    _handleCompleteOnboarding();
  }

  void _skipFollowSelection() {
    setState(() {
      _skipFollowImport = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onboardingStateAsync = ref.watch(onboardingProvider);
    final profileSaveState = ref.watch(onboardingStateProvider);
    final followImportSession = ref.watch(followImportControllerProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return PopScope<void>(
      canPop: !_isCompleting,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: true,
          title: Text(l10n.pageTitleCompleteProfile),
          leading: _isCompleting
              ? const SizedBox.shrink()
              : AppLeadingButton(tooltip: l10n.buttonBack),
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
            final AsyncValue<List<ProfileViewDetailed>> followMatchesAsync =
                state.bskyProfileRecord == null
                ? const AsyncData([])
                : ref.watch(followImportMatchesProvider);
            final followMatches = followMatchesAsync.value ?? const [];
            final remainingFollowMatches = followMatches
                .where(
                  (profile) =>
                      !followImportSession.importedDids.contains(profile.did),
                )
                .toList();
            final remainingSelectedFollowDids =
                followImportSession.remainingSelectedDids;

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
                id: OnboardingStepId.welcome,
                title: l10n.onboardingIntroStepTitle,
                builder: (context) => const OnboardingWelcomeStep(),
              ),
              OnboardingStep(
                id: OnboardingStepId.avatar,
                title: l10n.onboardingAvatarStepTitle,
                builder: (context) => OnboardingAvatarStep(
                  hasImportedBskyProfile: state.bskyProfileRecord != null,
                  avatarImageProvider: avatarImageProvider,
                  hasLocalAvatar: hasLocalAvatar,
                  hasInitialAvatar: hasInitialAvatar,
                  isAvatarActive: isAvatarActive,
                  onPickAvatar: () {
                    _profileCreated = false;
                    notifier.pickAvatar();
                  },
                  onRevertAvatar: () {
                    _profileCreated = false;
                    notifier.revertAvatarToInitial();
                  },
                  onClearAvatar: () {
                    _profileCreated = false;
                    notifier.clearAvatarSelection();
                  },
                ),
              ),
              OnboardingStep(
                id: OnboardingStepId.displayName,
                title: l10n.onboardingNameStepTitle,
                builder: (context) => OnboardingDisplayNameStep(
                  key: _displayNameStepKey,
                  initialDisplayName: state.displayName,
                  onDisplayNameChanged: (displayName) {
                    _profileCreated = false;
                    notifier.updateDisplayName(displayName);
                  },
                  onUndoDisplayName:
                      (state.bskyProfileRecord?.displayName != null &&
                          state.displayName !=
                              (state.bskyProfileRecord?.displayName ?? ''))
                      ? () {
                          _profileCreated = false;
                          notifier.resetDisplayName();
                        }
                      : null,
                ),
                canProceed: () =>
                    _displayNameStepKey.currentState?.validate() ?? false,
              ),
              OnboardingStep(
                id: OnboardingStepId.bio,
                title: l10n.onboardingBioStepTitle,
                builder: (context) => OnboardingBioStep(
                  key: _bioStepKey,
                  initialDescription: state.description,
                  onDescriptionChanged: (description) {
                    _profileCreated = false;
                    notifier.updateDescription(description);
                  },
                  onUndoDescription:
                      (state.bskyProfileRecord?.description != null &&
                          state.description !=
                              (state.bskyProfileRecord?.description ?? ''))
                      ? () {
                          _profileCreated = false;
                          notifier.resetDescription();
                        }
                      : null,
                ),
                canProceed: () => _bioStepKey.currentState?.validate() ?? false,
              ),
              OnboardingStep(
                id: OnboardingStepId.followImport,
                title: l10n.onboardingFollowImportStepTitle,
                shouldInclude: () {
                  if (_skipFollowImport || state.bskyProfileRecord == null) {
                    return false;
                  }
                  return followMatchesAsync.isLoading ||
                      followMatchesAsync.hasError ||
                      remainingFollowMatches.isNotEmpty;
                },
                primaryLabel: !followMatchesAsync.hasValue
                    ? l10n.buttonContinue
                    : l10n.onboardingFollowImportAction(
                        remainingSelectedFollowDids.length,
                      ),
                canProceed: () =>
                    followMatchesAsync.hasValue &&
                    remainingSelectedFollowDids.isNotEmpty,
                builder: (context) {
                  return followMatchesAsync.when(
                    loading: () => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(l10n.onboardingFollowImportLoading),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _skipFollowSelection,
                            child: Text(l10n.onboardingSkipForNow),
                          ),
                        ],
                      ),
                    ),
                    error: (_, _) => _FollowImportDiscoveryError(
                      onRetry: () =>
                          ref.invalidate(followImportMatchesProvider),
                      onSkip: _skipFollowSelection,
                    ),
                    data: (_) => FollowImportSelection(
                      profiles: remainingFollowMatches,
                      onSkip: _skipFollowSelection,
                    ),
                  );
                },
              ),
              OnboardingStep(
                id: OnboardingStepId.review,
                title: l10n.onboardingReviewStepTitle,
                builder: (context) => OnboardingReviewStep(
                  displayName:
                      _displayNameStepKey.currentState?.displayName.trim() ??
                      state.displayName.trim(),
                  description:
                      _bioStepKey.currentState?.description.trim() ??
                      state.description.trim(),
                  avatarImageProvider: avatarImageProvider,
                  selectedFollowCount:
                      _skipFollowImport || _continueWithoutFailedFollows
                      ? 0
                      : remainingSelectedFollowDids.length,
                ),
              ),
            ];

            return OnboardingSequence(
              steps: steps,
              isCompleteLoading:
                  _isCompleting ||
                  profileSaveState.isLoading ||
                  followImportSession.isSubmitting,
              onStepChanged: _handleStepChanged,
              onComplete: _handleCompleteOnboarding,
            );
          },
        ),
      ),
    );
  }
}

class _FollowImportDiscoveryError extends StatelessWidget {
  const _FollowImportDiscoveryError({
    required this.onRetry,
    required this.onSkip,
  });

  final VoidCallback onRetry;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              l10n.followImportDiscoveryFailedTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.followImportDiscoveryFailedDescription,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: l10n.buttonRetry,
              onPressed: onRetry,
              size: AppButtonSize.compact,
            ),
            TextButton(
              onPressed: onSkip,
              child: Text(l10n.onboardingSkipForNow),
            ),
          ],
        ),
      ),
    );
  }
}
