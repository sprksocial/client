import 'package:poptart_lex/com/atproto/label/defs.dart';

/// Merges label event streams to the latest event for each label identity.
List<Label> mergeLatestLabelEvents({
  required Iterable<Label> existing,
  required Iterable<Label> incoming,
  required DateTime now,
}) {
  final evaluationTime = now.toUtc();
  final latestByIdentity = <({String src, String uri, String val}), Label>{};
  for (final event in existing.followedBy(incoming)) {
    final identity = (src: event.src, uri: event.uri, val: event.val);
    final current = latestByIdentity[identity];
    if (current == null ||
        _labelShouldReplace(event, current, evaluationTime)) {
      latestByIdentity[identity] = event;
    }
  }
  return latestByIdentity.values.toList(growable: false);
}

/// Selects asserted, unexpired labels from a reconciled event snapshot.
List<Label> activeLabelsFromEvents(
  Iterable<Label> events, {
  required DateTime now,
}) {
  final evaluationTime = now.toUtc();
  return events
      .where((label) => isLabelActiveAt(label, now: evaluationTime))
      .toList(growable: false);
}

/// Whether a label assertion applies at [now].
bool isLabelActiveAt(Label label, {required DateTime now}) {
  final evaluationTime = now.toUtc();
  return !label.isNeg && (label.exp?.toUtc().isAfter(evaluationTime) ?? true);
}

bool _labelShouldReplace(Label candidate, Label existing, DateTime now) {
  final comparison = candidate.cts.toUtc().compareTo(existing.cts.toUtc());
  if (comparison != 0) return comparison > 0;

  final candidateInactive = !isLabelActiveAt(candidate, now: now);
  final existingInactive = !isLabelActiveAt(existing, now: now);
  return candidateInactive || !existingInactive;
}
