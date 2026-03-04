import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/search/providers/actor_typeahead_state.dart';

part 'actor_typeahead_provider.g.dart';

@riverpod
class ActorTypeahead extends _$ActorTypeahead {
  Timer? _debounce;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'ActorTypeaheadProvider',
  );
  final ActorRepository _actorRepository = GetIt.instance<ActorRepository>();

  @override
  ActorTypeaheadState build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });

    return ActorTypeaheadState.initial();
  }

  void updateQuery(String query, {int limit = 10}) {
    final trimmedQuery = query.trim();

    _debounce?.cancel();

    if (trimmedQuery.isEmpty) {
      state = ActorTypeaheadState.initial();
      return;
    }

    state = state.copyWith(query: trimmedQuery, isLoading: true, error: null);

    _debounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_searchTypeahead(trimmedQuery, limit: limit));
    });
  }

  Future<void> _searchTypeahead(String query, {int limit = 10}) async {
    try {
      final response = await _actorRepository.searchActorsTypeahead(
        query,
        limit: limit,
      );

      if (!ref.mounted || state.query != query) {
        return;
      }

      state = state.copyWith(results: response.actors, isLoading: false);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to fetch actor typeahead',
        error: e,
        stackTrace: stackTrace,
      );

      if (!ref.mounted || state.query != query) {
        return;
      }

      state = state.copyWith(
        error: 'Failed to fetch suggestions',
        isLoading: false,
      );
    }
  }

  void clear() {
    _debounce?.cancel();
    state = ActorTypeaheadState.initial();
  }
}
