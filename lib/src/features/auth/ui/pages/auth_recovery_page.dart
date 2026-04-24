import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/long_button.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/auth/providers/onboarding_providers.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

@RoutePage()
class AuthRecoveryPage extends ConsumerStatefulWidget {
  const AuthRecoveryPage({this.handle = '', super.key});

  final String handle;

  @override
  ConsumerState<AuthRecoveryPage> createState() => _AuthRecoveryPageState();
}

class _AuthRecoveryPageState extends ConsumerState<AuthRecoveryPage> {
  late final TextEditingController _handleController;
  final _formKey = GlobalKey<FormState>();
  bool _isCompletingOAuth = false;

  @override
  void initState() {
    super.initState();
    _handleController = TextEditingController(text: widget.handle);
    _handleController.addListener(_onHandleChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TextInput.ensureInitialized();
    });
  }

  @override
  void dispose() {
    _handleController.removeListener(_onHandleChanged);
    _handleController.dispose();
    super.dispose();
  }

  void _onHandleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initiateOAuth() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final handle = _handleController.text.trim();

    try {
      final authUrl = await authNotifier.initiateOAuth(handle);

      if (!mounted) return;

      String callbackUrl;
      try {
        callbackUrl = await FlutterWebAuth2.authenticate(
          url: authUrl,
          callbackUrlScheme: 'sprk',
        );
      } on PlatformException catch (e) {
        if (e.code == 'CANCELED') {
          if (!mounted) return;
          setState(() {
            _isCompletingOAuth = false;
          });
          authNotifier.resetOAuthState();
          return;
        }
        rethrow;
      }

      if (!mounted) return;

      setState(() {
        _isCompletingOAuth = true;
      });

      final completeResult = await authNotifier.completeOAuth(callbackUrl);

      if (!mounted) return;

      if (completeResult.isSuccess) {
        final hasSparkProfile = await ref
            .read(onboardingRepositoryProvider)
            .hasSparkProfile();

        if (!mounted) return;

        if (hasSparkProfile) {
          await ref.read(settingsProvider.notifier).syncPreferencesFromServer();

          if (!mounted) return;

          context.router.replaceAll([const MainRoute()]);
        } else {
          context.router.replaceAll([const OnboardingRoute()]);
        }
      } else {
        setState(() {
          _isCompletingOAuth = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCompletingOAuth = false;
      });
      final errorMessage = e is PlatformException
          ? AppLocalizations.of(context).errorSignInFailed(e.message ?? e.code)
          : AppLocalizations.of(context).errorSignInFailed(e.toString());
      authNotifier.resetOAuthState(error: errorMessage);
    }
  }

  void _goToGetStarted() {
    ref.read(authProvider.notifier).resetOAuthState();
    context.router.replaceAll([const RegisterRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLoading = ref.watch(
      authProvider.select((state) => state.isLoading),
    );
    final error = ref.watch(authProvider.select((state) => state.error));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isCompletingOAuth) ...[
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 16),
                    Text(
                      l10n.errorCompletingSignIn,
                      style: AppTypography.textMediumMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Icon(
                      FluentIcons.key_24_regular,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.pageTitleSignInAgain,
                      style: AppTypography.displaySmallBold.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.messageSavedSessionRecovery,
                      style: AppTypography.textMediumMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _handleController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          FluentIcons.person_24_regular,
                          color: colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.error),
                        ),
                      ),
                      style: AppTypography.textMediumMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      validator: (value) {
                        final handle = value?.trim() ?? '';
                        if (handle.isEmpty) {
                          return l10n.errorEnterHandle;
                        }
                        return null;
                      },
                      onEditingComplete: _initiateOAuth,
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        error,
                        style: AppTypography.textSmallMedium.copyWith(
                          color: colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Opacity(
                      opacity: isLoading ? 0.5 : 1.0,
                      child: LongButton(
                        label: l10n.buttonContinueAs(
                          _handleController.text.trim(),
                        ),
                        onPressed: isLoading ? null : _initiateOAuth,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LongButton(
                      label: l10n.buttonGoToGetStarted,
                      variant: LongButtonVariant.regular,
                      onPressed: isLoading ? null : _goToGetStarted,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
