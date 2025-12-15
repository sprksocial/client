import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';

part 'suggested_feeds_provider.g.dart';

/// Provider for fetching suggested Spark feeds
@riverpod
class SuggestedFeeds extends _$SuggestedFeeds {
  FeedRepository get _feedRepository => GetIt.instance<SprkRepository>().feed;
  SparkLogger get _logger => GetIt.instance<LogService>().getLogger('SuggestedFeeds');

  @override
  Future<List<GeneratorView>> build() async {
    try {
      _logger.d('Fetching suggested Spark feeds...');
      // Only fetch Spark feeds
      final feeds = await _feedRepository.getSuggestedFeeds();
      _logger.d('Fetched ${feeds.length} suggested Spark feeds');
      return feeds;
    } catch (e, stackTrace) {
      _logger.e('Error fetching suggested feeds', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Refresh the suggested feeds
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      _logger.d('Refreshing suggested Spark feeds...');
      // Only fetch Spark feeds
      final feeds = await _feedRepository.getSuggestedFeeds();
      _logger.d('Refreshed ${feeds.length} suggested Spark feeds');
      state = AsyncValue.data(feeds);
    } catch (e, stackTrace) {
      _logger.e('Error refreshing suggested feeds', error: e, stackTrace: stackTrace);
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
