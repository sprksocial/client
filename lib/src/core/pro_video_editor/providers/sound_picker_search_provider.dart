import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sound_repository.dart';
import 'package:spark/src/core/pro_video_editor/providers/sound_picker_search_state.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

part 'sound_picker_search_provider.g.dart';

typedef SoundPickerSearchDebounceScheduler =
    void Function() Function(Duration delay, Future<void> Function() action);

final soundPickerSearchDebounceSchedulerProvider =
    Provider<SoundPickerSearchDebounceScheduler>((ref) {
      return (delay, action) {
        final timer = Timer(delay, () => unawaited(action()));
        return timer.cancel;
      };
    });

@riverpod
class SoundPickerSearch extends _$SoundPickerSearch {
  static const int _limit = 25;

  void Function()? _cancelDebounce;
  int _activeRequestToken = 0;

  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'SoundPickerSearchProvider',
  );
  final SoundRepository _soundRepository = GetIt.instance<SoundRepository>();

  @override
  SoundPickerSearchState build() {
    ref.onDispose(() {
      _cancelDebounce?.call();
    });

    final requestToken = ++_activeRequestToken;
    unawaited(_loadTrending(requestToken: requestToken, reset: true));
    return SoundPickerSearchState.initial().copyWith(isLoading: true);
  }

  void updateQuery(String query) {
    final trimmedQuery = query.trim();
    _cancelDebounce?.call();

    if (trimmedQuery.isEmpty) {
      final requestToken = ++_activeRequestToken;
      state = SoundPickerSearchState.initial().copyWith(isLoading: true);
      unawaited(_loadTrending(requestToken: requestToken, reset: true));
      return;
    }

    final requestToken = ++_activeRequestToken;
    state = state.copyWith(
      query: trimmedQuery,
      audios: const [],
      cursor: null,
      isLoading: true,
      isLoadingMore: false,
      error: null,
    );

    _cancelDebounce = ref.read(soundPickerSearchDebounceSchedulerProvider)(
      const Duration(milliseconds: 350),
      () =>
          _searchAudios(trimmedQuery, requestToken: requestToken, reset: true),
    );
  }

  Future<void> submitQuery(String query) async {
    final trimmedQuery = query.trim();
    _cancelDebounce?.call();

    if (trimmedQuery.isEmpty) {
      final requestToken = ++_activeRequestToken;
      state = SoundPickerSearchState.initial().copyWith(isLoading: true);
      await _loadTrending(requestToken: requestToken, reset: true);
      return;
    }

    final requestToken = ++_activeRequestToken;
    state = state.copyWith(
      query: trimmedQuery,
      audios: const [],
      cursor: null,
      isLoading: true,
      isLoadingMore: false,
      error: null,
    );
    await _searchAudios(trimmedQuery, requestToken: requestToken, reset: true);
  }

  Future<void> loadMore() async {
    final cursor = state.cursor;
    if (cursor == null ||
        cursor.isEmpty ||
        state.isLoading ||
        state.isLoadingMore) {
      return;
    }

    final requestToken = _activeRequestToken;
    state = state.copyWith(isLoadingMore: true, error: null);

    if (state.isSearching) {
      await _searchAudios(
        state.query,
        cursor: cursor,
        requestToken: requestToken,
        reset: false,
      );
    } else {
      await _loadTrending(
        cursor: cursor,
        requestToken: requestToken,
        reset: false,
      );
    }
  }

  Future<void> _loadTrending({
    String? cursor,
    required int requestToken,
    required bool reset,
  }) async {
    try {
      final response = await _soundRepository.getTrendingAudios(
        limit: _limit,
        cursor: cursor,
      );

      if (!_isCurrent(requestToken, '')) return;

      state = state.copyWith(
        audios: reset ? response.audios : [...state.audios, ...response.audios],
        cursor: response.cursor,
        isLoading: false,
        isLoadingMore: false,
        error: null,
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to load sound picker trending audios',
        error: e,
        stackTrace: stackTrace,
      );
      if (!_isCurrent(requestToken, '')) return;

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: 'Failed to load sounds',
      );
    }
  }

  Future<void> _searchAudios(
    String query, {
    String? cursor,
    required int requestToken,
    required bool reset,
  }) async {
    try {
      final response = await _soundRepository.searchAudios(
        query,
        limit: _limit,
        cursor: cursor,
      );

      if (!_isCurrent(requestToken, query)) return;

      state = state.copyWith(
        audios: reset ? response.audios : [...state.audios, ...response.audios],
        cursor: response.cursor,
        isLoading: false,
        isLoadingMore: false,
        error: null,
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to search sound picker audios',
        error: e,
        stackTrace: stackTrace,
      );
      if (!_isCurrent(requestToken, query)) return;

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: 'Failed to search sounds',
      );
    }
  }

  bool _isCurrent(int requestToken, String query) {
    return ref.mounted &&
        requestToken == _activeRequestToken &&
        state.query == query;
  }
}
