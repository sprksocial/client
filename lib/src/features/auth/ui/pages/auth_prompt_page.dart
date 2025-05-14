import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/theme/data/models/app_theme.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

@RoutePage()
class AuthPromptPage extends StatelessWidget {
  final VoidCallback? onClose;

  const AuthPromptPage({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: onClose != null
          ? AppBar(
              leading: IconButton(
                padding: EdgeInsets.zero,
                onPressed: onClose,
                icon: Icon(FluentIcons.dismiss_24_regular, color: AppTheme.getTextColor(context)),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/branding/gradient.webp',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      isDarkMode ? 'assets/images/logo_dark_mode.svg' : 'assets/images/logo_dark_mode.svg',
                      height: 140,
                      width: 140,
                    ),
                    const SizedBox(height: 21),
                    Text(
                      'Welcome to Spark',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 340,
                      child: Text(
                        'Add an account to create videos, connect with friends, and more.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        minimumSize: const Size(320, 60),
                      ),
                      onPressed: () {
                        // TODO: LoginRoute
                        context.router.push();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Login with ',
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20, color: AppColors.white),
                          ),
                          SvgPicture.asset(
                            'assets/images/ataccount.svg',
                            height: 22,
                            width: 100,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        minimumSize: const Size(320, 60),
                      ),
                      onPressed: () {
                        // TODO: OnboardingRoute
                        context.router.push();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Create an ',
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20, color: AppColors.white),
                          ),
                          SvgPicture.asset(
                            'assets/images/ataccount.svg',
                            height: 22,
                            width: 100,
                          ),
                        ],
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
        ],
      ),
    );
  }
} 