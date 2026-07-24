import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/repo/list_records.dart'
    as repo_list_records;
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/storage/preferences/local_storage_interface.dart';
import 'package:spark/src/core/storage/preferences/storage_manager.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

class StoryRecordEntry {
  const StoryRecordEntry({required this.uri, required this.value});

  final AtUri uri;
  final Map<String, dynamic> value;
}

class StoryRecordPage {
  const StoryRecordPage({required this.records, this.cursor});

  final List<StoryRecordEntry> records;
  final String? cursor;
}

typedef StoryRecordPageLoader =
    Future<StoryRecordPage> Function({required String did, String? cursor});

class StoryProviderDependencies {
  const StoryProviderDependencies({
    required this.readDid,
    required this.readAtprotoAvailable,
    required this.loadRecordPage,
    required this.storyRepository,
    required this.deleteRecord,
    required this.loggerFor,
  });

  final String? Function() readDid;
  final bool Function() readAtprotoAvailable;
  final StoryRecordPageLoader loadRecordPage;
  final StoryRepository storyRepository;
  final Future<void> Function(AtUri uri) deleteRecord;
  final SparkLogger Function(String name) loggerFor;

  String? get did => readDid();
  bool get atprotoAvailable => readAtprotoAvailable();
}

final storyProviderDependenciesProvider = Provider<StoryProviderDependencies>((
  ref,
) {
  final sprk = GetIt.instance<SprkRepository>();
  return StoryProviderDependencies(
    readDid: () => sprk.authRepository.did,
    readAtprotoAvailable: () => sprk.authRepository.atproto != null,
    loadRecordPage: ({required did, cursor}) async {
      final atproto = sprk.authRepository.atproto;
      if (atproto == null) {
        throw StateError('AtProto not initialized');
      }
      final result = await atproto.call(
        repo_list_records.comAtprotoRepoListRecords,
        parameters: repo_list_records.RepoListRecordsInput(
          repo: did,
          collection: 'so.sprk.story.post',
          cursor: cursor,
          limit: 100,
        ),
      );
      return StoryRecordPage(
        records: [
          for (final record in result.data.records)
            StoryRecordEntry(uri: record.uri, value: record.value),
        ],
        cursor: result.data.cursor,
      );
    },
    storyRepository: GetIt.instance<StoryRepository>(),
    deleteRecord: (uri) => sprk.repo.deleteRecord(uri: uri),
    loggerFor: GetIt.instance<LogService>().getLogger,
  );
});

final storyAutoDeletePreferencesProvider = Provider<LocalStorageInterface>((
  ref,
) {
  return StorageManager.instance.preferences;
});

final storyClockProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});
