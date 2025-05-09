import 'dart:convert';
import 'dart:io';

import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:sparksocial/src/core/config/app_config.dart';
import 'package:sparksocial/src/core/network/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/video/data/models/models.dart';
import 'package:sparksocial/src/features/video/data/repositories/video_repository.dart';

class VideoRepositoryImpl implements VideoRepository {
  final AuthRepository _authRepository;
  final _logger = GetIt.instance<LogService>().getLogger('VideoRepository');

  VideoRepositoryImpl({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  @override
  Future<BlobReference?> processVideo(String videoPath) async {
    final atproto = _authRepository.atproto;
    if (atproto == null || _authRepository.session == null) {
      throw Exception('AtProto not initialized');
    }

    // Handle file:// URL scheme
    if (videoPath.startsWith('file://')) {
      videoPath = videoPath.replaceFirst('file://', '');
    }

    // Validate the video file
    final file = File(videoPath);
    if (!await file.exists()) {
      throw Exception('Video file not found: $videoPath');
    }

    try {
      // Check if the video is in a compatible format
      final videoBytes = await file.readAsBytes();
      if (videoBytes.isEmpty) {
        throw Exception('Video file is empty');
      }

      _logger.d('Video file size: ${videoBytes.length} bytes');

      final pdsService = atproto.service;
      final serviceTokenRes = await atproto.server.getServiceAuth(
        aud: 'did:web:$pdsService',
        lxm: NSID.parse('com.atproto.repo.uploadBlob'),
      );

      final serviceToken = serviceTokenRes.data.token;
      final response = await http.post(
        Uri.parse('${AppConfig.videoServiceUrl}/xrpc/so.sprk.video.uploadVideo'),
        headers: {'Authorization': 'Bearer $serviceToken', 'Content-Type': _getContentType(videoPath)},
        body: videoBytes,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to upload video: ${response.statusCode} ${response.body}');
      }

      // Parse the response
      final responseData = jsonDecode(response.body);

      // Extract the blob reference and convert to our model
      if (responseData != null && responseData is Map<String, dynamic>) {
        if (responseData.containsKey('blobRef')) {
          return BlobReference.fromJson(responseData['blobRef']);
        } else if (responseData.containsKey(r'$type') && responseData[r'$type'] == 'blob') {
          return BlobReference.fromJson(responseData);
        }
      }

      return null;
    } catch (e) {
      _logger.e('Error processing video: $e');
      rethrow;
    }
  }

  @override
  Future<StrongRef> postVideo(BlobReference? videoData, {String description = '', String videoAltText = ''}) async {
    if (videoData == null) {
      _logger.e('Video data is null');
      throw Exception('Video data is null');
    }
    
    // Create a VideoPost object with the provided data
    final videoPost = VideoPost.create(
      text: description,
      videoData: videoData.toJson(),
      videoAltText: videoAltText,
    );
    
    // Use the common implementation
    return postVideoWithPost(videoPost);
  }
  
  @override
  Future<StrongRef> postVideoWithPost(VideoPost videoPost) async {
    final atproto = _authRepository.atproto;
    if (atproto == null || _authRepository.session == null) {
      throw Exception('AtProto not initialized');
    }

    // Convert the VideoPost to its raw format for the API
    final postRecord = videoPost.toJson();

    // Create the post record
    final recordRes = await atproto.repo.createRecord(
      collection: NSID.parse('so.sprk.feed.post'), 
      record: postRecord
    );

    if (recordRes.status != HttpStatus.ok) {
      throw Exception('Failed to post video: ${recordRes.status} ${recordRes.data}');
    }

    return recordRes.data;
  }

  // Helper method to determine content type based on file extension
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