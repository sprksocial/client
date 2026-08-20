import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';

final class LabelerPreferenceSnapshot {
  const LabelerPreferenceSnapshot({
    required this.preferences,
    required this.definitions,
  });

  final Map<String, LabelPreference> preferences;
  final Map<String, ModerationLabelDefinition> definitions;
}

LabelPreference labelPreferenceFromPolicy({
  required String value,
  required Setting? savedSetting,
  required Setting? globalSetting,
  required ModerationLabelDefinition? definition,
}) {
  final defaultSetting = definition == null
      ? Setting.warn
      : Setting.fromValue(definition.defaultSetting.name);
  return LabelPreference(
    value: value,
    blurs: definition == null
        ? Blurs.media
        : Blurs.fromValue(definition.blurs.name),
    severity: definition == null
        ? Severity.alert
        : Severity.fromValue(definition.severity.name),
    defaultSetting: defaultSetting,
    setting: globalAdultContentLabelValues.contains(value)
        ? globalSetting ?? savedSetting ?? defaultSetting
        : savedSetting ?? defaultSetting,
    adultOnly: definition?.adultOnly ?? false,
  );
}
