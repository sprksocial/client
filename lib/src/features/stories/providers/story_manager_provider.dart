import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/story_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/stories/providers/story_auto_delete_provider.dart';
import 'package:spark/src/features/stories/providers/story_repository_provider.dart';

part 'story_manager_provider.g.dart';

final storyManagerLoggerProvider = Provider<SparkLogger>((ref) {
  return GetIt.instance<LogService>().getLogger('StoryManager');
});

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
  late final StoryRepository _repository = ref.read(storyRepositoryProvider);
  late final SparkLogger _logger = ref.read(storyManagerLoggerProvider);

  @override
  Future<StoryManagerState> build() async {
    ref.watch(currentDidProvider);
    ref.watch(atprotoProvider);
    ref.read(storyAutoDeleteExecutorProvider.future).ignore();
    return _loadInitial();
  }

  Future<StoryManagerState> _loadInitial() async {
    try {
      final did = ref.read(currentDidProvider);
      if (did == null) {
        return StoryManagerState(stories: const [], error: 'Not authenticated');
      }
      // Page through all story records directly via atproto to include expired
      if (ref.read(atprotoProvider) == null) {
        return StoryManagerState(
          stories: const [],
          error: 'AtProto not initialized',
        );
      }
      String? cursor;
      final uris = <AtUri>[];
      do {
        final result = await _repository.listStoryRecords(
          did: did,
          cursor: cursor,
        );
        for (final record in result.records) {
          uris.add(record.uri);
        }
        cursor = result.cursor;
      } while (cursor != null);
      if (uris.isEmpty) {
        return StoryManagerState(stories: const []);
      }
      final storyViews = await _repository.getStoryViews(uris);

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
      await _repository.deleteStoryRecord(story.uri);
    } catch (e, s) {
      _logger.e('Error deleting story', error: e, stackTrace: s);
      // Revert by refreshing fully
      await refresh();
    }
  }
}
