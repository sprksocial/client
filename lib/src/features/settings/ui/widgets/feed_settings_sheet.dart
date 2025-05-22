import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/features/settings/data/models/label_preference.dart';
import 'package:sparksocial/src/features/settings/providers/labeler_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';
import 'package:sparksocial/src/features/settings/ui/widgets/feed_settings_header.dart';
import 'package:sparksocial/src/features/settings/ui/widgets/content_settings_list.dart';
import 'package:sparksocial/src/features/settings/ui/widgets/feed_settings_list.dart';

class FeedSettingsSheet extends ConsumerStatefulWidget {
  final Function(String, bool) onToggleChanged;

  const FeedSettingsSheet({super.key, required this.onToggleChanged});

  @override
  ConsumerState<FeedSettingsSheet> createState() => _FeedSettingsSheetState();
}

class _FeedSettingsSheetState extends ConsumerState<FeedSettingsSheet> with SingleTickerProviderStateMixin {
  bool _isLoadingLabels = false;
  String? _labelsError;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadLabelDefinitions();
    _tabController = TabController(length: 2, vsync: this);
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

      if (mounted) {
        setState(() => _isLoadingLabels = false);
      }
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
        final newPreference = hideAdultContent ? LabelPreference.hide : LabelPreference.show;

        await settingsNotifier.setLabelPreference(labelerDid, labelValue, newPreference);
      }
    }

    // Force rebuild
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;

    // Make sure we have adequate padding for the notch/dynamic island
    final topPadding = MediaQuery.of(context).padding.top;

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
            SizedBox(height: topPadding + 8),
            FeedSettingsHeader(onClose: () => context.router.maybePop()),
            Expanded(
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: textColor,
                    unselectedLabelColor: textColor.withAlpha(127),
                    tabs: const [Tab(text: "Feed"), Tab(text: "Content")],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        FeedSettingsList(onSettingChanged: widget.onToggleChanged),
                        ContentSettingsList(
                          isLoadingLabels: _isLoadingLabels,
                          labelsError: _labelsError,
                          onRetryLabels: _loadLabelDefinitions,
                          onUpdateAdultContentPreferences: _updateAdultContentPreferences,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom safe area
            if (MediaQuery.of(context).padding.bottom > 0) SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
