import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/settings/providers/labeler_provider.dart';
import 'package:sparksocial/src/features/settings/providers/settings_provider.dart';
import 'package:sparksocial/src/features/settings/ui/widgets/content_label_preference.dart';
import 'package:sparksocial/src/features/settings/ui/widgets/feed_setting_item.dart';

class ContentSettingsList extends ConsumerWidget {
  final Function(bool) onUpdateAdultContentPreferences;
  final bool isLoadingLabels;
  final String? labelsError;
  final VoidCallback onRetryLabels;

  const ContentSettingsList({
    super.key,
    required this.onUpdateAdultContentPreferences,
    required this.isLoadingLabels,
    required this.labelsError,
    required this.onRetryLabels,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final labelerDid = ref.read(defaultLabelerDidProvider);

    if (isLoadingLabels) {
      return const Center(child: CircularProgressIndicator());
    }

    if (labelsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(labelsError!, style: TextStyle(color: AppColors.red, fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetryLabels,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink, foregroundColor: AppColors.white),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final labelerDetailsAsync = ref.watch(labelerDetailsProvider(labelerDid));

    return labelerDetailsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error loading labels: $error', style: TextStyle(color: textColor))),
      data: (labeler) {
        final definitions = labeler.labelDefinitions;

        if (definitions.isEmpty) {
          return Center(child: Text('No content labels available', style: TextStyle(color: textColor)));
        }

        // Sort labels: adult content first, then regular content
        List<String> sortedLabels = definitions.keys.toList();
        sortedLabels.sort((a, b) {
          bool isAdultA = definitions[a]?.adultOnly ?? false;
          bool isAdultB = definitions[b]?.adultOnly ?? false;

          // Adult labels first (true before false)
          if (isAdultA && !isAdultB) return -1;
          if (!isAdultA && isAdultB) return 1;

          // If both are adult or both are not adult, sort alphabetically
          return a.compareTo(b);
        });

        return ListView.builder(
          itemCount: definitions.length + 1, // +1 for the Adult Content switch
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            // Add the Adult Content switch at the top
            if (index == 0) {
              final hideAdultContent = ref.watch(settingsProvider).hideAdultContent;
        
              return FeedSettingItem(
                feedName: 'Hide Adult Content',
                description: 'Hide all posts with adult content labels',
                isEnabled: hideAdultContent,
                onToggleChanged: (value) async {
                  // Update the setting
                  await ref.read(settingsProvider.notifier).setHideAdultContent(value);
        
                  // Update all adult-only label preferences
                  await onUpdateAdultContentPreferences(value);
                },
              );
            }
        
            // Adjust index for label definitions using our sorted list
            final labelsIndex = index - 1;
            final labelKey = sortedLabels[labelsIndex];
            final labelValue = definitions[labelKey];
        
            if (labelValue == null) return const SizedBox();
        
            // Extract info from the LabelValue model
            String displayName = labelValue.value;
            String description = '';
        
            if (labelValue.locales.isNotEmpty) {
              // Get the first locale (assumed to be English)
              final enLocale = labelValue.locales.first;
              displayName = enLocale.name;
              description = enLocale.description;
            }
        
            return ContentLabelPreference(
              labelValue: labelKey,
              displayName: displayName,
              description: description,
              labelDid: labelerDid,
            );
          },
        );
      },
    );
  }
}
