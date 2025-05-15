import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../utils/app_colors.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final Map<String, String> _followModeMap = {'Spark exclusive': 'sprk', 'Bluesky synced': 'bsky'};

  void _handleLogout() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : AppColors.background;
    final textColor = isDark ? AppColors.white : AppColors.textPrimary;
    final itemColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final settingsService = Provider.of<SettingsService>(context);

    // Make sure we have adequate padding for the notch/dynamic island
    final topPadding = MediaQuery.of(context).padding.top + 24.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Material(
        color: backgroundColor,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              // Add extra padding at the top for the notch/camera hole
              SizedBox(height: topPadding),
              _buildHeader(context, textColor),

              // Main content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFollowModeItem(
                      isDark: isDark,
                      itemColor: itemColor,
                      textColor: textColor,
                      settingsService: settingsService,
                    ),

                    const SizedBox(height: 16),

                    // Logout button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                            trailing: Icon(FluentIcons.sign_out_24_regular, color: Colors.red),
                            onTap: _handleLogout,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(FluentIcons.arrow_left_24_regular, color: textColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text('Profile Settings', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 48), // For balance
        ],
      ),
    );
  }

  Widget _buildFollowModeItem({
    required bool isDark,
    required Color itemColor,
    required Color textColor,
    required SettingsService settingsService,
  }) {
    final currentMode = settingsService.followMode;
    final displayValues = _followModeMap.keys.toList(); // ['Spark exclusive', 'Bluesky synced']
    final internalValues = _followModeMap.values.toList(); // ['sprk', 'bsky']

    Widget buildModeButton(String displayValue, String internalValue) {
      final bool isSelected = currentMode == internalValue;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ElevatedButton(
            onPressed: () {
              if (!isSelected) {
                settingsService.setFollowMode(internalValue);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? AppColors.pink : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              foregroundColor: isSelected ? Colors.white : textColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: isSelected ? 2 : 0,
              side:
                  isSelected
                      ? BorderSide.none
                      : BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, width: 0.5),
            ),
            child: Text(displayValue, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: itemColor, // This is the overall card background
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Follow Mode', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              'Choose how your follows are managed across Spark.',
              style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildModeButton(displayValues[0], internalValues[0]), // Spark exclusive
                buildModeButton(displayValues[1], internalValues[1]), // Bluesky synced
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                currentMode == 'sprk' ? 'You are managing follows within Spark only.' : 'Your follows are synced with Bluesky.',
                style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.6)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
