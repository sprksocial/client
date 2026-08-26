import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:spark/src/core/moderation/moderation_engine.dart';
import 'package:spark/src/core/moderation/moderation_models.dart';

enum _ModerationSubjectKind { content, profile }

/// A typed moderation input that owns how protocol labels are evaluated.
final class ModerationSubject {
  ModerationSubject._(
    this._kind, {
    required this.subjectDid,
    required Iterable<Label> labels,
    required Iterable<Label> authorLabels,
  }) : labels = List.unmodifiable(labels),
       authorLabels = List.unmodifiable(authorLabels);

  factory ModerationSubject.content({
    required String? subjectDid,
    required Iterable<Label> labels,
    Iterable<Label> authorLabels = const [],
  }) {
    return ModerationSubject._(
      _ModerationSubjectKind.content,
      subjectDid: subjectDid,
      labels: labels,
      authorLabels: authorLabels,
    );
  }

  factory ModerationSubject.profile({
    required String? subjectDid,
    required Iterable<Label> labels,
  }) {
    return ModerationSubject._(
      _ModerationSubjectKind.profile,
      subjectDid: subjectDid,
      labels: labels,
      authorLabels: const [],
    );
  }

  final _ModerationSubjectKind _kind;
  final String? subjectDid;
  final List<Label> labels;
  final List<Label> authorLabels;

  bool get hasLabels => labels.isNotEmpty || authorLabels.isNotEmpty;

  ModerationDecision evaluate(
    ModerationEngine engine, {
    Iterable<String> preferredLocales = const [],
  }) {
    return switch (_kind) {
      _ModerationSubjectKind.profile => engine.evaluateProfileLabels(
        labels,
        subjectDid: subjectDid,
        preferredLocales: preferredLocales,
      ),
      _ModerationSubjectKind.content => ModerationDecision.merge([
        engine.evaluate(
          labels,
          target: ModerationTarget.content,
          subjectDid: subjectDid,
          preferredLocales: preferredLocales,
        ),
        if (authorLabels.isNotEmpty)
          engine.evaluateProfileLabels(
            authorLabels,
            subjectDid: subjectDid,
            preferredLocales: preferredLocales,
          ),
      ]),
    };
  }

  String disclosureKey(ModerationContext context) {
    return <String?>[
      subjectDid,
      _kind.name,
      context.name,
      ...labels.map(_labelSignature),
      ...authorLabels.map(_labelSignature),
    ].join('|');
  }
}

String _labelSignature(Label label) {
  return '${label.src}|${label.uri}|${label.cid}|${label.val}|${label.neg}|'
      '${label.cts.toUtc().toIso8601String()}|${label.exp}';
}
