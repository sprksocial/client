import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/long_button.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/auth/providers/onboarding_providers.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

/// Registration page that uses OAuth to create an account
@RoutePage()
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  bool _hasReceivedCallback = false;
  bool _isCompletingOAuth = false;

  Future<void> _initiateOAuth() async {
    final authNotifier = ref.read(authProvider.notifier);

    try {
      // Initiate OAuth flow without handle, using pds.sprk.so service
      final authUrl = await authNotifier.initiateOAuthWithService(
        'pds.sprk.so',
      );

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
          await ref.read(settingsProvider.notifier).syncPreferencesFromServer();

          if (!mounted) return;

          context.router.replaceAll([const MainRoute()]);
        } else {
          context.router.replaceAll([const OnboardingRoute()]);
        }
      } else {
        // OAuth completion failed - reset callback state
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
          ? 'Sign up failed: ${e.message ?? e.code}'
          : 'Sign up failed: $e';
      authNotifier.resetOAuthState(error: errorMessage);
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
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Main content - centered
              Expanded(
                child: Center(
                  child: _isCompletingOAuth
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Completing sign up...',
                              style: AppTypography.textMediumMedium.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Spark logo
                            SvgPicture.asset(
                              'images/sprk.svg',
                              height: 100,
                              width: 100,
                              package: 'assets',
                              colorFilter: isDarkMode
                                  ? null
                                  : const ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.srcIn,
                                    ),
                            ),
                            const SizedBox(height: 32),
                            // Welcome text
                            Text(
                              'Welcome!',
                              style: AppTypography.displaySmallBold.copyWith(
                                color: colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Share videos, connect with friends,\n'
                              'and take back your timeline.',
                              style: AppTypography.textMediumMedium.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (error != null) ...[
                              const SizedBox(height: 24),
                              Text(
                                error,
                                style: AppTypography.textSmallMedium.copyWith(
                                  color: colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                ),
              ),
              // Buttons at the bottom
              if (!_hasReceivedCallback) ...[
                Opacity(
                  opacity: isLoading ? 0.5 : 1.0,
                  child: LongButton(
                    label: 'Get Started',
                    onPressed: isLoading ? null : _initiateOAuth,
                  ),
                ),
                const SizedBox(height: 12),
                LongButton(
                  label: 'I already have an account',
                  variant: LongButtonVariant.regular,
                  onPressed: () => context.router.push(const LoginRoute()),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
