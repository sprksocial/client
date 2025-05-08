import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../screens/create_video_screen.dart';
import '../../../screens/login_screen.dart';
import '../../../screens/messages_screen.dart';
import '../../../screens/onboarding_screen.dart';
import '../../../screens/profile_screen.dart';
import '../../../screens/search_screen.dart';
import '../../../screens/splash_screen.dart';
import '../../../main.dart';

// Here's where we add the pages for the router
export 'package:sparksocial/src/features/auth/ui/pages/auth_prompt_page.dart';

// These pages are temporary and will be replaced with the actual pages when they are implemented in the new architecture

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