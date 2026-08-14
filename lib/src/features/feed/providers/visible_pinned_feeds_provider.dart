import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/moderation/moderation_provider.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

final visiblePinnedFeedsProvider = Provider<List<Feed>>((ref) {
  final settings = ref.watch(settingsProvider);
  final engine = ref.watch(moderationEngineProvider).asData?.value;

  return settings.feeds
      .where((feed) {
        if (!feed.config.pinned) return false;

        final generator = feed.view;
        if (generator == null) return true;

        final hasLabels =
            (generator.labels?.isNotEmpty ?? false) ||
            (generator.creator.labels?.isNotEmpty ?? false);
        if (!hasLabels) return true;
        if (engine == null) return false;

        return !feedGeneratorModerationDecision(
          engine,
          generator,
        ).forContext(ModerationContext.contentList).filter;
      })
      .toList(growable: false);
});

ModerationDecision feedGeneratorModerationDecision(
  ModerationEngine engine,
  GeneratorView generator, {
  Iterable<String> preferredLocales = const [],
}) {
  return ModerationDecision.merge([
    engine.evaluate(
      generator.labels ?? const [],
      target: ModerationTarget.content,
      subjectDid: generator.creator.did,
      preferredLocales: preferredLocales,
    ),
    engine.evaluateProfileLabels(
      generator.creator.labels ?? const [],
      subjectDid: generator.creator.did,
      preferredLocales: preferredLocales,
    ),
  ]);
}
