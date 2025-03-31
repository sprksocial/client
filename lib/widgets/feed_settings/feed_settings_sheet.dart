import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/settings_service.dart';
import '../../utils/app_colors.dart';

class FeedSettingsSheet extends StatefulWidget {
  final List<FeedSetting> feedSettings;
  final Function(String, bool) onToggleChanged;

  const FeedSettingsSheet({super.key, required this.feedSettings, required this.onToggleChanged});

  @override
  State<FeedSettingsSheet> createState() => _FeedSettingsSheetState();
}

class _FeedSettingsSheetState extends State<FeedSettingsSheet> {
  late List<FeedSetting> _feedSettings;

  @override
  void initState() {
    super.initState();
    _feedSettings = List.from(widget.feedSettings);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : AppColors.background;
    final textColor = isDark ? AppColors.white : AppColors.textPrimary;

    // Make sure we have adequate padding for the notch/dynamic island
    final topPadding = MediaQuery.of(context).padding.top + 24.0;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Add extra padding at the top for the notch/camera hole
            SizedBox(height: topPadding),
            _buildHeader(context, textColor),
            Expanded(child: _buildFeedList(isDark)),
            // Bottom safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
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
          IconButton(icon: Icon(Icons.close, color: textColor), onPressed: () => Navigator.pop(context)),
          Text('Feed Settings', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 48), // For balance
        ],
      ),
    );
  }

  Widget _buildFeedList(bool isDark) {
    final itemColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final textColor = isDark ? AppColors.white : AppColors.textPrimary;

    return ListView.builder(
      itemCount: _feedSettings.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final setting = _feedSettings[index];

        // If this is the feed blur setting, get its value from the SettingsService
        if (setting.settingType == 'feed_blur') {
          final settingsService = Provider.of<SettingsService>(context);
          final isBlurEnabled = settingsService.feedBlurEnabled;

          // Update local state if it differs from service
          if (setting.isEnabled != isBlurEnabled) {
            _feedSettings[index] = FeedSetting(
              feedName: setting.feedName,
              description: setting.description,
              settingType: setting.settingType,
              isEnabled: isBlurEnabled,
            );
          }
        }

        return FeedSettingItem(
          feedName: setting.feedName,
          description: setting.description,
          isEnabled: setting.isEnabled,
          itemColor: itemColor,
          textColor: textColor,
          onToggleChanged: (value) {
            // Update local state first
            setState(() {
              _feedSettings[index] = FeedSetting(
                feedName: setting.feedName,
                description: setting.description,
                settingType: setting.settingType,
                isEnabled: value,
              );
            });

            // If this is the feed blur setting, update the SettingsService
            if (setting.settingType == 'feed_blur') {
              final settingsService = Provider.of<SettingsService>(context, listen: false);
              settingsService.setFeedBlur(value);
            }

            // Then call the parent callback
            widget.onToggleChanged(setting.settingType, value);
          },
        );
      },
    );
  }
}

class FeedSetting {
  final String feedName;
  final String settingType;
  final String? description;
  final bool isEnabled;

  const FeedSetting({required this.feedName, required this.isEnabled, this.description, required this.settingType});
}

class FeedSettingItem extends StatelessWidget {
  final String feedName;
  final String? description;
  final bool isEnabled;
  final Color itemColor;
  final Color textColor;
  final ValueChanged<bool> onToggleChanged;

  const FeedSettingItem({
    super.key,
    required this.feedName,
    this.description,
    required this.isEnabled,
    required this.itemColor,
    required this.textColor,
    required this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(color: itemColor, borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(feedName, style: TextStyle(color: textColor, fontSize: 16)),
            subtitle:
                description != null
                    ? Text(description!, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12))
                    : null,
            trailing: Switch(
              value: isEnabled,
              onChanged: onToggleChanged,
              activeColor: AppColors.pink,
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade600,
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
            onTap: () {
              // Toggle when tapping anywhere on the list tile
              onToggleChanged(!isEnabled);
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
        ),
      ),
    );
  }
}
