import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/network/atproto/atproto.dart';
import 'package:spark/src/core/storage/preferences/local_storage_interface.dart';
import 'package:spark/src/core/storage/preferences/storage_manager.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return GetIt.instance<StoryRepository>();
});

final storyCurrentDidProvider = Provider<String?>((ref) {
  return GetIt.instance<SprkRepository>().authRepository.did;
});

final storyAtprotoAvailableProvider = Provider<bool>((ref) {
  return GetIt.instance<SprkRepository>().authRepository.atproto != null;
});

final storyLoggerProvider = Provider.family<SparkLogger, String>((ref, name) {
  return GetIt.instance<LogService>().getLogger(name);
});

final storyAutoDeletePreferencesProvider = Provider<LocalStorageInterface>((
  ref,
) {
  return StorageManager.instance.preferences;
});

final storyClockProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});
