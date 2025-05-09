import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:atproto/atproto.dart';
import 'package:sparksocial/src/features/video/data/models/models.dart';
import 'package:sparksocial/src/features/video/data/repositories/upload_repository.dart';

part 'video_providers.g.dart';

/// Provider for the upload repository
@Riverpod(keepAlive: true)
UploadRepository uploadRepository(Ref ref) {
  return GetIt.instance<UploadRepository>();
}

/// Provider for processing a video
@riverpod
Future<BlobReference?> processVideo(
  Ref ref, 
  {required String videoPath}
) async {
  final uploadRepository = ref.watch(uploadRepositoryProvider);
  return uploadRepository.processVideo(videoPath);
}

/// Provider for posting a video
@riverpod
Future<StrongRef> postVideo(
  Ref ref, {
  required BlobReference? videoData,
  String description = '',
  String videoAltText = '',
}) async {
  final uploadRepository = ref.watch(uploadRepositoryProvider);
  return uploadRepository.postVideo(
    videoData,
    description: description,
    videoAltText: videoAltText,
  );
}

/// Provider for posting a video with a prepared VideoPost
@riverpod
Future<StrongRef> postVideoWithPost(
  Ref ref, {
  required VideoPost videoPost,
}) async {
  final uploadRepository = ref.watch(uploadRepositoryProvider);
  return uploadRepository.postVideoWithPost(videoPost);
} 