import 'package:flutter/cupertino.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthPromptScreen extends StatelessWidget {
  final VoidCallback? onClose;

  const AuthPromptScreen({
    super.key,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: onClose != null ? CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onClose,
          child: const Icon(FluentIcons.dismiss_24_regular),
        ),
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
      ) : null,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  FluentIcons.sparkle_24_regular,
                  size: 80,
                  color: CupertinoColors.systemPink,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to Spark',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add an account to create videos, connect with friends, and more',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: CupertinoColors.systemPink,
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: CupertinoColors.systemGrey6,
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: CupertinoColors.systemPink,
                      ),
                    ),
                  ),
                ),
                if (onClose != null) ...[
                  const SizedBox(height: 24),
                  CupertinoButton(
                    onPressed: onClose,
                    child: const Text(
                      'Continue browsing',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
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