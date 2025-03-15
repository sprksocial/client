import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

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
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(Ionicons.chevron_back),
        ),
        middle: const Text('Create Account'),
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
                  const SizedBox(height: 20),
                  // Email Field
                  _buildLabel('Email'),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _emailController,
                    placeholder: 'Your email address',
                    keyboardType: TextInputType.emailAddress,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(Ionicons.mail_outline, color: CupertinoColors.systemGrey),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 24),

                  // Handle Field with .sprk.so suffix
                  _buildLabel('Username'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Icon(Ionicons.at_outline, color: CupertinoColors.systemGrey),
                        ),
                        Expanded(
                          child: CupertinoTextField(
                            controller: _handleController,
                            placeholder: 'username',
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.zero,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 16),
                          child: Text(
                            '.sprk.so',
                            style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.systemGrey.resolveFrom(context),
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
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(Ionicons.lock_closed_outline, color: CupertinoColors.systemGrey),
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
                            ? Ionicons.eye_off_outline
                            : Ionicons.eye_outline,
                        color: CupertinoColors.systemGrey,
                      ),
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
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(Ionicons.ticket_outline, color: CupertinoColors.systemGrey),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Ionicons.alert_circle_outline,
                            color: CupertinoColors.systemRed,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: CupertinoColors.systemRed,
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
                      color: CupertinoColors.systemPink,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _isFormValid() && !_isRegistering
                          ? _register
                          : null,
                      child: _isRegistering
                          ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(color: CupertinoColors.systemGrey),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.only(left: 8),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Sign in'),
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
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}