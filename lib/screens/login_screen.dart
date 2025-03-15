import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _handleController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  // Add focus nodes for autofill
  final _handleFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // For autofill

  @override
  void initState() {
    super.initState();
    // Schedule autofill request for after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TextInput.ensureInitialized();
    });
  }

  @override
  void dispose() {
    _handleController.dispose();
    _passwordController.dispose();
    _handleFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.login(
        _handleController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Complete autofill when login is successful
        TextInput.finishAutofillContext(shouldSave: true);
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 40),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          CupertinoColors.systemPink,
                          CupertinoColors.systemBlue,
                        ],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'TT',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Title
                  const Text(
                    'Login to your account',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Handle field
                  AutofillGroup(
                    child: Column(
                      children: [
                        CupertinoTextField(
                          controller: _handleController,
                          focusNode: _handleFocusNode,
                          placeholder: 'Handle',
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Icon(
                              FluentIcons.person_24_regular,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          style: const TextStyle(color: CupertinoColors.black),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username, AutofillHints.email],
                          onEditingComplete: () => _passwordFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        CupertinoTextField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          placeholder: 'Password',
                          padding: const EdgeInsets.all(16),
                          obscureText: _obscurePassword,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Icon(
                              FluentIcons.lock_closed_24_regular,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          suffix: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              child: Icon(
                                _obscurePassword
                                    ? FluentIcons.eye_24_regular
                                    : FluentIcons.eye_off_24_regular,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ),
                          style: const TextStyle(color: CupertinoColors.black),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          autofillHints: const [AutofillHints.password],
                          onEditingComplete: () {
                            TextInput.finishAutofillContext();
                            _login();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error message
                  if (authService.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        authService.error!,
                        style: const TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Login button
                  CupertinoButton(
                    onPressed: authService.isLoading ? null : _login,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(12),
                    child: authService.isLoading
                        ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                        : const Text('Login'),
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