import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/buttons/primary_button.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/ui/foundation/colors.dart';

@RoutePage()
class AuthPromptPage extends StatelessWidget {
  const AuthPromptPage({super.key, this.onClose});
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: onClose != null
          ? AppBar(
              leading: IconButton(
                padding: EdgeInsets.zero,
                onPressed: onClose,
                icon: Icon(FluentIcons.dismiss_24_regular, color: Theme.of(context).colorScheme.onSurface),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('branding/gradient.webp', fit: BoxFit.cover, package: 'assets'),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      isDarkMode ? 'assets/images/logo_dark_mode.svg' : 'assets/images/logo_dark_mode.svg',
                      height: 140,
                      width: 140,
                    ),
                    const SizedBox(height: 21),
                    const Text(
                      'Welcome to Spark',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    const SizedBox(
                      width: 340,
                      child: Text(
                        'Add an account to create videos, connect with friends, and more.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.white, fontSize: 20, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 60),
                    PrimaryButton(
                      text: 'Login with ',
                      trailing: SvgPicture.asset('assets/images/ataccount.svg', height: 22, width: 100),
                      onPressed: () {
                        context.router.push(const LoginRoute());
                      },
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'Create an ',
                      trailing: SvgPicture.asset('assets/images/ataccount.svg', height: 22, width: 100),
                      onPressed: () {
                        context.router.push(const RegisterRoute());
                      },
                    ),
                    if (onClose != null) ...[
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: onClose,
                        child: Text('Continue browsing', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
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
