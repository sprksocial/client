import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/stories/providers/story_auto_delete_provider.dart';

part 'story_manager_provider.g.dart';

/// Simple state holder for the story manager
class StoryManagerState {
  StoryManagerState({
    required this.stories,
    this.isLoading = false,
    this.error,
  });
  final List<StoryView> stories; // hydrated story views
  final bool isLoading;
  final String? error;

  StoryManagerState copyWith({
    List<StoryView>? stories,
    bool? isLoading,
    String? error,
  }) {
    return StoryManagerState(
      stories: stories ?? this.stories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class StoryManager extends _$StoryManager {
  late final SprkRepository _sprk;
  late final StoryRepository _storyRepo;
  late final SparkLogger _logger;

  @override
  Future<StoryManagerState> build() async {
    _sprk = GetIt.I<SprkRepository>();
    _storyRepo = GetIt.I<StoryRepository>();
    _logger = GetIt.I<LogService>().getLogger('StoryManager');
    ref.read(storyAutoDeleteExecutorProvider.future).ignore();
    return _loadInitial();
  }

  Future<StoryManagerState> _loadInitial() async {
    try {
      final did = _sprk.authRepository.did;
      if (did == null) {
        return StoryManagerState(stories: const [], error: 'Not authenticated');
      }
      // Page through all story records directly via atproto to include expired
      final atproto = _sprk.authRepository.atproto;
      if (atproto == null) {
        return StoryManagerState(
          stories: const [],
          error: 'AtProto not initialized',
        );
      }
      const collection = 'so.sprk.story.post';
      String? cursor;
      final uris = <AtUri>[];
      do {
        final result = await atproto.repo.listRecords(
          repo: did,
          collection: collection,
          cursor: cursor,
          limit: 100,
        );
        for (final record in result.data.records) {
          uris.add(record.uri);
        }
        cursor = result.data.cursor;
      } while (cursor != null);
      if (uris.isEmpty) {
        return StoryManagerState(stories: const []);
      }
      final storyViews = await _storyRepo.getStoryViews(uris);

      storyViews.sort((a, b) => b.indexedAt.compareTo(a.indexedAt));

      return StoryManagerState(stories: storyViews);
    } catch (e, s) {
      _logger.e('Failed to load stories for manager', error: e, stackTrace: s);
      return StoryManagerState(stories: const [], error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadInitial);
  }

  Future<void> deleteStory(StoryView story) async {
    final current = state.value;
    if (current == null) return;
    try {
      // Optimistic update
      final updatedList = List<StoryView>.from(current.stories)
        ..removeWhere((s) => s.uri == story.uri);
      state = AsyncData(current.copyWith(stories: updatedList));
      await _sprk.repo.deleteRecord(uri: story.uri);
    } catch (e, s) {
      _logger.e('Error deleting story', error: e, stackTrace: s);
      // Revert by refreshing fully
      await refresh();
    }
  }
}
