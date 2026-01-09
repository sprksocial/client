import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sound_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/sound/providers/sound_page_state.dart';

part 'sound_page_provider.g.dart';

@riverpod
class SoundPage extends _$SoundPage {
  final SoundRepository _soundRepository = GetIt.instance<SoundRepository>();
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'SoundPage',
  );
  bool _isLoading = false;

  @override
  Future<SoundPageState> build(AtUri audioUri) async {
    try {
      final response = await _soundRepository.getAudioPosts(
        audioUri,
        limit: SoundPageState.fetchLimit,
      );

      return SoundPageState(
        audio: response.audio,
        posts: response.posts,
        cursor: response.cursor,
        isEndOfNetwork: response.cursor == null,
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Error loading audio posts: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || (state.value?.isEndOfNetwork ?? true)) return;

    _isLoading = true;
    final currentState = state.value;
    if (currentState == null) {
      _isLoading = false;
      return;
    }

    try {
      final response = await _soundRepository.getAudioPosts(
        audioUri,
        limit: SoundPageState.fetchLimit,
        cursor: currentState.cursor,
      );

      final updatedPosts = [...currentState.posts, ...response.posts];

      state = AsyncValue.data(
        currentState.copyWith(
          posts: updatedPosts,
          cursor: response.cursor,
          isEndOfNetwork: response.cursor == null,
        ),
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Error loading more audio posts: $e',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    try {
      final response = await _soundRepository.getAudioPosts(
        audioUri,
        limit: SoundPageState.fetchLimit,
      );

      state = AsyncValue.data(
        SoundPageState(
          audio: response.audio,
          posts: response.posts,
          cursor: response.cursor,
          isEndOfNetwork: response.cursor == null,
        ),
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Error refreshing audio posts: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
