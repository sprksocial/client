import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/core/storage/storage_constants.dart';
import 'package:sparksocial/src/features/settings/data/models/feed_setting.dart';
import 'package:sparksocial/src/features/settings/data/models/label_preference.dart';
import 'package:sparksocial/src/features/settings/providers/labeler_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';
import 'package:sparksocial/src/features/settings/ui/widgets/feed_settings_header.dart';

class FeedSettingsSheet extends ConsumerStatefulWidget {
  final List<FeedSetting> feedSettings;
  final Function(String, bool) onToggleChanged;

  const FeedSettingsSheet({
    super.key, 
    required this.feedSettings, 
    required this.onToggleChanged
  });

  @override
  ConsumerState<FeedSettingsSheet> createState() => _FeedSettingsSheetState();
}

class _FeedSettingsSheetState extends ConsumerState<FeedSettingsSheet> {
  late List<FeedSetting> _feedSettings;
  bool _isLoadingLabels = false;
  String? _labelsError;

  @override
  void initState() {
    super.initState();
    _feedSettings = List.from(widget.feedSettings);
    _loadLabelDefinitions();
  }

  // Load label definitions from the default labeler
  Future<void> _loadLabelDefinitions() async {
    setState(() {
      _isLoadingLabels = true;
      _labelsError = null;
    });

    try {
      // Get default labeler DID from provider
      final labelerDid = ref.read(defaultLabelerDidProvider);
      
      // Request labeler details using provider
      await ref.read(labelerDetailsProvider(labelerDid).future);
      
      setState(() {
        _isLoadingLabels = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _labelsError = 'Failed to load content labels: $e';
          _isLoadingLabels = false;
        });
      }
    }
  }

  // Update adult content label preferences based on hideAdultContent setting
  Future<void> _updateAdultContentPreferences(bool hideAdultContent) async {
    final labelerDid = ref.read(defaultLabelerDidProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    
    // Get the labeler details with definitions
    final labeler = await ref.read(labelerDetailsProvider(labelerDid).future);
    
    // For each label definition that has adultOnly: true
    for (final entry in labeler.labelDefinitions.entries) {
      final labelValue = entry.key;
      final definition = entry.value;
      
      // Check if this is an adult-only label
      final bool isAdultOnly = definition.adultOnly;
      
      if (isAdultOnly) {
        // Set the preference based on the hideAdultContent setting
        final newPreference = hideAdultContent 
          ? LabelPreference.hide 
          : LabelPreference.show;
        
        await settingsNotifier.setLabelPreference(
          labelerDid,
          labelValue,
          newPreference
        );
      }
    }
    
    // Force rebuild
    setState(() {});
  }

  // Handle setting changes
  void _onSettingChanged(String settingType, bool value) {
    final index = _feedSettings.indexWhere(
      (setting) => setting.settingType == settingType
    );
    
    if (index != -1) {
      setState(() {
        final setting = _feedSettings[index];
        _feedSettings[index] = FeedSetting(
          feedName: setting.feedName,
          description: setting.description,
          settingType: setting.settingType,
          isEnabled: value,
        );
      });
      
      // If this is the feed blur setting, update settings
      if (settingType == StorageKeys.feedBlurKey) {
        ref.read(settingsProvider.notifier).setFeedBlur(value);
      }
      
      // Call the parent callback
      widget.onToggleChanged(settingType, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.surface;

    // Make sure we have adequate padding for the notch/dynamic island
    final topPadding = MediaQuery.of(context).padding.top + 24.0;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), 
            topRight: Radius.circular(20)
          ),
        ),
        child: Column(
          children: [
            // Add extra padding at the top for the notch/camera hole
            SizedBox(height: topPadding),
            FeedSettingsHeader(
              onClose: () => context.router.maybePop(),
            ),
            
            // Using AutoTabsRouter.tabBar for navigation
            Expanded(
              child: AutoTabsRouter.tabBar(
                routes: [
                  // Feed Settings Tab
                  FeedSettingsTabRoute(
                    feedSettings: _feedSettings,
                    onToggleChanged: _onSettingChanged,
                  ),
                  // Content Settings Tab
                  ContentSettingsTabRoute(
                    isLoadingLabels: _isLoadingLabels,
                    labelsError: _labelsError,
                    onRetryLabels: _loadLabelDefinitions,
                    onUpdateAdultContentPreferences: _updateAdultContentPreferences,
                  ),
                ],
                builder: (context, child, controller) {
                  return Column(
                    children: [
                      // Tab bar
                      TabBar(
                        controller: controller,
                        labelColor: colorScheme.onSurface,
                        unselectedLabelColor: colorScheme.onSurface.withAlpha(127),
                        tabs: const [
                          Tab(text: "Feed"),
                          Tab(text: "Content"),
                        ],
                      ),
                      // Tab content
                      Expanded(child: child),
                    ],
                  );
                },
              ),
            ),

            // Bottom safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}