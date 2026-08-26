import 'package:spark/src/core/moderation/moderation.dart';

final class LabelerPreferenceSnapshot {
  const LabelerPreferenceSnapshot({
    required this.settings,
    required this.definitions,
  });

  final Map<String, ModerationSetting> settings;
  final Map<String, ModerationLabelDefinition> definitions;
}

ModerationSetting moderationSettingFromPolicy({
  required ModerationSetting? savedSetting,
  required ModerationSetting? globalSetting,
  required ModerationLabelDefinition? definition,
}) {
  return globalSetting ??
      savedSetting ??
      definition?.defaultSetting ??
      ModerationSetting.warn;
}
