import 'package:atproto/atproto.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:sparksocial/src/core/storage/preferences/settings_repository.dart';

class LabelUtils {
  static Future<bool> shouldShowWarning(List<Label> labels) async {
    if (labels.isEmpty) return false;
    
    final settingsRepository = GetIt.instance<SettingsRepository>();
    
    for (final label in labels) {
      try {
        final preference = await settingsRepository.getLabelPreference(label.value);
        if (preference.severity == Severity.alert && preference.setting == Setting.warn) {
          return true;
        }
      } catch (e) {
        // If no preference found, continue checking other labels
        continue;
      }
    }
    
    return false;
  }

  static Future<bool> shouldBlurContent(List<Label> labels) async {
    if (labels.isEmpty) return false;
    
    final settingsRepository = GetIt.instance<SettingsRepository>();
    
    for (final label in labels) {
      try {
        final preference = await settingsRepository.getLabelPreference(label.value);
        if (preference.blurs == Blurs.content || preference.blurs == Blurs.media && preference.setting == Setting.warn) {
          return true;
        }
      } catch (e) {
        // If no preference found, continue checking other labels
        continue;
      }
    }

    return false;
  }
  
  static Future<List<String>> getWarningLabels(List<Label> labels) async {
    if (labels.isEmpty) return [];
    
    final settingsRepository = GetIt.instance<SettingsRepository>();
    final warningLabels = <String>[];
    
    for (final label in labels) {
      try {
        final preference = await settingsRepository.getLabelPreference(label.value);
        if (preference.severity == Severity.alert && preference.setting == Setting.warn) {
          warningLabels.add(label.value);
        }
      } catch (e) {
        // If no preference found, continue checking other labels
        continue;
      }
    }
    
    return warningLabels;
  }

  static Future<List<String>> getInformLabels(List<Label> labels) async {
    if (labels.isEmpty) return [];
    
    final settingsRepository = GetIt.instance<SettingsRepository>();
    final informLabels = <String>[];
    
    for (final label in labels) {
      try {
        final preference = await settingsRepository.getLabelPreference(label.value);
        if (preference.severity == Severity.inform && preference.setting == Setting.warn) {
          informLabels.add(label.value);
        }
      } catch (e) {
        // If no preference found, continue checking other labels
        continue;
      }
    }
    
    return informLabels;
  }
} 