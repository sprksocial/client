import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/onboarding_service.dart';
import '../services/settings_service.dart';
import '../utils/app_colors.dart';
import 'import_follows_screen.dart';

class FollowModeScreen extends StatefulWidget {
  final String displayName;
  final String description;
  final dynamic avatar;

  const FollowModeScreen({super.key, required this.displayName, required this.description, required this.avatar});

  @override
  State<FollowModeScreen> createState() => _FollowModeScreenState();
}

class _FollowModeScreenState extends State<FollowModeScreen> {
  bool _isLoading = false;

  Future<void> _selectSparkExclusive() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final settingsService = Provider.of<SettingsService>(context, listen: false);
    await settingsService.setFollowMode('sprk');

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) =>
                ImportFollowsScreen(displayName: widget.displayName, description: widget.description, avatar: widget.avatar),
      ),
    );
  }

  Future<void> _selectBlueskySynced() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    final onboardingService = OnboardingService(authService);

    try {
      await settingsService.setFollowMode('bsky');
      await onboardingService.finalizeProfileCreation(
        displayName: widget.displayName,
        description: widget.description,
        avatar: widget.avatar,
      );

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      if (!mounted) return;
      // Make sure to stop loading on error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error finishing onboarding: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.white : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Choose Follow Mode'),
        centerTitle: true,
        automaticallyImplyLeading: true, // Show back button
        iconTheme: IconThemeData(color: textColor),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'How do you want to manage your follows?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Spark can manage its own list of follows, or sync with your Bluesky follows.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _selectSparkExclusive,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Spark Exclusive (Recommended)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Import your Bluesky follows (optional) and manage them independently in Spark.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.6)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _selectBlueskySynced,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: const Text('Bluesky Synced', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Your follows in Spark will mirror your Bluesky follows.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.6)),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
