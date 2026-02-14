import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/stories/providers/story_auto_delete_provider.dart';

part 'story_archive_provider.g.dart';

/// Simple state holder for the story archive
class StoryArchiveState {
  StoryArchiveState({
    required this.stories,
    this.isLoading = false,
    this.error,
  });
  final List<StoryView> stories; // hydrated story views
  final bool isLoading;
  final String? error;

  StoryArchiveState copyWith({
    List<StoryView>? stories,
    bool? isLoading,
    String? error,
  }) {
    return StoryArchiveState(
      stories: stories ?? this.stories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class StoryArchive extends _$StoryArchive {
  late final StoryRepository _storyRepo;
  late final SparkLogger _logger;

  @override
  Future<StoryArchiveState> build() async {
    _storyRepo = GetIt.I<StoryRepository>();
    _logger = GetIt.I<LogService>().getLogger('StoryArchive');
    ref.read(storyAutoDeleteExecutorProvider.future).ignore();
    return _loadInitial();
  }

  Future<StoryArchiveState> _loadInitial() async {
    try {
      String? cursor;
      final stories = <StoryView>[];
      do {
        final result = await _storyRepo.getArchive(
          limit: 100,
          cursor: cursor,
        );
        stories.addAll(result.stories);
        cursor = result.cursor;
      } while (cursor != null);
      if (stories.isEmpty) {
        return StoryArchiveState(stories: const []);
      }

      stories.sort((a, b) => b.indexedAt.compareTo(a.indexedAt));

      return StoryArchiveState(stories: stories);
    } catch (e, s) {
      _logger.e('Failed to load stories for archive', error: e, stackTrace: s);
      return StoryArchiveState(stories: const [], error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadInitial);
  }
}
