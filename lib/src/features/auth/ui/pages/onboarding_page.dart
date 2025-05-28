import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/auth/data/models/onboarding_screen_state.dart'; // Import for OnboardingScreenState
import 'package:sparksocial/src/features/auth/providers/onboarding_notifier.dart';
import 'package:sparksocial/src/core/widgets/custom_text_field.dart'; // Corrected path

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

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _descriptionController = TextEditingController();

    final initialState = ref.read(onboardingNotifierProvider);
    if (initialState.hasValue && initialState.value != null) {
      _displayNameController.text = initialState.value!.displayName;
      _descriptionController.text = initialState.value!.description;
    }

    _displayNameController.addListener(() {
      final currentProviderState = ref.read(onboardingNotifierProvider).value;
      if (currentProviderState != null && _displayNameController.text != currentProviderState.displayName) {
        ref.read(onboardingNotifierProvider.notifier).updateDisplayName(_displayNameController.text);
      }
    });

    _descriptionController.addListener(() {
      final currentProviderState = ref.read(onboardingNotifierProvider).value;
      if (currentProviderState != null && _descriptionController.text != currentProviderState.description) {
        ref.read(onboardingNotifierProvider.notifier).updateDescription(_descriptionController.text);
      }
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleNextStep() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = ref.read(onboardingNotifierProvider.notifier);
    final navData = provider.getOnboardingDataForNextStep();

    if (navData == null) {
      // This might happen if the state is error/loading, though form validation should prevent it.
      // Handle error appropriately, e.g. show a snackbar.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not retrieve profile data. Please try again.')));
      return;
    }

    dynamic avatarForNav;
    if (navData.avatarBytes != null) {
      avatarForNav = navData.avatarBytes;
    } else {
      final currentOnboardingStateValue = ref.read(onboardingNotifierProvider).value;
      avatarForNav = currentOnboardingStateValue?.bskyProfileRecord?.avatar;
    }

    context.router.push(
      ImportFollowsRoute(displayName: navData.displayName, description: navData.description, avatar: avatarForNav),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboardingStateAsync = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    ref.listen<AsyncValue<OnboardingScreenState>>(onboardingNotifierProvider, (_, next) {
      if (next.hasValue && next.value != null) {
        final stateValue = next.value!;
        if (_displayNameController.text != stateValue.displayName) {
          _displayNameController.text = stateValue.displayName;
        }
        if (_descriptionController.text != stateValue.description) {
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
        title: const Text('Complete your profile'),
        leading: const AutoLeadingButton(), // Adds back button if applicable
      ),
      body: onboardingStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: ${err.toString()}'),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: () => notifier.reloadProfile(), child: const Text('Retry')),
            ],
          ),
        ),
        data: (state) {
          ImageProvider<Object>? avatarImageProvider;
          if (state.localAvatarBytes != null) {
            avatarImageProvider = MemoryImage(state.localAvatarBytes!);
          } else if (notifier.currentAvatarDisplayUrl != null) {
            avatarImageProvider = NetworkImage(notifier.currentAvatarDisplayUrl!);
          }

          final bool hasLocalAvatar = state.localAvatarBytes != null;
          final bool isAvatarActive = hasLocalAvatar || notifier.currentAvatarDisplayUrl != null;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight, // Changed alignment for better visibility
                        children: [
                          GestureDetector(
                            onTap: () => notifier.pickAvatar(),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: avatarImageProvider,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest, // Placeholder color
                              child: avatarImageProvider == null
                                  ? Icon(Icons.person, size: 50, color: theme.colorScheme.onSurfaceVariant)
                                  : null,
                            ),
                          ),
                          Positioned(
                            // Positioned to avoid overlap if both are shown
                            right: 0,
                            bottom: 0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasLocalAvatar) // Show undo if a local avatar is picked
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: GestureDetector(
                                      onTap: () => notifier.revertAvatarToInitial(),
                                      child: Container(
                                        decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(Icons.undo, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                if (isAvatarActive) // Show close if any avatar is active
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: GestureDetector(
                                      onTap: () => notifier.clearAvatarSelection(),
                                      child: Container(
                                        decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            controller: _displayNameController,
                            hintText: 'Display Name',
                            fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
                            onUndo: state.bskyProfileRecord?.displayName != null ? () => notifier.resetDisplayName() : null,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Display Name is required';
                              if (value.trim().length > 64) return 'Display Name cannot exceed 64 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _descriptionController,
                            hintText: 'Bio',
                            fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
                            maxLines: 3,
                            onUndo: state.bskyProfileRecord?.description != null ? () => notifier.resetDescription() : null,
                            validator: (value) {
                              if (value != null && value.trim().length > 256) return 'Bio cannot exceed 256 characters';
                              return null; // Bio is optional
                            },
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: _handleNextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary, // AppColors.pink
                                foregroundColor: colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [Text('Next'), SizedBox(width: 8), Icon(Icons.arrow_forward)],
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
