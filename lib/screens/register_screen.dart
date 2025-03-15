import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

    final authService = Provider.of<AuthService>(context, listen: false);

    // Get the handle and add the domain suffix
    final String handle = "${_handleController.text}.sprk.so";

    final success = await authService.register(
      handle,
      _emailController.text,
      _passwordController.text,
      _inviteCodeController.text.isEmpty ? null : _inviteCodeController.text,
    );

    setState(() {
      _isRegistering = false;
    });

    if (success) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      setState(() {
        _errorMessage = authService.error;
      });
    }
  }

  bool _isFormValid() {
    return _emailController.text.isNotEmpty &&
        _handleController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.getBackgroundColor(context, false),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDarkMode 
            ? AppColors.darkBackground.withAlpha(242)
            : AppColors.background,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(
            FluentIcons.chevron_left_24_regular, 
            color: AppTheme.getTextColor(context),
          ),
        ),
        middle: Text(
          'Create Account',
          style: TextStyle(
            color: AppTheme.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo at the top
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 30, top: 10),
                      child: SvgPicture.asset(
                        isDarkMode 
                            ? 'assets/images/logo_dark_mode.svg'
                            : 'assets/images/logo_light_mode.svg',
                      ),
                    ),
                  ),

                  // Email Field
                  _buildLabel('Email'),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _emailController,
                    placeholder: 'Your email address',
                    keyboardType: TextInputType.emailAddress,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.deepPurple
                          : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(
                        FluentIcons.mail_24_regular, 
                        color: AppColors.primary,
                      ),
                    ),
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                    ),
                    placeholderStyle: TextStyle(
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 24),

                  // Handle Field with .sprk.so suffix
                  _buildLabel('Username'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.deepPurple
                          : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Icon(
                            FluentIcons.mention_24_regular, 
                            color: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: CupertinoTextField(
                            controller: _handleController,
                            placeholder: 'username',
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                            ),
                            placeholderStyle: TextStyle(
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Text(
                            '.sprk.so',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Password Field
                  _buildLabel('Password'),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _passwordController,
                    placeholder: 'Your password',
                    obscureText: !_isPasswordVisible,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.deepPurple
                          : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(
                        FluentIcons.key_24_regular, 
                        color: AppColors.primary,
                      ),
                    ),
                    suffix: CupertinoButton(
                      padding: const EdgeInsets.only(right: 8),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      child: Icon(
                        _isPasswordVisible
                            ? FluentIcons.eye_off_24_regular
                            : FluentIcons.eye_24_regular,
                        color: AppColors.primary,
                      ),
                    ),
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                    ),
                    placeholderStyle: TextStyle(
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 24),

                  // Invite Code Field (Optional)
                  _buildLabel('Invite Code (Optional)'),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _inviteCodeController,
                    placeholder: 'Enter invite code if you have one',
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.deepPurple
                          : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(
                        FluentIcons.tag_24_regular, 
                        color: AppColors.primary,
                      ),
                    ),
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                    ),
                    placeholderStyle: TextStyle(
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                  ),

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
                          const Icon(
                            FluentIcons.warning_24_regular,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _isFormValid() && !_isRegistering
                          ? _register
                          : null,
                      child: _isRegistering
                          ? const CupertinoActivityIndicator(color: AppColors.white)
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: AppTheme.getSecondaryTextColor(context),
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.only(left: 8),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppTheme.getTextColor(context),
      ),
    );
  }
}