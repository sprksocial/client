import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/moderation/moderation_definitions.dart';
import 'package:spark/src/core/moderation/moderation_label_events.dart';
import 'package:spark/src/core/moderation/moderation_models.dart';

final class ModerationEngine {
  ModerationEngine({
    required this.definitions,
    required this.preferences,
    this.currentUserDid,
    this.selfLabelerDid,
    Map<String, String> labelerHandles = const {},
  }) : _labelerHandles = Map.unmodifiable(labelerHandles);

  final ModerationLabelDefinitions definitions;
  final ModerationPreferences preferences;
  final String? currentUserDid;
  final String? selfLabelerDid;
  final Map<String, String> _labelerHandles;

  ModerationDecision evaluate(
    Iterable<Label> labels, {
    required ModerationTarget target,
    String? subjectDid,
    Iterable<String> preferredLocales = const [],
    DateTime? now,
  }) {
    final evaluationTime = (now ?? DateTime.now()).toUtc();
    final causes = <ModerationCause>[];

    for (final label in labels) {
      if (!isLabelActiveAt(label, now: evaluationTime)) continue;

      final isSelfLabel = subjectDid != null && label.src == subjectDid;
      final definition = isSelfLabel
          ? definitions.lookupSelfLabel(label, labelerDid: selfLabelerDid)
          : definitions.lookup(label);
      if (definition == null) continue;

      if (isSelfLabel &&
          definition.definedBy == null &&
          definition.flags.contains(ModerationLabelFlag.noSelf)) {
        continue;
      }
      if (definition.flags.contains(ModerationLabelFlag.unauthenticated) &&
          preferences.authenticated) {
        continue;
      }

      final setting = preferences.settingFor(
        label,
        definition,
        labelerDid: isSelfLabel ? selfLabelerDid : null,
      );
      if (setting == ModerationSetting.ignore) continue;

      final adultRestricted =
          definition.adultOnly && !preferences.adultContentEnabled;
      final noOverride = definition.noOverride || adultRestricted;
      final behavior = definition.behaviorFor(target);
      causes.add(
        ModerationCause(
          label: label,
          definition: definition,
          target: target,
          setting: setting,
          behavior: behavior,
          noOverride: noOverride,
          priority: _priorityFor(
            setting: setting,
            behavior: behavior,
            noOverride: noOverride,
          ),
          strings: definition.stringsFor(preferredLocales),
          sourceHandle: _labelerHandles[label.src],
        ),
      );
    }

    causes.sort((a, b) => a.priority.compareTo(b.priority));
    return ModerationDecision(
      causes: causes,
      isSubjectCurrentUser: subjectDid != null && subjectDid == currentUserDid,
    );
  }

  /// Evaluates the mixed account and profile-record labels returned on profile
  /// views using their protocol-defined targets.
  ModerationDecision evaluateProfileLabels(
    Iterable<Label> labels, {
    String? subjectDid,
    Iterable<String> preferredLocales = const [],
    DateTime? now,
  }) {
    final items = labels.toList(growable: false);
    return ModerationDecision.merge([
      evaluate(
        items.where(_isAccountLabel),
        target: ModerationTarget.account,
        subjectDid: subjectDid,
        preferredLocales: preferredLocales,
        now: now,
      ),
      evaluate(
        items.where(_isProfileRecordLabel),
        target: ModerationTarget.profile,
        subjectDid: subjectDid,
        preferredLocales: preferredLocales,
        now: now,
      ),
    ]);
  }
}

bool _isProfileRecordLabel(Label label) {
  return label.uri.endsWith('/app.bsky.actor.profile/self');
}

bool _isAccountLabel(Label label) {
  return !_isProfileRecordLabel(label) || label.val == '!no-unauthenticated';
}

final class ModerationDecision {
  ModerationDecision({
    required Iterable<ModerationCause> causes,
    required this.isSubjectCurrentUser,
  }) : causes = List.unmodifiable(causes);

  /// Combines decisions for different targets belonging to the same subject.
  ///
  /// For example, a post surface can merge its author's account decision with
  /// the post's content decision before asking for [ModerationContext.contentView].
  factory ModerationDecision.merge(Iterable<ModerationDecision> decisions) {
    final items = decisions.toList();
    final causes = items.expand((decision) => decision.causes).toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
    return ModerationDecision(
      causes: causes,
      isSubjectCurrentUser: items.any(
        (decision) => decision.isSubjectCurrentUser,
      ),
    );
  }

  final List<ModerationCause> causes;
  final bool isSubjectCurrentUser;

  bool get excludeFromPromotion => causes.any(
    (cause) => cause.definition.flags.contains(ModerationLabelFlag.noPromote),
  );

  bool get hideFromUnauthenticated => causes.any(
    (cause) =>
        cause.definition.flags.contains(ModerationLabelFlag.unauthenticated),
  );

  ModerationUI forContext(ModerationContext context) {
    final filters = <ModerationCause>[];
    final blurs = <ModerationCause>[];
    final alerts = <ModerationCause>[];
    final informs = <ModerationCause>[];

    for (final cause in causes) {
      final noPromote = cause.definition.flags.contains(
        ModerationLabelFlag.noPromote,
      );
      if (!noPromote &&
          cause.setting == ModerationSetting.hide &&
          !isSubjectCurrentUser &&
          _filtersContext(cause.target, context)) {
        filters.add(cause);
      }

      switch (cause.behavior[context]) {
        case ModerationAction.blur:
          blurs.add(cause);
        case ModerationAction.alert:
          alerts.add(cause);
        case ModerationAction.inform:
          informs.add(cause);
        case null:
          break;
      }

      // Spark is media-first: ordinary warning labels at the warn preference
      // add a blur even when their definition does not request one. Informational
      // labels remain badge-only unless their definition explicitly adds a blur.
      // Protocol imperatives such as !no-promote retain their special meaning.
      if (!noPromote &&
          cause.setting == ModerationSetting.warn &&
          cause.definition.severity != ModerationSeverity.inform &&
          _warnBlurApplies(cause.target, context) &&
          !blurs.contains(cause)) {
        blurs.add(cause);
      }
    }

    return ModerationUI(
      filters: filters,
      blurs: blurs,
      alerts: alerts,
      informs: informs,
      noOverride:
          !isSubjectCurrentUser && blurs.any((cause) => cause.noOverride),
    );
  }
}

bool _filtersContext(ModerationTarget target, ModerationContext context) {
  return switch (context) {
    ModerationContext.profileList => target == ModerationTarget.account,
    ModerationContext.contentList =>
      target == ModerationTarget.account || target == ModerationTarget.content,
    _ => false,
  };
}

bool _warnBlurApplies(ModerationTarget target, ModerationContext context) {
  return switch (target) {
    ModerationTarget.account => true,
    ModerationTarget.profile =>
      context == ModerationContext.profileList ||
          context == ModerationContext.profileView ||
          context == ModerationContext.avatar ||
          context == ModerationContext.banner ||
          context == ModerationContext.displayName,
    ModerationTarget.content =>
      context == ModerationContext.contentList ||
          context == ModerationContext.contentView ||
          context == ModerationContext.contentMedia,
  };
}

int _priorityFor({
  required ModerationSetting setting,
  required ModerationBehavior behavior,
  required bool noOverride,
}) {
  if (noOverride) return 1;
  if (setting == ModerationSetting.hide) return 2;
  if (behavior[ModerationContext.profileView] == ModerationAction.blur ||
      behavior[ModerationContext.contentView] == ModerationAction.blur) {
    return 5;
  }
  if (behavior[ModerationContext.contentList] == ModerationAction.blur ||
      behavior[ModerationContext.contentMedia] == ModerationAction.blur) {
    return 7;
  }
  return 8;
}
