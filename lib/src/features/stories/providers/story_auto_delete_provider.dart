import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/storage/preferences/storage_constants.dart';
import 'package:spark/src/features/stories/providers/story_manager_provider.dart';
import 'package:spark/src/features/stories/providers/story_provider_dependencies.dart';

part 'story_auto_delete_provider.g.dart';

final storyManagerRefresherProvider = Provider<Future<void> Function()>((ref) {
  return () => ref.read(storyManagerProvider.notifier).refresh();
});

/// Holds the auto delete preference state (bool)
@riverpod
class StoryAutoDeletePref extends _$StoryAutoDeletePref {
  @override
  Future<bool> build() async {
    final prefs = ref.read(storyAutoDeletePreferencesProvider);
    var stored = await prefs.getBool(StorageKeys.storyAutoDeleteEnabled);
    if (stored == null) {
      stored = true;
      await prefs.setBool(StorageKeys.storyAutoDeleteEnabled, true);
    }
    return stored;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = ref.read(storyAutoDeletePreferencesProvider);
    await prefs.setBool(StorageKeys.storyAutoDeleteEnabled, value);
    // Update state immutably
    state = AsyncData(value);
  }
}

/// Executes auto deletion at startup if enabled. Exposed as Future provider
/// so that splash / root widgets can await or just watch for side-effects.
@riverpod
Future<void> storyAutoDeleteExecutor(Ref ref) async {
  final enabledAsync = await ref.watch(storyAutoDeletePrefProvider.future);
  if (!enabledAsync) return;

  final dependencies = ref.read(storyProviderDependenciesProvider);
  final logger = dependencies.loggerFor('StoryAutoDeleteExec');
  final did = dependencies.did;
  if (!dependencies.atprotoAvailable || did == null) return;

  try {
    String? cursor;
    final expiredUris = <StoryRecordEntry>[];
    final now = ref.read(storyClockProvider)().toUtc();
    do {
      final page = await dependencies.loadRecordPage(did: did, cursor: cursor);
      for (final rec in page.records) {
        final createdAt = rec.value['createdAt'];
        DateTime? ts;
        if (createdAt is String) {
          ts = DateTime.tryParse(createdAt)?.toUtc();
        }
        if (ts != null && now.difference(ts) > const Duration(hours: 24)) {
          expiredUris.add(rec);
        }
      }
      cursor = page.cursor;
    } while (cursor != null);

    if (expiredUris.isEmpty) return;

    for (final record in expiredUris) {
      try {
        await dependencies.deleteRecord(record.uri);
      } catch (e) {
        logger.w('Failed deleting expired story ${record.uri}', error: e);
      }
    }

    // Refresh manager state if it's already loaded
    // Refresh story manager provider so UI reflects deletions
    await ref.read(storyManagerRefresherProvider)();
  } catch (e, s) {
    logger.e('Auto delete failed', error: e, stackTrace: s);
  }
}
