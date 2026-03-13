import 'package:atproto/com_atproto_label_defs.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';

/// Utility class for working with labels.
///
/// All methods that need preferences now take them as a parameter instead of
/// fetching them. This ensures preferences are loaded once and passed down
/// from the [UserPreferencesProvider].
class LabelUtils {
  /// Gets a label preference from the given preferences.
  /// Returns null if not found instead of throwing.
  static LabelPreference? getLabelPreferenceFromPrefs(
    Preferences preferences,
    String value,
  ) {
    final contentLabelPrefs = preferences.contentLabelPrefs ?? [];
    try {
      final contentLabelPref = contentLabelPrefs.firstWhere(
        (pref) => pref.label == value,
      );
      return LabelPreference(
        value: contentLabelPref.label,
        blurs: _visibilityToBlurs(contentLabelPref.visibility),
        severity: _visibilityToSeverity(contentLabelPref.visibility),
        defaultSetting: _visibilityToSetting(contentLabelPref.visibility),
        setting: _visibilityToSetting(contentLabelPref.visibility),
        adultOnly: _isAdultOnlyLabel(value),
      );
    } catch (e) {
      return null;
    }
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
    const adultOnlyLabels = {'porn', 'sexual', 'nsfl'};
    return adultOnlyLabels.contains(label);
  }

  /// Checks if any label should show a warning.
  /// Takes preferences as a parameter instead of fetching.
  static bool shouldShowWarning(Preferences preferences, List<Label> labels) {
    if (labels.isEmpty) return false;

    for (final label in labels) {
      final preference = getLabelPreferenceFromPrefs(preferences, label.val);
      if (preference != null &&
          preference.severity == Severity.alert &&
          preference.setting == Setting.warn) {
        return true;
      }
    }

    return false;
  }

  /// Checks if content should be blurred.
  /// Takes preferences as a parameter instead of fetching.
  static bool shouldBlurContent(Preferences preferences, List<Label> labels) {
    if (labels.isEmpty) return false;

    for (final label in labels) {
      final preference = getLabelPreferenceFromPrefs(preferences, label.val);
      if (preference != null &&
          (preference.blurs == Blurs.content ||
              (preference.blurs == Blurs.media &&
                  preference.setting == Setting.warn))) {
        return true;
      }
    }

    return false;
  }

  /// Gets labels that should show warnings.
  /// Takes preferences as a parameter instead of fetching.
  static List<String> getWarningLabels(
    Preferences preferences,
    List<Label> labels,
  ) {
    if (labels.isEmpty) return [];

    final warningLabels = <String>[];

    for (final label in labels) {
      final preference = getLabelPreferenceFromPrefs(preferences, label.val);
      if (preference != null &&
          preference.severity == Severity.alert &&
          preference.setting == Setting.warn) {
        warningLabels.add(label.val);
      }
    }

    return warningLabels;
  }

  /// Gets labels that should show info.
  /// Takes preferences as a parameter instead of fetching.
  static List<String> getInformLabels(
    Preferences preferences,
    List<Label> labels,
  ) {
    if (labels.isEmpty) return [];

    final informLabels = <String>[];

    for (final label in labels) {
      final preference = getLabelPreferenceFromPrefs(preferences, label.val);
      if (preference != null &&
          preference.severity == Severity.inform &&
          preference.setting == Setting.warn) {
        informLabels.add(label.val);
      }
    }

    return informLabels;
  }

  /// Checks if content should be hidden.
  /// Takes preferences as a parameter instead of fetching.
  static bool shouldHideContent(Preferences preferences, List<Label> labels) {
    if (labels.isEmpty) return false;

    for (final label in labels) {
      final preference = getLabelPreferenceFromPrefs(preferences, label.val);
      if (preference != null &&
          (preference.setting == Setting.hide || preference.adultOnly)) {
        return true;
      }
    }

    return false;
  }
}
