import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/storage/cache/cache_manager_interface.dart';
import 'package:sparksocial/src/core/utils/logging/logging.dart';
import 'package:sparksocial/src/features/feed/data/repositories/media_repository.dart';
import 'package:sparksocial/src/features/feed/data/repositories/media_repository_impl.dart';

part 'media_provider.g.dart';

/// Provider for the media repository
@Riverpod(keepAlive: true)
MediaRepository mediaRepository(Ref ref) {
  final mediaRepository = MediaRepositoryImpl(
    cacheManager: GetIt.instance<CacheManagerInterface>(),
    logService: GetIt.instance<LogService>(),
  );
  
  ref.onDispose(() {
    mediaRepository.dispose();
  });
  
  return mediaRepository;
}

/// Provider for checking if a video is preloaded
@riverpod
bool isVideoPreloaded(Ref ref, int index) {
  final mediaRepository = ref.watch(mediaRepositoryProvider);
  return mediaRepository.isVideoPreloaded(index);
}

/// Provider for getting a local video path
@riverpod
String? localVideoPath(Ref ref, int index) {
  final mediaRepository = ref.watch(mediaRepositoryProvider);
  return mediaRepository.getLocalVideoPath(index);
}

/// Provider for getting a preloaded video
@riverpod
Future<void> preloadMedia(
  Ref ref, {
  required int index,
  required String? videoUrl,
  required List<String> imageUrls,
  required BuildContext context,
}) async {
  final mediaRepository = ref.watch(mediaRepositoryProvider);
  await mediaRepository.preloadMedia(index, videoUrl, imageUrls, context);
} 