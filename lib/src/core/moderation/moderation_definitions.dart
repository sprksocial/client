import 'dart:collection';

import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/moderation/moderation_models.dart';

final class ModerationLabelDefinitions {
  factory ModerationLabelDefinitions({
    Iterable<ModerationLabelDefinition> definitions = const [],
    bool includeBuiltIns = true,
  }) {
    final items = definitions.toList(growable: false);
    return ModerationLabelDefinitions._(
      definitions: items,
      configuredLabelerDids: items
          .map((definition) => definition.definedBy)
          .nonNulls,
      includeBuiltIns: includeBuiltIns,
    );
  }

  ModerationLabelDefinitions._({
    required Iterable<ModerationLabelDefinition> definitions,
    required Iterable<String> configuredLabelerDids,
    required bool includeBuiltIns,
  }) {
    final all = <ModerationLabelDefinition>[
      if (includeBuiltIns) ...builtInLabelDefinitions,
      ...definitions,
    ];
    final global = {
      for (final definition in all.where((item) => item.definedBy == null))
        definition.identifier: definition,
    };
    // Imperative meanings are protocol behavior, not labeler policy. Keep
    // them authoritative even if a caller accidentally supplies a same-named
    // global definition.
    if (includeBuiltIns) {
      for (final definition in builtInLabelDefinitions.where(
        (item) => item.identifier.startsWith('!'),
      )) {
        global[definition.identifier] = definition;
      }
    }
    _global = UnmodifiableMapView(global);
    _bySource = UnmodifiableMapView({
      for (final source in all.map((item) => item.definedBy).nonNulls.toSet())
        source: UnmodifiableMapView({
          for (final definition in all.where(
            (item) => item.definedBy == source,
          ))
            definition.identifier: definition,
        }),
    });
    _configuredLabelerDids = Set.unmodifiable(configuredLabelerDids);
  }

  factory ModerationLabelDefinitions.fromLabelers(
    Map<String, Iterable<LabelValueDefinition>> definitionsByLabeler, {
    bool includeBuiltIns = true,
  }) {
    return ModerationLabelDefinitions._(
      includeBuiltIns: includeBuiltIns,
      configuredLabelerDids: definitionsByLabeler.keys,
      definitions: [
        for (final entry in definitionsByLabeler.entries)
          for (final definition in entry.value)
            interpretLabelValueDefinition(definition, definedBy: entry.key),
      ],
    );
  }

  late final Map<String, ModerationLabelDefinition> _global;
  late final Map<String, Map<String, ModerationLabelDefinition>> _bySource;
  late final Set<String> _configuredLabelerDids;

  Map<String, ModerationLabelDefinition> get global => _global;

  Map<String, Map<String, ModerationLabelDefinition>> get bySource => _bySource;

  bool isConfiguredSource(String did) => _configuredLabelerDids.contains(did);

  ModerationLabelDefinition? lookup(Label label) {
    if (label.val.startsWith('!')) return _global[label.val];
    return _bySource[label.src]?[label.val] ?? _global[label.val];
  }

  ModerationLabelDefinition? lookupSelfLabel(
    Label label, {
    required String? labelerDid,
  }) {
    if (label.val.startsWith('!')) return _global[label.val];

    // Only protocol-supported global values may be self-applied. For those
    // values, use the configured labeler's metadata when it is available.
    if (!globalAdultContentLabelValues.contains(label.val)) return null;
    final builtIn = _global[label.val];
    if (builtIn == null) return null;
    return _bySource[labelerDid]?[label.val] ?? builtIn;
  }
}

ModerationLabelDefinition interpretLabelValueDefinition(
  LabelValueDefinition definition, {
  required String definedBy,
}) {
  final severity = switch (definition.severity.toJson()) {
    'alert' => ModerationSeverity.alert,
    'inform' => ModerationSeverity.inform,
    _ => ModerationSeverity.none,
  };
  final blurs = switch (definition.blurs.toJson()) {
    'content' => ModerationBlur.content,
    'media' => ModerationBlur.media,
    _ => ModerationBlur.none,
  };
  final defaultSetting = switch (definition.defaultSetting?.toJson()) {
    'hide' => ModerationSetting.hide,
    'ignore' => ModerationSetting.ignore,
    _ => ModerationSetting.warn,
  };
  final flags = <ModerationLabelFlag>{ModerationLabelFlag.noSelf};
  if (definition.adultOnly ?? false) flags.add(ModerationLabelFlag.adult);

  return ModerationLabelDefinition(
    identifier: definition.identifier,
    definedBy: definedBy,
    severity: severity,
    blurs: blurs,
    defaultSetting: defaultSetting,
    configurable: true,
    flags: flags,
    locales: definition.locales.map(ModerationLabelStrings.fromLexicon),
    behaviors: _definitionBehaviors(
      severity: severity,
      blurs: blurs,
      adultOnly: definition.adultOnly ?? false,
    ),
  );
}

final List<ModerationLabelDefinition>
builtInLabelDefinitions = List.unmodifiable([
  _imperativeDefinition(
    identifier: '!hide',
    defaultSetting: ModerationSetting.hide,
    flags: const {ModerationLabelFlag.noOverride, ModerationLabelFlag.noSelf},
  ),
  _imperativeDefinition(
    identifier: '!takedown',
    defaultSetting: ModerationSetting.hide,
    flags: const {ModerationLabelFlag.noOverride, ModerationLabelFlag.noSelf},
  ),
  _imperativeDefinition(
    identifier: '!warn',
    defaultSetting: ModerationSetting.warn,
    flags: const {ModerationLabelFlag.noSelf},
  ),
  _imperativeDefinition(
    identifier: '!no-unauthenticated',
    defaultSetting: ModerationSetting.hide,
    flags: const {
      ModerationLabelFlag.noOverride,
      ModerationLabelFlag.unauthenticated,
    },
  ),
  ModerationLabelDefinition(
    identifier: '!no-promote',
    severity: ModerationSeverity.none,
    blurs: ModerationBlur.none,
    defaultSetting: ModerationSetting.hide,
    configurable: false,
    flags: const {ModerationLabelFlag.noPromote, ModerationLabelFlag.noSelf},
    locales: const [],
    behaviors: const {},
  ),
  _mediaDefinition(
    identifier: 'porn',
    defaultSetting: ModerationSetting.hide,
    adultOnly: true,
  ),
  _mediaDefinition(
    identifier: 'sexual',
    defaultSetting: ModerationSetting.warn,
    adultOnly: true,
  ),
  _mediaDefinition(
    identifier: 'nudity',
    defaultSetting: ModerationSetting.ignore,
  ),
  _mediaDefinition(
    identifier: 'graphic-media',
    defaultSetting: ModerationSetting.warn,
    adultOnly: true,
  ),
  _mediaDefinition(
    identifier: 'gore',
    defaultSetting: ModerationSetting.warn,
    adultOnly: true,
  ),
  _contentDefinition(
    identifier: 'nsfl',
    defaultSetting: ModerationSetting.warn,
    adultOnly: true,
  ),
  _contentDefinition(
    identifier: 'dmca-violation',
    defaultSetting: ModerationSetting.hide,
  ),
  _contentDefinition(
    identifier: 'doxxing',
    defaultSetting: ModerationSetting.warn,
  ),
]);

final Map<String, ModerationLabelDefinition> builtInLabelDefinitionsByValue =
    UnmodifiableMapView({
      for (final definition in builtInLabelDefinitions)
        definition.identifier: definition,
    });

ModerationLabelDefinition _imperativeDefinition({
  required String identifier,
  required ModerationSetting defaultSetting,
  required Set<ModerationLabelFlag> flags,
}) {
  final profileBlurred = ModerationBehavior({
    ModerationContext.profileList: ModerationAction.blur,
    ModerationContext.profileView: ModerationAction.blur,
    ModerationContext.avatar: ModerationAction.blur,
    ModerationContext.banner: ModerationAction.blur,
    ModerationContext.displayName: ModerationAction.blur,
  });
  final contentBlurred = ModerationBehavior({
    ModerationContext.contentList: ModerationAction.blur,
    ModerationContext.contentView: ModerationAction.blur,
    ModerationContext.contentMedia: ModerationAction.blur,
  });
  final accountBlurred = ModerationBehavior({
    ...profileBlurred.actions,
    ...contentBlurred.actions,
  });
  return ModerationLabelDefinition(
    identifier: identifier,
    severity: identifier == '!warn'
        ? ModerationSeverity.none
        : ModerationSeverity.alert,
    blurs: ModerationBlur.content,
    defaultSetting: defaultSetting,
    configurable: false,
    flags: flags,
    locales: const [],
    behaviors: {
      ModerationTarget.account: accountBlurred,
      ModerationTarget.profile: profileBlurred,
      ModerationTarget.content: contentBlurred,
    },
  );
}

ModerationLabelDefinition _mediaDefinition({
  required String identifier,
  required ModerationSetting defaultSetting,
  bool adultOnly = false,
}) {
  return ModerationLabelDefinition(
    identifier: identifier,
    severity: ModerationSeverity.none,
    blurs: ModerationBlur.media,
    defaultSetting: defaultSetting,
    configurable: true,
    flags: {if (adultOnly) ModerationLabelFlag.adult},
    locales: const [],
    behaviors: _definitionBehaviors(
      severity: ModerationSeverity.none,
      blurs: ModerationBlur.media,
      adultOnly: adultOnly,
    ),
  );
}

ModerationLabelDefinition _contentDefinition({
  required String identifier,
  required ModerationSetting defaultSetting,
  bool adultOnly = false,
}) {
  return ModerationLabelDefinition(
    identifier: identifier,
    severity: ModerationSeverity.alert,
    blurs: ModerationBlur.content,
    defaultSetting: defaultSetting,
    configurable: true,
    flags: {if (adultOnly) ModerationLabelFlag.adult},
    locales: const [],
    behaviors: _definitionBehaviors(
      severity: ModerationSeverity.alert,
      blurs: ModerationBlur.content,
      adultOnly: adultOnly,
    ),
  );
}

Map<ModerationTarget, ModerationBehavior> _definitionBehaviors({
  required ModerationSeverity severity,
  required ModerationBlur blurs,
  required bool adultOnly,
}) {
  final notice = switch (severity) {
    ModerationSeverity.alert => ModerationAction.alert,
    ModerationSeverity.inform => ModerationAction.inform,
    ModerationSeverity.none => null,
  };
  final account = <ModerationContext, ModerationAction>{};
  final profile = <ModerationContext, ModerationAction>{};
  final content = <ModerationContext, ModerationAction>{};

  switch (blurs) {
    case ModerationBlur.content:
      if (notice != null) {
        account[ModerationContext.profileList] = notice;
        account[ModerationContext.profileView] = notice;
        profile[ModerationContext.profileList] = notice;
        profile[ModerationContext.profileView] = notice;
      }
      account[ModerationContext.contentList] = ModerationAction.blur;
      content[ModerationContext.contentList] = ModerationAction.blur;
      if (adultOnly) {
        account[ModerationContext.contentView] = ModerationAction.blur;
        content[ModerationContext.contentView] = ModerationAction.blur;
      } else if (notice != null) {
        account[ModerationContext.contentView] = notice;
        content[ModerationContext.contentView] = notice;
      }
    case ModerationBlur.media:
      if (notice != null) {
        account[ModerationContext.profileList] = notice;
        account[ModerationContext.profileView] = notice;
        profile[ModerationContext.profileList] = notice;
        profile[ModerationContext.profileView] = notice;
      }
      account[ModerationContext.avatar] = ModerationAction.blur;
      account[ModerationContext.banner] = ModerationAction.blur;
      profile[ModerationContext.avatar] = ModerationAction.blur;
      profile[ModerationContext.banner] = ModerationAction.blur;
      content[ModerationContext.contentMedia] = ModerationAction.blur;
      account[ModerationContext.contentView] = ModerationAction.blur;
      content[ModerationContext.contentView] = ModerationAction.blur;
    case ModerationBlur.none:
      if (notice != null) {
        account[ModerationContext.profileList] = notice;
        account[ModerationContext.profileView] = notice;
        account[ModerationContext.contentList] = notice;
        account[ModerationContext.contentView] = notice;
        profile[ModerationContext.profileList] = notice;
        profile[ModerationContext.profileView] = notice;
        content[ModerationContext.contentList] = notice;
        content[ModerationContext.contentView] = notice;
      }
  }

  return {
    ModerationTarget.account: ModerationBehavior(account),
    ModerationTarget.profile: ModerationBehavior(profile),
    ModerationTarget.content: ModerationBehavior(content),
  };
}
