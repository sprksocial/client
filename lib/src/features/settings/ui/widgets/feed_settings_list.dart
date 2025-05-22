import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/storage/storage_constants.dart';
import 'package:sparksocial/src/features/settings/data/models/feed_setting.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';
import 'package:sparksocial/src/features/settings/ui/widgets/feed_setting_item.dart';

class FeedSettingsList extends ConsumerWidget {
  final Function(String, bool) onSettingChanged;

  const FeedSettingsList({super.key, required this.onSettingChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final List<FeedSetting> displayableSettings = [
      FeedSetting(
        feedName: 'Following',
        settingType: StorageKeys.followingFeedEnabledKey,
        isEnabled: settingsState.followingFeedEnabled,
      ),
      FeedSetting(feedName: 'For You', settingType: StorageKeys.forYouFeedEnabledKey, isEnabled: settingsState.forYouFeedEnabled),
      FeedSetting(feedName: 'Latest', settingType: StorageKeys.latestFeedEnabledKey, isEnabled: settingsState.latestFeedEnabled),
      FeedSetting(
        feedName: 'Disable Background Blur',
        settingType: StorageKeys.feedBlurKey,
        description: 'Turn off the background blur effect on media',
        // Note: isEnabled for this specific setting is inverted in the UI
        // The provider stores feedBlurEnabled (true if blur is on)
        // The UI shows "Disable Background Blur" (true if blur is off)
        isEnabled: !settingsState.feedBlurEnabled,
      ),
    ];

    return ListView.builder(
      itemCount: displayableSettings.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final setting = displayableSettings[index];

        return FeedSettingItem(
          feedName: setting.feedName,
          description: setting.description,
          isEnabled: setting.isEnabled,
          onToggleChanged: (value) => onSettingChanged(setting.settingType, value),
        );
      },
    );
  }
}
