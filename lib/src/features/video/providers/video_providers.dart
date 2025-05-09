import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:atproto/atproto.dart';
import 'package:sparksocial/src/features/video/data/models/models.dart';
import 'package:sparksocial/src/features/video/data/repositories/video_repository.dart';

part 'video_providers.g.dart';

/// Provider for the video repository
@Riverpod(keepAlive: true)
VideoRepository videoRepository(Ref ref) {
  return GetIt.instance<VideoRepository>();
}

/// Provider for processing a video
@riverpod
Future<BlobReference?> processVideo(
  Ref ref, 
  {required String videoPath}
) async {
  final videoRepository = ref.watch(videoRepositoryProvider);
  return videoRepository.processVideo(videoPath);
}

/// Provider for posting a video
@riverpod
Future<StrongRef> postVideo(
  Ref ref, {
  required BlobReference? videoData,
  String description = '',
  String videoAltText = '',
}) async {
  final videoRepository = ref.watch(videoRepositoryProvider);
  return videoRepository.postVideo(
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
  final videoRepository = ref.watch(videoRepositoryProvider);
  return videoRepository.postVideoWithPost(videoPost);
} 