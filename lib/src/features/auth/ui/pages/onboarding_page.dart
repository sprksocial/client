import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/auth/data/models/onboarding_screen_state.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/ui/widgets/custom_text_field.dart';
import 'package:spark/src/features/auth/providers/onboarding_notifier.dart';
import 'package:spark/src/features/auth/providers/onboarding_providers.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

@RoutePage()
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _displayNameController.addListener(_updateDisplayName);
    _descriptionController.addListener(_updateDescription);
  }

  void _updateDisplayName() {
    final currentProviderState = ref.read(onboardingProvider).value;
    if (currentProviderState != null &&
        _displayNameController.text != currentProviderState.displayName) {
      ref
          .read(onboardingProvider.notifier)
          .updateDisplayName(_displayNameController.text);
    }
  }

  void _updateDescription() {
    final currentProviderState = ref.read(onboardingProvider).value;
    if (currentProviderState != null &&
        _descriptionController.text != currentProviderState.description) {
      ref
          .read(onboardingProvider.notifier)
          .updateDescription(_descriptionController.text);
    }
  }

  @override
  void dispose() {
    _displayNameController.removeListener(_updateDisplayName);
    _descriptionController.removeListener(_updateDescription);
    _displayNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCompleteOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create the profile
      final onboardingState = ref.read(onboardingStateProvider.notifier);

      // Determine avatar to use
      Object? avatarToUse;
      final currentState = ref.read(onboardingProvider).value;
      if (currentState?.localAvatarBytes != null) {
        avatarToUse = currentState!.localAvatarBytes;
      } else if (currentState?.removeInitialAvatar != true &&
          currentState?.bskyProfileRecord?.avatar != null) {
        avatarToUse = currentState!.bskyProfileRecord!.avatar;
      }

      await onboardingState.createCustomProfile(
        displayName: _displayNameController.text.trim(),
        description: _descriptionController.text.trim(),
        avatar: avatarToUse,
      );

      if (!mounted) return;

      // Sync preferences from server before navigating to main
      // This ensures feeds are loaded properly after onboarding
      await ref.read(settingsProvider.notifier).syncPreferencesFromServer();

      if (!mounted) return;

      // Navigate to main screen
      context.router.replaceAll([const MainRoute()]);
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onboardingStateAsync = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    ref.listen<AsyncValue<OnboardingScreenState>>(onboardingProvider, (
      previous,
      next,
    ) {
      if (next.hasValue && next.value != null) {
        final stateValue = next.value!;
        if (_displayNameController.text.isEmpty &&
            stateValue.displayName.isNotEmpty) {
          _displayNameController.text = stateValue.displayName;
        }
        if (_descriptionController.text.isEmpty &&
            stateValue.description.isNotEmpty) {
          _descriptionController.text = stateValue.description;
        }
      }
    });

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(l10n.pageTitleCompleteProfile),
        leading: const AutoLeadingButton(),
      ),
      body: onboardingStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${l10n.errorGeneric}: $err'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: notifier.reloadProfile,
                child: Text(l10n.buttonRetry),
              ),
            ],
          ),
        ),
        data: (state) {
          final hasImportedBskyProfile = state.bskyProfileRecord != null;
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

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasImportedBskyProfile) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'We found your Bluesky profile in your repo and used it to autofill these details. You can change anything here before continuing, and this profile only appears in Spark, not on Bluesky.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          GestureDetector(
                            onTap: notifier.pickAvatar,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: avatarImageProvider,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              child: avatarImageProvider == null
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasLocalAvatar)
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: GestureDetector(
                                      onTap: notifier.revertAvatarToInitial,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.undo,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (isAvatarActive)
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: GestureDetector(
                                      onTap: notifier.clearAvatarSelection,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.removeInitialAvatar && hasInitialAvatar) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: notifier.revertAvatarToInitial,
                          icon: const Icon(Icons.undo),
                          label: const Text('Use Bluesky avatar'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            controller: _displayNameController,
                            hintText: l10n.hintDisplayName,
                            fillColor:
                                theme.inputDecorationTheme.fillColor ??
                                theme.colorScheme.surface,
                            onUndo:
                                (state.bskyProfileRecord?.displayName != null &&
                                    _displayNameController.text !=
                                        (state.bskyProfileRecord?.displayName ??
                                            ''))
                                ? notifier.resetDisplayName
                                : null,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.inputErrorRequired;
                              }
                              if (value.trim().length > 64) {
                                return 'Display Name cannot exceed '
                                    '64 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _descriptionController,
                            hintText: l10n.hintBio,
                            fillColor:
                                theme.inputDecorationTheme.fillColor ??
                                theme.colorScheme.surface,
                            maxLines: 3,
                            onUndo:
                                (state.bskyProfileRecord?.description != null &&
                                    _descriptionController.text !=
                                        (state.bskyProfileRecord?.description ??
                                            ''))
                                ? notifier.resetDescription
                                : null,
                            validator: (value) {
                              if (value != null && value.trim().length > 256) {
                                return 'Bio cannot exceed 256 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : _handleCompleteOnboarding,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(l10n.buttonConfirm),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.check),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
