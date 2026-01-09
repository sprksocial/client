import 'package:atproto/com_atproto_label_defs.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/pref_repository.dart';

class LabelUtils {
  static Future<LabelPreference> _getLabelPreference(String value) async {
    final prefRepository = GetIt.instance<PrefRepository>();
    final preferences = await prefRepository.getPreferences();
    final contentLabelPrefs = preferences.contentLabelPrefs ?? [];
    final contentLabelPref = contentLabelPrefs.firstWhere(
      (pref) => pref.label == value,
      orElse: () => throw Exception('Label preference not found'),
    );
    return LabelPreference(
      value: contentLabelPref.label,
      blurs: _visibilityToBlurs(contentLabelPref.visibility),
      severity: _visibilityToSeverity(contentLabelPref.visibility),
      defaultSetting: _visibilityToSetting(contentLabelPref.visibility),
      setting: _visibilityToSetting(contentLabelPref.visibility),
      adultOnly: _isAdultOnlyLabel(value),
    );
  }

  static Setting _visibilityToSetting(String visibility) {
    switch (visibility) {
      case 'ignore':
        return Setting.ignore;
      case 'warn':
        return Setting.warn;
      case 'hide':
        return Setting.hide;
      default:
        return Setting.ignore;
    }
  }

  static Blurs _visibilityToBlurs(String visibility) {
    switch (visibility) {
      case 'ignore':
        return Blurs.none;
      case 'warn':
        return Blurs.media;
      case 'hide':
        return Blurs.content;
      default:
        return Blurs.none;
    }
  }

  static Severity _visibilityToSeverity(String visibility) {
    switch (visibility) {
      case 'ignore':
        return Severity.none;
      case 'warn':
        return Severity.alert;
      case 'hide':
        return Severity.alert;
      default:
        return Severity.none;
    }
  }

  static bool _isAdultOnlyLabel(String label) {
    const adultOnlyLabels = {
      'porn',
      'sexual',
      'nsfl',
    };
    return adultOnlyLabels.contains(label);
  }

  static Future<bool> shouldShowWarning(List<Label> labels) async {
    if (labels.isEmpty) return false;

    for (final label in labels) {
      try {
        final preference = await _getLabelPreference(label.val);
        if (preference.severity == Severity.alert &&
            preference.setting == Setting.warn) {
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

    for (final label in labels) {
      try {
        final preference = await _getLabelPreference(label.val);
        if (preference.blurs == Blurs.content ||
            preference.blurs == Blurs.media &&
                preference.setting == Setting.warn) {
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

    final warningLabels = <String>[];

    for (final label in labels) {
      try {
        final preference = await _getLabelPreference(label.val);
        if (preference.severity == Severity.alert &&
            preference.setting == Setting.warn) {
          warningLabels.add(label.val);
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

    final informLabels = <String>[];

    for (final label in labels) {
      try {
        final preference = await _getLabelPreference(label.val);
        if (preference.severity == Severity.inform &&
            preference.setting == Setting.warn) {
          informLabels.add(label.val);
        }
      } catch (e) {
        // If no preference found, continue checking other labels
        continue;
      }
    }

    return informLabels;
  }

  static Future<bool> shouldHideContent(List<Label> labels) async {
    if (labels.isEmpty) return false;

    for (final label in labels) {
      try {
        final preference = await _getLabelPreference(label.val);
        if (preference.setting == Setting.hide || preference.adultOnly) {
          return true;
        }
      } catch (e) {
        // If no preference found, continue checking other labels
        continue;
      }
    }

    return false;
  }
}
