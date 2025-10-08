import 'package:atproto_core/atproto_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/storage/preferences/storage_constants.dart';
import 'package:sparksocial/src/core/storage/preferences/storage_manager.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';
import 'package:sparksocial/src/features/stories/providers/story_manager_provider.dart';

part 'story_auto_delete_provider.g.dart';

/// Holds the auto delete preference state (bool)
@riverpod
class StoryAutoDeletePref extends _$StoryAutoDeletePref {
  late final SparkLogger _logger;

  @override
  Future<bool> build() async {
    _logger = GetIt.I<LogService>().getLogger('StoryAutoDeletePref');
    final prefs = StorageManager.instance.preferences;
    var stored = await prefs.getBool(StorageKeys.storyAutoDeleteEnabled);
    if (stored == null) {
      stored = true;
      await prefs.setBool(StorageKeys.storyAutoDeleteEnabled, true);
      _logger.d('Auto delete preference not found. Setting default to true.');
    } else {
      _logger.d('Loaded auto delete preference: $stored');
    }
    return stored;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = StorageManager.instance.preferences;
    await prefs.setBool(StorageKeys.storyAutoDeleteEnabled, value);
    _logger.d('Set auto delete preference to $value');
    // Update state immutably
    state = AsyncData(value);
  }
}

/// Executes auto deletion (once) at startup if enabled. Exposed as a Future provider
/// so that splash / root widgets can await or just watch for side-effects.
@riverpod
Future<void> storyAutoDeleteExecutor(Ref ref) async {
  final enabledAsync = await ref.watch(storyAutoDeletePrefProvider.future);
  if (!enabledAsync) return;

  final sprk = GetIt.I<SprkRepository>();
  final logger = GetIt.I<LogService>().getLogger('StoryAutoDeleteExec');
  final atproto = sprk.authRepository.atproto;
  final did = sprk.authRepository.session?.did;
  if (atproto == null || did == null) return;

  try {
    const collection = 'so.sprk.feed.story';
    String? cursor;
    final expiredUris = <AtUri>[];
    final now = DateTime.now().toUtc();
    do {
      final page = await atproto.repo.listRecords(
        repo: did,
        collection: NSID.parse(collection),
        cursor: cursor,
        limit: 100,
      );
      for (final rec in page.data.records) {
        final createdAt = rec.value['createdAt'];
        DateTime? ts;
        if (createdAt is String) {
          ts = DateTime.tryParse(createdAt)?.toUtc();
        }
        if (ts != null && now.difference(ts) > const Duration(hours: 24)) {
          expiredUris.add(rec.uri);
        }
      }
      cursor = page.data.cursor;
    } while (cursor != null);

    if (expiredUris.isEmpty) {
      logger.d('Auto delete: no expired stories');
      return;
    }

    logger.d('Auto delete: deleting ${expiredUris.length} expired stories');
    for (final uri in expiredUris) {
      try {
        await sprk.repo.deleteRecord(uri: uri);
      } catch (e) {
        logger.w('Failed deleting expired story $uri', error: e);
      }
    }

    // Refresh manager state if it's already loaded
    // Refresh story manager provider (will instantiate if not yet) so UI reflects deletions
    final manager = ref.read(storyManagerProvider.notifier);
    await manager.refresh();
  } catch (e, s) {
    GetIt.I<LogService>().getLogger('StoryAutoDeleteExec').e('Auto delete failed', error: e, stackTrace: s);
  }
}
