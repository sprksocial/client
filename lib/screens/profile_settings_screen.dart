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

  String _getDisplayMode(String internalMode) {
    return _followModeMap.entries
        .firstWhere((entry) => entry.value == internalMode, orElse: () => _followModeMap.entries.first)
        .key;
  }

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
                          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(color: itemColor, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Follow Mode', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Choose how you want to manage your follows across Spark and Bluesky',
                style: TextStyle(color: textColor.withAlpha(179), fontSize: 12),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: textColor.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _getDisplayMode(settingsService.followMode),
                    isExpanded: true,
                    dropdownColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    icon: Icon(FluentIcons.chevron_down_24_regular, color: textColor),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        // Convert selected display string back to internal key
                        final internalMode = _followModeMap[newValue];
                        if (internalMode != null) {
                          settingsService.setFollowMode(internalMode);
                        }
                      }
                    },
                    items:
                        _followModeMap.keys.map<DropdownMenuItem<String>>((String displayValue) {
                          return DropdownMenuItem<String>(
                            value: displayValue,
                            child: Text(displayValue, style: TextStyle(color: textColor)),
                          );
                        }).toList(),
                    style: TextStyle(color: textColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
