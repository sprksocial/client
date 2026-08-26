import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation_models.dart';

extension ModerationLabelLocalizations on AppLocalizations {
  ModerationLabelStrings? globalModerationLabelStrings(String identifier) {
    final (name, description) = switch (identifier) {
      'porn' => (moderationLabelPornName, moderationLabelPornDescription),
      'sexual' => (moderationLabelSexualName, moderationLabelSexualDescription),
      'nudity' => (moderationLabelNudityName, moderationLabelNudityDescription),
      'graphic-media' => (
        moderationLabelGraphicMediaName,
        moderationLabelGraphicMediaDescription,
      ),
      'gore' => (moderationLabelGoreName, moderationLabelGoreDescription),
      _ => (null, null),
    };
    if (name == null || description == null) return null;

    return ModerationLabelStrings(
      lang: localeName,
      name: name,
      description: description,
    );
  }
}

extension LocalizedModerationLabelDefinition on ModerationLabelDefinition {
  ModerationLabelStrings? localizedStrings(
    AppLocalizations localizations, {
    Iterable<String> preferredLocales = const [],
  }) {
    final publishedStrings = stringsFor(preferredLocales);
    if (definedBy != null && publishedStrings != null) return publishedStrings;
    return localizations.globalModerationLabelStrings(identifier) ??
        publishedStrings;
  }
}

extension LocalizedModerationCause on ModerationCause {
  ModerationLabelStrings? localizedStrings(AppLocalizations localizations) {
    if (definition.definedBy != null && strings != null) return strings;
    return localizations.globalModerationLabelStrings(definition.identifier) ??
        strings;
  }
}
