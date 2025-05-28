import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_route/auto_route.dart';
import 'package:sparksocial/src/core/config/app_config.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/auth/providers/auth_providers.dart';
import 'package:sparksocial/src/features/auth/providers/onboarding_providers.dart';
import 'package:sparksocial/src/features/auth/ui/widgets/at_account_dialog.dart';

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

    final String handle = "${_handleController.text}.sprk.so";

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/branding/gradient.webp', fit: BoxFit.cover)),
          SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: SvgPicture.asset('assets/images/logo_dark_mode.svg', height: 140, width: 140)),
                      const SizedBox(height: 21),
                      Center(
                        child: Text(
                          'Create Account',
                          style: TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: SizedBox(
                          width: 340,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text('Create your new ', style: TextStyle(color: AppColors.white, fontSize: 20, height: 1.7)),
                              SvgPicture.asset('assets/images/ataccount.svg', height: 25, width: 100),
                              const SizedBox(width: 4),
                              const ATAccountInfoIcon(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      if (AppConfig.signupsDisabled) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(FluentIcons.warning_24_regular, color: AppColors.error),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'New account registration is currently disabled while we correct issues in our system. We will try to re-enable it as soon as possible.',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Text(
                        'Email',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.white),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Your email address',
                          hintStyle: TextStyle(color: AppColors.hintText),
                          filled: true,
                          fillColor: AppColors.white.withAlpha(255),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          prefixIcon: const Icon(FluentIcons.mail_24_regular, color: AppColors.primary),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: const TextStyle(color: Colors.black),
                        onChanged: (_) => setState(() {}),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Username',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.white),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(color: AppColors.white.withAlpha(255), borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Icon(FluentIcons.mention_24_regular, color: AppColors.primary),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _handleController,
                                decoration: InputDecoration(
                                  hintText: 'username',
                                  hintStyle: TextStyle(color: AppColors.hintText),
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                style: const TextStyle(color: Colors.black),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Text('.sprk.so', style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Password',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.white),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Your password',
                          hintStyle: TextStyle(color: AppColors.hintText),
                          filled: true,
                          fillColor: AppColors.white.withAlpha(255),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          prefixIcon: const Icon(FluentIcons.key_24_regular, color: AppColors.primary),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              _isPasswordVisible ? FluentIcons.eye_off_24_regular : FluentIcons.eye_24_regular,
                              color: AppColors.primary,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: const TextStyle(color: Colors.black),
                        onChanged: (_) => setState(() {}),
                      ),

                      const SizedBox(height: 14),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(FluentIcons.warning_24_regular, color: AppColors.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            minimumSize: const Size(0, 60),
                          ),
                          onPressed: _isFormValid() && !_isRegistering ? _register : null,
                          child: _isRegistering
                              ? const CircularProgressIndicator(color: AppColors.white)
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: AppColors.white),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account?', style: TextStyle(color: AppColors.white)),
                          TextButton(
                            onPressed: () => context.router.replace(const LoginRoute()),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
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
        ],
      ),
    );
  }
}
