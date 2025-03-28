import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthPromptScreen extends StatelessWidget {
  final VoidCallback? onClose;

  const AuthPromptScreen({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar:
          onClose != null
              ? AppBar(
                leading: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: onClose,
                  icon: Icon(FluentIcons.dismiss_24_regular, color: AppTheme.getTextColor(context)),
                ),
                backgroundColor: isDarkMode ? AppColors.darkBackground.withAlpha(242) : AppColors.background,
                elevation: 0,
              )
              : null,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  isDarkMode ? 'assets/images/logo_dark_mode.svg' : 'assets/images/logo_light_mode.svg',
                  height: 80,
                  width: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to Spark',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.getTextColor(context)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Add an account to create videos, connect with friends, and more',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 16),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
                    },
                    child: const Text('Register', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                if (onClose != null) ...[
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: onClose,
                    child: Text('Continue browsing', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
