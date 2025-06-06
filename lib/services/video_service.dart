import 'dart:convert';
import 'dart:io';

import 'package:atproto/core.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:sparksocial/config/app_config.dart';
import 'package:sparksocial/services/auth_service.dart';

class VideoService {
  final AuthService _authService;

  VideoService(this._authService);

  Future<Map<String, dynamic>?> processVideo(String videoPath) async {
    final authAtProto = _authService.atproto;
    if (authAtProto == null || authAtProto.session == null) {
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

      final pdsService = authAtProto.service;
      final serviceTokenRes = await authAtProto.server.getServiceAuth(
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

      // Extract just the blobRef if it exists
      if (responseData != null && responseData is Map<String, dynamic> && responseData.containsKey('blobRef')) {
        return responseData['blobRef'];
      }

      return responseData;
    } catch (e) {
      rethrow;
    }
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
