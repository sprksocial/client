import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';

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
      final success = await authService.login(_handleController.text.trim(), _passwordController.text);

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
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
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
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: SvgPicture.asset(
                      isDarkMode ? 'assets/images/logo_dark_mode.svg' : 'assets/images/logo_light_mode.svg',
                      width: 100,
                      height: 100,
                    ),
                  ),

                  // Title
                  Text(
                    'Login to your account',
                    style: TextStyle(color: AppTheme.getTextColor(context), fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Handle field
                  AutofillGroup(
                    child: Column(
                      children: [
                        TextField(
                          controller: _handleController,
                          focusNode: _handleFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Handle',
                            prefixIcon: const Icon(FluentIcons.person_24_regular, color: AppColors.primary),
                            filled: true,
                            fillColor: isDarkMode ? AppColors.deepPurple : Colors.grey[200],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: TextStyle(color: AppTheme.getTextColor(context)),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username, AutofillHints.email],
                          onEditingComplete: () => _passwordFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(FluentIcons.lock_closed_24_regular, color: AppColors.primary),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword ? FluentIcons.eye_24_regular : FluentIcons.eye_off_24_regular,
                                color: AppColors.primary,
                              ),
                            ),
                            filled: true,
                            fillColor: isDarkMode ? AppColors.deepPurple : Colors.grey[200],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: TextStyle(color: AppTheme.getTextColor(context)),
                          obscureText: _obscurePassword,
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
                        style: const TextStyle(color: AppColors.error, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Login button
                  ElevatedButton(
                    onPressed: authService.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                    ),
                    child:
                        authService.isLoading
                            ? const CircularProgressIndicator(color: AppColors.white)
                            : const Text('Login', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
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
