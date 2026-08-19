import 'dart:collection';

import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:sprk_poptart/so/sprk/actor/defs/content_label_pref.dart';

enum ModerationTarget { account, profile, content }

enum ModerationContext {
  contentList,
  contentView,
  contentMedia,
  profileList,
  profileView,
  avatar,
  banner,
  displayName,
}

enum ModerationAction { blur, alert, inform }

enum ModerationSetting { ignore, warn, hide }

enum ModerationSeverity { none, inform, alert }

enum ModerationBlur { none, media, content }

/// Canonical labels configured globally from the adult-content settings.
const globalAdultContentLabelValues = <String>{
  'porn',
  'sexual',
  'graphic-media',
  'nudity',
};

enum ModerationLabelFlag {
  noOverride,
  adult,
  unauthenticated,
  noSelf,
  noPromote,
}

final class ModerationLabelStrings {
  const ModerationLabelStrings({
    required this.lang,
    required this.name,
    required this.description,
  });

  final String lang;
  final String name;
  final String description;

  factory ModerationLabelStrings.fromLexicon(
    LabelValueDefinitionStrings strings,
  ) {
    return ModerationLabelStrings(
      lang: strings.lang,
      name: strings.name,
      description: strings.description,
    );
  }
}

final class ModerationBehavior {
  ModerationBehavior([
    Map<ModerationContext, ModerationAction> actions = const {},
  ]) : _actions = UnmodifiableMapView(Map.of(actions));

  final Map<ModerationContext, ModerationAction> _actions;

  Map<ModerationContext, ModerationAction> get actions => _actions;

  ModerationAction? operator [](ModerationContext context) => _actions[context];

  bool get isEmpty => _actions.isEmpty;
}

final class ModerationLabelDefinition {
  ModerationLabelDefinition({
    required this.identifier,
    required this.severity,
    required this.blurs,
    required this.defaultSetting,
    required this.configurable,
    required Iterable<ModerationLabelFlag> flags,
    required Iterable<ModerationLabelStrings> locales,
    required Map<ModerationTarget, ModerationBehavior> behaviors,
    this.definedBy,
  }) : flags = Set.unmodifiable(flags),
       locales = List.unmodifiable(locales),
       behaviors = UnmodifiableMapView(Map.of(behaviors));

  final String identifier;
  final String? definedBy;
  final ModerationSeverity severity;
  final ModerationBlur blurs;
  final ModerationSetting defaultSetting;
  final bool configurable;
  final Set<ModerationLabelFlag> flags;
  final List<ModerationLabelStrings> locales;
  final Map<ModerationTarget, ModerationBehavior> behaviors;

  bool get adultOnly => flags.contains(ModerationLabelFlag.adult);

  bool get noOverride => flags.contains(ModerationLabelFlag.noOverride);

  ModerationBehavior behaviorFor(ModerationTarget target) {
    return behaviors[target] ?? ModerationBehavior();
  }

  /// Selects definition-published strings using BCP 47 lookup-style fallback.
  ModerationLabelStrings? stringsFor(Iterable<String> preferredLocales) {
    if (locales.isEmpty) return null;

    final normalized = <String, ModerationLabelStrings>{};
    for (final strings in locales) {
      normalized.putIfAbsent(_normalizeLocale(strings.lang), () => strings);
    }

    for (final preferred in preferredLocales) {
      var candidate = _normalizeLocale(preferred);
      while (candidate.isNotEmpty) {
        final exact = normalized[candidate];
        if (exact != null) return exact;
        final separator = candidate.lastIndexOf('-');
        if (separator == -1) break;
        candidate = candidate.substring(0, separator);
      }

      final language = candidate;
      if (language.isNotEmpty) {
        for (final entry in normalized.entries) {
          if (entry.key.split('-').first == language) return entry.value;
        }
      }
    }

    return normalized['en'] ??
        normalized.entries
            .where((entry) => entry.key.split('-').first == 'en')
            .map((entry) => entry.value)
            .firstOrNull ??
        locales.first;
  }

  static String _normalizeLocale(String locale) {
    return locale.trim().replaceAll('_', '-').toLowerCase();
  }
}

final class ModerationLabelPreference {
  const ModerationLabelPreference({
    required this.value,
    required this.setting,
    this.labelerDid,
  });

  final String value;
  final String? labelerDid;
  final ModerationSetting setting;
}

final class ModerationPreferences {
  ModerationPreferences({
    required Iterable<ModerationLabelPreference> labels,
    required this.adultContentEnabled,
    required this.authenticated,
  }) : labels = List.unmodifiable(labels);

  factory ModerationPreferences.fromContentLabelPrefs(
    Iterable<ContentLabelPref> labels, {
    required bool adultContentEnabled,
    required bool authenticated,
  }) {
    return ModerationPreferences(
      labels: labels.map(
        (preference) => ModerationLabelPreference(
          value: preference.label,
          labelerDid: preference.labelerDid,
          setting: switch (preference.visibility.toJson()) {
            'hide' => ModerationSetting.hide,
            'warn' => ModerationSetting.warn,
            _ => ModerationSetting.ignore,
          },
        ),
      ),
      adultContentEnabled: adultContentEnabled,
      authenticated: authenticated,
    );
  }

  final List<ModerationLabelPreference> labels;
  final bool adultContentEnabled;
  final bool authenticated;

  ModerationSetting settingFor(
    Label label,
    ModerationLabelDefinition definition, {
    String? labelerDid,
  }) {
    if (!definition.configurable) return definition.defaultSetting;
    if (definition.adultOnly && !adultContentEnabled) {
      return ModerationSetting.hide;
    }

    ModerationLabelPreference? global;
    ModerationLabelPreference? sourceSpecific;
    for (final preference in labels) {
      if (preference.value != label.val) continue;
      if (preference.labelerDid == (labelerDid ?? label.src)) {
        sourceSpecific = preference;
      }
      if (preference.labelerDid == null) global ??= preference;
    }
    if (globalAdultContentLabelValues.contains(label.val) && global != null) {
      return global.setting;
    }
    return sourceSpecific?.setting ??
        global?.setting ??
        definition.defaultSetting;
  }
}

final class ModerationCause {
  const ModerationCause({
    required this.label,
    required this.definition,
    required this.target,
    required this.setting,
    required this.behavior,
    required this.noOverride,
    required this.priority,
    this.strings,
    this.sourceHandle,
  });

  final Label label;
  final ModerationLabelDefinition definition;
  final ModerationTarget target;
  final ModerationSetting setting;
  final ModerationBehavior behavior;
  final bool noOverride;
  final int priority;
  final ModerationLabelStrings? strings;
  final String? sourceHandle;

  String get sourceDid => label.src;
}

final class ModerationUI {
  ModerationUI({
    required Iterable<ModerationCause> filters,
    required Iterable<ModerationCause> blurs,
    required Iterable<ModerationCause> alerts,
    required Iterable<ModerationCause> informs,
    required this.noOverride,
  }) : filters = List.unmodifiable(filters),
       blurs = List.unmodifiable(blurs),
       alerts = List.unmodifiable(alerts),
       informs = List.unmodifiable(informs);

  final List<ModerationCause> filters;
  final List<ModerationCause> blurs;
  final List<ModerationCause> alerts;
  final List<ModerationCause> informs;
  final bool noOverride;

  bool get filter => filters.isNotEmpty;
  bool get blur => blurs.isNotEmpty;
  bool get alert => alerts.isNotEmpty;
  bool get inform => informs.isNotEmpty;
}
