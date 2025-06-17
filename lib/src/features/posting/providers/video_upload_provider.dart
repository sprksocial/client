import 'dart:convert';
import 'dart:io';

import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sparksocial/src/core/network/atproto/atproto.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';

import '../../../core/auth/data/repositories/auth_repository.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/logging/log_service.dart';
import 'video_upload_state.dart';

part 'video_upload_provider.g.dart';

@riverpod
class VideoUpload extends _$VideoUpload {
  late final AuthRepository _authRepository;
  late final SparkLogger _logger;

  @override
  VideoUploadState build(String videoPath) {
    _authRepository = GetIt.instance<SprkRepository>().authRepository;
    _logger = GetIt.instance<LogService>().getLogger('VideoService');
    return VideoUploadState.initial(videoPath: videoPath);
  }

  /// Process a video file and upload it to the video service
  Future<void> processVideo(String videoPath) async {
    try {
      state = VideoUploadState.processingVideo(videoPath: videoPath);
      _logger.i('Starting video processing for: $videoPath');

      final authAtProto = _authRepository.atproto;
      if (authAtProto == null || authAtProto.session == null) {
        throw Exception('AtProto not initialized');
      }

      // Handle file:// URL scheme
      String cleanVideoPath = videoPath;
      if (videoPath.startsWith('file://')) {
        cleanVideoPath = videoPath.replaceFirst('file://', '');
      }

      // Validate the video file
      final file = File(cleanVideoPath);
      if (!await file.exists()) {
        throw Exception('Video file not found: $cleanVideoPath');
      }

      // Check if the video is in a compatible format
      final videoBytes = await file.readAsBytes();
      if (videoBytes.isEmpty) {
        throw Exception('Video file is empty');
      }

      _logger.i('Video file size: ${videoBytes.length} bytes');

      final pdsService = authAtProto.service;
      final serviceTokenRes = await authAtProto.server.getServiceAuth(
        aud: 'did:web:$pdsService',
        lxm: NSID.parse('com.atproto.repo.uploadBlob'),
      );

      final serviceToken = serviceTokenRes.data.token;
      final response = await http.post(
        Uri.parse('${AppConfig.videoServiceUrl}/xrpc/so.sprk.video.uploadVideo'),
        headers: {'Authorization': 'Bearer $serviceToken', 'Content-Type': _getContentType(cleanVideoPath)},
        body: videoBytes,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to upload video: ${response.statusCode} ${response.body}');
      }

      // Parse the response
      final responseData = jsonDecode(response.body);
      Blob blob;
      //{'jobStatus': {'blob': blob}} = responseData; this is how it should work in the lexicon
      blob = Blob.fromJson(responseData['blobRef']);

      state = VideoUploadState.videoProcessed(videoPath: videoPath, blob: blob);

      _logger.i('Video processed successfully');
    } catch (error, stackTrace) {
      _logger.e('Error processing video', error: error, stackTrace: stackTrace);
      state = VideoUploadState.error(message: error.toString(), videoPath: videoPath);
    }
  }

  /// Post a video to the feed using the processed blob reference
  Future<void> postVideo({
    required Blob blob,
    String description = '',
    String altText = '',
    String? videoPath,
    bool crosspostToBsky = false,
  }) async {
    try {
      state = VideoUploadState.postingVideo(
        videoPath: videoPath ?? state.currentVideoPath ?? '',
        blob: blob,
        description: description,
        altText: altText,
      );

      final authAtProto = _authRepository.atproto;
      if (authAtProto == null || authAtProto.session == null) {
        throw Exception('AtProto not initialized');
      }

      final postText = description.isNotEmpty ? description : '';

      // Create a properly formatted AT Protocol post record
      final postRecord = PostRecord(
        text: postText,
        embed: EmbedVideo(video: blob, alt: altText),
        createdAt: DateTime.now().toUtc(),
      );

      // Create the post record
      final recordRes = await authAtProto.repo.createRecord(
        collection: NSID.parse('so.sprk.feed.post'),
        record: postRecord.toJson(),
      );

      if (recordRes.status != HttpStatus.ok) {
        throw Exception('Failed to post video: ${recordRes.status} ${recordRes.data}');
      }

      // Crosspost to Bluesky if enabled
      if (crosspostToBsky) {
        try {
          await _crosspostVideoToBlueSky(postText, blob, altText);
        } catch (e) {
          _logger.w('Failed to crosspost video to Bluesky: $e');
          // Don't fail the entire operation if Bluesky crossposting fails
        }
      }

      state = VideoUploadState.posted(videoPath: videoPath ?? state.currentVideoPath ?? '', blob: blob, postRef: recordRes.data);

      _logger.i('Video posted successfully');
    } catch (error, stackTrace) {
      _logger.e('Error posting video', error: error, stackTrace: stackTrace);
      state = VideoUploadState.error(message: error.toString(), videoPath: videoPath ?? state.currentVideoPath, blob: blob);
    }
  }

  /// Process video and post it in one step
  Future<void> processAndPostVideo({
    required String videoPath,
    String description = '',
    String altText = '',
    bool crosspostToBsky = false,
  }) async {
    await processVideo(videoPath);

    // Check if processing was successful
    final currentState = state;
    if (currentState is VideoUploadStateVideoProcessed) {
      await postVideo(
        blob: currentState.blob,
        description: description,
        altText: altText,
        videoPath: videoPath,
        crosspostToBsky: crosspostToBsky,
      );
    }
  }

  /// Crosspost video to Bluesky using same blob but Bluesky models
  Future<void> _crosspostVideoToBlueSky(String text, Blob blob, String altText) async {
    _logger.d('Crossposting video to Bluesky');

    final session = _authRepository.session;
    if (session == null) {
      throw Exception('No session available for Bluesky crosspost');
    }

    // Create Bluesky video post record using direct JSON structure
    final bskyPostRecord = <String, dynamic>{
      "\$type": "app.bsky.feed.post",
      "text": text,
      "embed": {"\$type": "app.bsky.embed.video", "video": blob.toJson(), "alt": altText},
      "createdAt": DateTime.now().toUtc().toIso8601String(),
    };

    final bskyAtProto = _authRepository.atproto!;
    final bskyResult = await bskyAtProto.repo.createRecord(collection: NSID.parse('app.bsky.feed.post'), record: bskyPostRecord);

    _logger.i('Successfully crossposted video to Bluesky: ${bskyResult.data.uri}');
  }

  /// Helper method to determine content type based on file extension
  String _getContentType(String videoPath) {
    final extension = path.extension(videoPath).toLowerCase();

    switch (extension) {
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.avi':
        return 'video/x-msvideo';
      case '.webm':
        return 'video/webm';
      default:
        return 'video/mp4'; // Default to mp4
    }
  }
}
