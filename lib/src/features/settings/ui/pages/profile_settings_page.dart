import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/profile/providers/profile_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';

enum FollowMode { sprk, bsky }

@RoutePage()
class ProfileSettingsPage extends ConsumerStatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  ConsumerState<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends ConsumerState<ProfileSettingsPage> {
  final Map<String, FollowMode> _followModeMap = {'Spark exclusive': FollowMode.sprk, 'Bluesky synced': FollowMode.bsky};

  Future<void> _handleLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get the profile notifier and call logout
      final profileNotifier = ref.read(profileNotifierProvider().notifier);
      await profileNotifier.logout();

      // Close loading dialog
      if (mounted) {
        // Navigate to login screen
        context.router.replaceAll([const RegisterRoute()]);
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted) {
        context.router.maybePop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleFollowModeChange(FollowMode newMode) {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    settingsNotifier.setFollowMode(newMode);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final itemColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    const pinkColor = Color(0xFFE91E63);

    final displayValues = _followModeMap.keys.toList();
    final modeValues = _followModeMap.values.toList();

    final settingsState = ref.watch(settingsProvider);
    final currentFollowMode = settingsState.followMode;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: const AutoLeadingButton(),
        title: Text(
          'Profile Settings',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(color: itemColor, borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Follow Mode',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose how your follows are managed across Spark.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Spark exclusive button
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: () => _handleFollowModeChange(modeValues[0]),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentFollowMode == modeValues[0]
                                  ? pinkColor
                                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                              foregroundColor: currentFollowMode == modeValues[0]
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: currentFollowMode == modeValues[0] ? 2 : 0,
                              side: currentFollowMode == modeValues[0]
                                  ? BorderSide.none
                                  : BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, width: 0.5),
                            ),
                            child: Text(
                              displayValues[0],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: () => _handleFollowModeChange(modeValues[1]),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentFollowMode == modeValues[1]
                                  ? pinkColor
                                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                              foregroundColor: currentFollowMode == modeValues[1]
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: currentFollowMode == modeValues[1] ? 2 : 0,
                              side: currentFollowMode == modeValues[1]
                                  ? BorderSide.none
                                  : BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, width: 0.5),
                            ),
                            child: Text(
                              displayValues[1],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      currentFollowMode == FollowMode.sprk
                          ? 'You are managing follows within Spark only.'
                          : 'Your follows are synced with Bluesky.',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(FluentIcons.sign_out_24_regular, color: Colors.red),
                onTap: _handleLogout,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
