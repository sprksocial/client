import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/long_button.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/utils/uppercase_text_formatter.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/auth/providers/onboarding_providers.dart';

@RoutePage()
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _handleController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authCodeController = TextEditingController();
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  bool _showAuthCodeField = false;

  final _handleFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _authCodeFocusNode = FocusNode();

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
    _passwordController.dispose();
    _authCodeController.dispose();
    _handleFocusNode.dispose();
    _passwordFocusNode.dispose();
    _authCodeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authNotifier = ref.read(authProvider.notifier);

      final result = await authNotifier.login(
        _handleController.text.trim(),
        _passwordController.text,
        authCode: _showAuthCodeField ? _authCodeController.text.trim() : null,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        TextInput.finishAutofillContext();
        final hasSparkProfile = await ref.read(onboardingRepositoryProvider).hasSparkProfile();

        if (!mounted) return;

        if (hasSparkProfile) {
          context.router.replaceAll([const FeedsRoute()]);
        } else {
          context.router.replaceAll([const OnboardingRoute()]);
        }
      } else if (result.isCodeRequired) {
        setState(() {
          _showAuthCodeField = true;
        });
        _authCodeFocusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider.select((state) => state.isLoading));
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sign In',
                    style: AppTypography.displaySmallBold.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  AutofillGroup(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _handleController,
                          focusNode: _handleFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Handle',
                            prefixIcon: Icon(FluentIcons.person_24_regular, color: colorScheme.primary),
                            filled: true,
                            fillColor: colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          style: AppTypography.textMediumMedium.copyWith(color: colorScheme.onSurface),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username, AutofillHints.email],
                          onEditingComplete: _passwordFocusNode.requestFocus,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(FluentIcons.lock_closed_24_regular, color: colorScheme.primary),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword ? FluentIcons.eye_24_regular : FluentIcons.eye_off_24_regular,
                                color: colorScheme.primary,
                              ),
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          style: AppTypography.textMediumMedium.copyWith(color: colorScheme.onSurface),
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          autofillHints: const [AutofillHints.password],
                          onEditingComplete: () {
                            if (_showAuthCodeField) {
                              _authCodeFocusNode.requestFocus();
                            } else {
                              TextInput.finishAutofillContext();
                              _login();
                            }
                          },
                        ),

                        if (_showAuthCodeField) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _authCodeController,
                            focusNode: _authCodeFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Enter code (e.g., ABCD1-ZXC45)',
                              helperText: 'Enter the code from your email',
                              prefixIcon: Icon(FluentIcons.key_24_regular, color: colorScheme.primary),
                              filled: true,
                              fillColor: colorScheme.surface,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            style: AppTypography.textMediumMedium.copyWith(color: colorScheme.onSurface),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
                              const UpperCaseTextFormatter(),
                            ],
                            onEditingComplete: () {
                              TextInput.finishAutofillContext();
                              _login();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        switch (error) {
                          final String e when e.contains('must be a valid handle') => 'Invalid handle',
                          final String e when e.contains('identifier or password') => 'Invalid handle or password',
                          _ => error,
                        },
                        style: AppTypography.textSmallMedium.copyWith(color: colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    LongButton(
                      label: _showAuthCodeField ? 'Verify Code' : 'Login',
                      onPressed: _login,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
