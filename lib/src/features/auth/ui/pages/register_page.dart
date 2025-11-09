import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/config/app_config.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/long_button.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/auth/providers/onboarding_providers.dart';

@RoutePage()
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _handleController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _inviteCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isRegistering = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _handleController.dispose();
    _passwordController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _isRegistering = true;
      _errorMessage = null;
    });

    final handle = '${_handleController.text}.sprk.so';

    final authNotifier = ref.read(authProvider.notifier);
    final result = await authNotifier.register(
      handle,
      _emailController.text,
      _passwordController.text,
      _inviteCodeController.text.isEmpty ? null : _inviteCodeController.text,
    );

    setState(() {
      _isRegistering = false;
    });

    if (result.isSuccess) {
      final hasProfile = await ref.read(hasSparkProfileProvider.future);
      if (!mounted) return;

      if (hasProfile) {
        context.router.replace(const FeedsRoute());
      } else {
        context.router.replace(const OnboardingRoute());
      }
    } else {
      setState(() {
        _errorMessage = result.error;
      });
    }
  }

  bool _isFormValid() {
    return !AppConfig.signupsDisabled &&
        _emailController.text.isNotEmpty &&
        _handleController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Create Account',
                    style: AppTypography.displaySmallBold.copyWith(color: colorScheme.onSurface),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (AppConfig.signupsDisabled) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(FluentIcons.warning_24_regular, color: colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'New account registration is currently disabled while we correct issues in our system. We will try to re-enable it as soon as possible.',
                              style: AppTypography.textSmallMedium.copyWith(color: colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Your email address',
                      prefixIcon: Icon(FluentIcons.mail_24_regular, color: colorScheme.primary),
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
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _handleController,
                    decoration: InputDecoration(
                      hintText: 'username',
                      prefixIcon: Icon(FluentIcons.mention_24_regular, color: colorScheme.primary),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            '.sprk.so',
                            style: AppTypography.textMediumMedium.copyWith(color: colorScheme.primary),
                          ),
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
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 24),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Your password',
                      prefixIcon: Icon(FluentIcons.key_24_regular, color: colorScheme.primary),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          _isPasswordVisible ? FluentIcons.eye_off_24_regular : FluentIcons.eye_24_regular,
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
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 14),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(FluentIcons.warning_24_regular, color: colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTypography.textSmallMedium.copyWith(color: colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),

                  if (_isRegistering)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    LongButton(
                      label: 'Create Account',
                      onPressed: _isFormValid() ? _register : null,
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: AppTypography.textMediumMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () => context.router.push(const LoginRoute()),
                        child: Text(
                          'Sign in',
                          style: AppTypography.textMediumBold.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
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
