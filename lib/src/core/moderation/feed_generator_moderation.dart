import 'package:spark/src/core/moderation/moderation_subject.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';

ModerationSubject feedGeneratorModerationSubject(GeneratorView generator) {
  return ModerationSubject.content(
    labels: generator.labels ?? const [],
    authorLabels: generator.creator.labels ?? const [],
    subjectDid: generator.creator.did,
  );
}
