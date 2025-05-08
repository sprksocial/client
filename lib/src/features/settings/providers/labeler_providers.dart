import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/features/settings/data/models/label_preference.dart';
import 'package:sparksocial/src/features/settings/data/models/labeler.dart';
import 'package:sparksocial/src/features/settings/data/repositories/labeler_repository.dart';

part 'labeler_providers.g.dart';

/// Provider for the Labeler Repository
@riverpod
LabelerRepository labelerRepository(Ref ref) {
  return GetIt.instance<LabelerRepository>();
}

/// Provider for the list of followed labelers
@riverpod
Future<List<String>> followedLabelers(Ref ref) async {
  final repository = ref.watch(labelerRepositoryProvider);
  return repository.getFollowedLabelers();
}

/// Provider for a specific labeler's details
@riverpod
Future<Labeler> labelerDetails(Ref ref, String labelerDid) async {
  final repository = ref.watch(labelerRepositoryProvider);

  // Load labeler info
  final labeler = await repository.getLabelerInfo(labelerDid);

  // Load label definitions
  final definitions = await repository.getLabelDefinitions(labelerDid);

  // Return labeler with definitions
  return labeler.copyWith(labelDefinitions: definitions);
}

/// Provider for default labeler DID
@riverpod
String defaultLabelerDid(Ref ref) {
  return "did:plc:pbgyr67hftvpoqtvaurpsctc";
}

/// Provider for a label preference
@riverpod
Future<LabelPreference?> labelPreference(Ref ref, String labelerDid, String labelValue) async {
  final repository = ref.watch(labelerRepositoryProvider);
  final prefString = await repository.getLabelPreference(labelerDid, labelValue);

  if (prefString == null) return null;

  return LabelPreference.values.firstWhere((pref) => pref.name == prefString, orElse: () => LabelPreference.show);
}

/// Provider for determining if content should be hidden
@riverpod
Future<bool> shouldHideContent(Ref ref, List<String> contentLabels) async {
  if (contentLabels.isEmpty) return false;

  // First check for special '!hide' label which always hides content
  if (contentLabels.contains('!hide')) {
    return true;
  }

  final labelerDids = await ref.watch(followedLabelersProvider.future);

  // For each label in the content
  for (final labelValue in contentLabels) {
    // Check in each followed labeler
    for (final labelerDid in labelerDids) {
      // Get the labeler details to check label definition
      final labeler = await ref.watch(labelerDetailsProvider(labelerDid).future);
      final labelDefinition = labeler.labelDefinitions[labelValue];

      // Get preference or use default based on label definition
      LabelPreference preference;
      final userPref = await ref.watch(labelPreferenceProvider(labelerDid, labelValue).future);

      if (userPref != null) {
        preference = userPref;
      } else if (labelDefinition != null) {
        // Map defaultSetting string to LabelPreference
        switch (labelDefinition.defaultSetting) {
          case 'hide':
            preference = LabelPreference.hide;
            break;
          case 'warn':
            preference = LabelPreference.warn;
            break;
          default:
            preference = LabelPreference.show;
        }
      } else {
        preference = LabelPreference.show;
      }

      // If any labeler says to hide, hide
      if (preference == LabelPreference.hide) {
        return true;
      }
    }
  }

  return false;
}

/// Provider for determining if content should show a warning
@riverpod
Future<bool> shouldWarnContent(Ref ref, List<String> contentLabels) async {
  if (contentLabels.isEmpty) return false;

  // First check for special '!warn' label which always warns for content
  if (contentLabels.contains('!warn')) {
    return true;
  }

  // If content should be hidden, we don't need to warn
  final shouldHide = await ref.watch(shouldHideContentProvider(contentLabels).future);
  if (shouldHide) return false;

  final labelerDids = await ref.watch(followedLabelersProvider.future);

  // For each label in the content
  for (final labelValue in contentLabels) {
    // Check in each followed labeler
    for (final labelerDid in labelerDids) {
      // Get the labeler details to check label definition
      final labeler = await ref.watch(labelerDetailsProvider(labelerDid).future);
      final labelDefinition = labeler.labelDefinitions[labelValue];

      // Get preference or use default based on label definition
      LabelPreference preference;
      final userPref = await ref.watch(labelPreferenceProvider(labelerDid, labelValue).future);

      if (userPref != null) {
        preference = userPref;
      } else if (labelDefinition != null) {
        // Map defaultSetting string to LabelPreference
        switch (labelDefinition.defaultSetting) {
          case 'hide':
            preference = LabelPreference.hide;
            break;
          case 'warn':
            preference = LabelPreference.warn;
            break;
          default:
            preference = LabelPreference.show;
        }
      } else {
        preference = LabelPreference.show;
      }

      // If any labeler says to warn, warn
      if (preference == LabelPreference.warn) {
        return true;
      }
    }
  }

  return false;
}

/// Provider for warning messages for content
@riverpod
Future<List<String>> warningMessages(Ref ref, List<String> contentLabels) async {
  final Set<String> warnings = {};

  // Check for special '!warn' label which has a dedicated warning message
  if (contentLabels.contains('!warn')) {
    warnings.add("This content has been flagged by the publisher as requiring a warning");
  }

  final labelerDids = await ref.watch(followedLabelersProvider.future);

  // For each label in the content
  for (final labelValue in contentLabels) {
    // Skip processing the special labels
    if (labelValue == '!warn' || labelValue == '!hide') continue;

    // Check in each followed labeler
    for (final labelerDid in labelerDids) {
      // Get preference
      final preference = await ref.watch(labelPreferenceProvider(labelerDid, labelValue).future);

      // Get the labeler details to check label definition
      final labeler = await ref.watch(labelerDetailsProvider(labelerDid).future);
      final labelDefinition = labeler.labelDefinitions[labelValue];

      // If no explicit preference, use default from label definition
      LabelPreference effectivePreference =
          preference ??
          (labelDefinition != null
              ? (labelDefinition.defaultSetting == 'warn'
                  ? LabelPreference.warn
                  : (labelDefinition.defaultSetting == 'hide' ? LabelPreference.hide : LabelPreference.show))
              : LabelPreference.show);

      // If the labeler says to warn about this label
      if (effectivePreference == LabelPreference.warn) {
        if (labelDefinition != null) {
          // Try to get display name from locales first
          final String displayName;
          if (labelDefinition.locales.isNotEmpty) {
            final enLocale = labelDefinition.locales.first;
            displayName = enLocale.name;
          } else {
            // Use label value as fallback
            displayName = labelValue;
          }

          warnings.add(displayName);
        } else {
          // If we don't have the definition, use the raw value
          warnings.add("This post contains content that was labeled as $labelValue");
        }
      }
    }
  }

  return warnings.toList();
}

/// Methods for managing labelers
@riverpod
class LabelerManager extends _$LabelerManager {
  @override
  Future<void> build() async {
    // Empty initial state
    return;
  }

  /// Follow a labeler
  Future<void> followLabeler(String labelerDid) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(labelerRepositoryProvider);
      await repository.addFollowedLabeler(labelerDid);

      // Refresh followed labelers list
      ref.invalidate(followedLabelersProvider);

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError('Failed to follow labeler: $e', stack);
      debugPrint('Error following labeler: $e');
    }
  }

  /// Unfollow a labeler
  Future<void> unfollowLabeler(String labelerDid) async {
    state = const AsyncLoading();

    try {
      // Don't allow unfollowing the default labeler
      if (labelerDid == ref.read(defaultLabelerDidProvider)) {
        state = const AsyncData(null);
        return;
      }

      final repository = ref.read(labelerRepositoryProvider);
      await repository.removeFollowedLabeler(labelerDid);

      // Refresh followed labelers list
      ref.invalidate(followedLabelersProvider);

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError('Failed to unfollow labeler: $e', stack);
      debugPrint('Error unfollowing labeler: $e');
    }
  }

  /// Set label preference
  Future<void> setLabelPreference(String labelerDid, String labelValue, LabelPreference preference) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(labelerRepositoryProvider);
      await repository.setLabelPreference(labelerDid, labelValue, preference.name);

      // Invalidate preference cache
      ref.invalidate(labelPreferenceProvider(labelerDid, labelValue));

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError('Failed to set label preference: $e', stack);
      debugPrint('Error setting label preference: $e');
    }
  }
}
