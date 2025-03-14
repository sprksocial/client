import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    // Check if user is already authenticated
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Wait for animations to complete
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    // Wait for auth service to finish loading saved session
    while (authService.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    // Check if session is valid
    final bool isSessionValid = await authService.validateSession();

    if (!mounted) return;

    if (isSessionValid) {
      // User is authenticated, go to home
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // User is not authenticated, go to login
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brightPurple.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'S',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Spark',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const CupertinoActivityIndicator(
                color: CupertinoColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}