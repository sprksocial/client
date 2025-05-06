import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../screens/auth_prompt_screen.dart';
import '../../../screens/create_video_screen.dart';
import '../../../screens/login_screen.dart';
import '../../../screens/messages_screen.dart';
import '../../../screens/onboarding_screen.dart';
import '../../../screens/profile_screen.dart';
import '../../../screens/search_screen.dart';
import '../../../screens/splash_screen.dart';
import '../../../main.dart';

// Define route pages for AutoRoute
// Each page should correspond to a screen in the app

@RoutePage()
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

@RoutePage()
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}

@RoutePage()
class AuthPromptPage extends StatelessWidget {
  const AuthPromptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPromptScreen();
  }
}

@RoutePage()
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingScreen();
  }
}

@RoutePage()
class CreateVideoPage extends StatelessWidget {
  const CreateVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CreateVideoScreen();
  }
}

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, @PathParam('did') required this.did});
  
  final String did;

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(did: did);
  }
}

@RoutePage()
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SearchScreen();
  }
}

@RoutePage()
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MessagesScreen();
  }
} 