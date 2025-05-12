import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/storage/storage_constants.dart';
import 'package:sparksocial/src/features/settings/data/models/feed_setting.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';
import 'package:sparksocial/src/features/settings/ui/widgets/feed_setting_item.dart';

class FeedSettingsList extends ConsumerWidget {
  final List<FeedSetting> feedSettings;
  final Function(int, bool) onSettingChanged;

  const FeedSettingsList({
    super.key,
    required this.feedSettings,
    required this.onSettingChanged, 
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final updatedSettings = List<FeedSetting>.from(feedSettings);

    // Update feed blur settings from provider state
    for (int i = 0; i < updatedSettings.length; i++) {
      final setting = updatedSettings[i];
      if (setting.settingType == StorageKeys.feedBlurKey) {
        final isBlurEnabled = settingsState.feedBlurEnabled;
        if (setting.isEnabled != isBlurEnabled) {
          updatedSettings[i] = FeedSetting(
            feedName: setting.feedName,
            description: setting.description,
            settingType: setting.settingType,
            isEnabled: isBlurEnabled,
          );
        }
      }
    }

    return ListView.builder(
      itemCount: updatedSettings.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final setting = updatedSettings[index];

        return FeedSettingItem(
          feedName: setting.feedName,
          description: setting.description,
          isEnabled: setting.isEnabled,
          onToggleChanged: (value) => onSettingChanged(index, value),
        );
      },
    );
  }
} 