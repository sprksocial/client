import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/search/providers/actor_typeahead_state.dart';
import 'package:spark/src/features/search/providers/search_debounce_scheduler.dart';

part 'actor_typeahead_provider.g.dart';

@riverpod
class ActorTypeahead extends _$ActorTypeahead {
  void Function()? _cancelDebounce;
  int _activeRequestToken = 0;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'ActorTypeaheadProvider',
  );
  final ActorRepository _actorRepository = GetIt.instance<ActorRepository>();

  @override
  ActorTypeaheadState build() {
    ref.onDispose(() {
      _cancelDebounce?.call();
    });

    return ActorTypeaheadState.initial();
  }

  void updateQuery(String query, {int limit = 10}) {
    final trimmedQuery = query.trim();

    _cancelDebounce?.call();

    if (trimmedQuery.isEmpty) {
      _activeRequestToken++;
      state = ActorTypeaheadState.initial();
      return;
    }

    state = state.copyWith(query: trimmedQuery, isLoading: true, error: null);

    final requestToken = ++_activeRequestToken;
    _cancelDebounce = ref.read(searchDebounceSchedulerProvider)(
      const Duration(milliseconds: 300),
      () => _searchTypeahead(
        trimmedQuery,
        limit: limit,
        requestToken: requestToken,
      ),
    );
  }

  Future<void> _searchTypeahead(
    String query, {
    int limit = 10,
    required int requestToken,
  }) async {
    try {
      final response = await _actorRepository.searchActorsTypeahead(
        query,
        limit: limit,
      );

      if (!ref.mounted ||
          requestToken != _activeRequestToken ||
          state.query != query) {
        return;
      }

      state = state.copyWith(results: response.actors, isLoading: false);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to fetch actor typeahead',
        error: e,
        stackTrace: stackTrace,
      );

      if (!ref.mounted ||
          requestToken != _activeRequestToken ||
          state.query != query) {
        return;
      }

      state = state.copyWith(
        error: 'Failed to fetch suggestions',
        isLoading: false,
      );
    }
  }

  void clear() {
    _cancelDebounce?.call();
    _activeRequestToken++;
    state = ActorTypeaheadState.initial();
  }
}
