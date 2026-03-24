import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_overlay_back_button.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/long_button.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/auth/providers/onboarding_providers.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

@RoutePage()
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _handleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _handleFocusNode = FocusNode();
  bool _hasReceivedCallback = false;
  bool _isCompletingOAuth = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TextInput.ensureInitialized();
    });
  }

  @override
  void dispose() {
    _handleController.dispose();
    _handleFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initiateOAuth() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authNotifier = ref.read(authProvider.notifier);
      final handle = _handleController.text.trim();

      try {
        // Initiate OAuth flow - this returns the authorization URL
        final authUrl = await authNotifier.initiateOAuth(handle);

        if (!mounted) return;

        // Open the browser for OAuth authentication
        String callbackUrl;
        try {
          callbackUrl = await FlutterWebAuth2.authenticate(
            url: authUrl,
            callbackUrlScheme: 'sprk',
          );
        } on PlatformException catch (e) {
          if (e.code == 'CANCELED') {
            // User cancelled the OAuth flow - reset loading state
            if (!mounted) return;
            setState(() {
              _hasReceivedCallback = false;
              _isCompletingOAuth = false;
            });
            authNotifier.resetOAuthState();
            return;
          }
          // Re-throw other platform exceptions to be handled below
          rethrow;
        }

        if (!mounted) return;

        // Mark that we've received the callback - now we're completing OAuth
        setState(() {
          _hasReceivedCallback = true;
          _isCompletingOAuth = true;
        });

        // Complete the OAuth flow with the callback URL
        final completeResult = await authNotifier.completeOAuth(callbackUrl);

        if (!mounted) return;

        if (completeResult.isSuccess) {
          final hasSparkProfile = await ref
              .read(onboardingRepositoryProvider)
              .hasSparkProfile();

          if (!mounted) return;

          if (hasSparkProfile) {
            // Sync preferences from server before navigating to feed
            await ref
                .read(settingsProvider.notifier)
                .syncPreferencesFromServer();

            if (!mounted) return;

            context.router.replaceAll([const MainRoute()]);
          } else {
            context.router.replaceAll([const OnboardingRoute()]);
          }
        } else {
          // OAuth completion failed - reset callback state to show input again
          if (!mounted) return;
          setState(() {
            _hasReceivedCallback = false;
            _isCompletingOAuth = false;
          });
        }
      } catch (e) {
        // Reset loading state for any errors
        if (!mounted) return;
        setState(() {
          _hasReceivedCallback = false;
          _isCompletingOAuth = false;
        });
        final errorMessage = e is PlatformException
            ? 'Login failed: ${e.message ?? e.code}'
            : 'Login failed: $e';
        authNotifier.resetOAuthState(error: errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      authProvider.select((state) => state.isLoading),
    );
    final error = ref.watch(authProvider.select((state) => state.error));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_hasReceivedCallback) ...[
                        Text(
                          'Sign In',
                          style: AppTypography.displaySmallBold.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your handle to continue with OAuth',
                          style: AppTypography.textMediumMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                      ],

                      if (!_hasReceivedCallback) ...[
                        TextFormField(
                          controller: _handleController,
                          focusNode: _handleFocusNode,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: 'jerry.sprk.so',
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
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                              ),
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
                          onEditingComplete: _initiateOAuth,
                        ),
                        const SizedBox(height: 24),
                      ],

                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            switch (error) {
                              final String e
                                  when e.contains('must be a valid handle') =>
                                'Invalid handle',
                              final String e
                                  when e.contains('Failed to resolve') =>
                                'Could not find this handle',
                              _ => error,
                            },
                            style: AppTypography.textSmallMedium.copyWith(
                              color: colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      if (_isCompletingOAuth)
                        Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Completing sign in...',
                              style: AppTypography.textMediumMedium.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      else if (!_hasReceivedCallback)
                        Opacity(
                          opacity: isLoading ? 0.5 : 1.0,
                          child: LongButton(
                            label: 'Continue',
                            onPressed: isLoading ? null : _initiateOAuth,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Back button in top-left corner
          Positioned(
            top: 0,
            left: 0,
            child: AppOverlayBackButton(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}
