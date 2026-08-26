import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/moderation/moderation.dart';
import 'package:spark/src/core/moderation/moderation_provider.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

part 'suggested_feeds_provider.g.dart';

final promotableSuggestedFeedsProvider =
    Provider.autoDispose<AsyncValue<List<GeneratorView>>>((ref) {
      final suggestedFeeds = ref.watch(suggestedFeedsProvider);
      final feeds = suggestedFeeds.value;
      if (feeds == null ||
          !feeds.any(
            (feed) => feedGeneratorModerationSubject(feed).hasLabels,
          )) {
        return suggestedFeeds;
      }

      return ref
          .watch(moderationEngineProvider)
          .when(
            data: (engine) => suggestedFeeds.whenData(
              (feeds) => feeds
                  .where(
                    (feed) => !feedGeneratorModerationSubject(
                      feed,
                    ).evaluate(engine).excludeFromPromotion,
                  )
                  .toList(growable: false),
            ),
            error: AsyncValue.error,
            loading: AsyncValue.loading,
          );
    });

/// Provider for fetching suggested Spark feeds
@riverpod
class SuggestedFeeds extends _$SuggestedFeeds {
  FeedRepository get _feedRepository => GetIt.instance<SprkRepository>().feed;
  SparkLogger get _logger =>
      GetIt.instance<LogService>().getLogger('SuggestedFeeds');

  @override
  Future<List<GeneratorView>> build() async {
    try {
      // Only fetch Spark feeds
      final feeds = await _feedRepository.getSuggestedFeeds();
      return feeds;
    } catch (e, stackTrace) {
      _logger.e(
        'Error fetching suggested feeds',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Refresh the suggested feeds
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      // Only fetch Spark feeds
      final feeds = await _feedRepository.getSuggestedFeeds();
      state = AsyncValue.data(feeds);
    } catch (e, stackTrace) {
      _logger.e(
        'Error refreshing suggested feeds',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
