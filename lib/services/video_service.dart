import 'dart:convert';
import 'dart:io';
import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sparksocial/services/auth_service.dart';
import 'package:sparksocial/config/app_config.dart';
import 'package:http/http.dart' as http;

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
      // Ensure the video is in a compatible format
      final processedVideoPath = await _ensureCompatibleFormat(videoPath);
      final processedFile = File(processedVideoPath);
      
      if (!await processedFile.exists()) {
        throw Exception('Processed video file not found: $processedVideoPath');
      }
      
      final videoBytes = await processedFile.readAsBytes();
      if (videoBytes.isEmpty) {
        throw Exception('Video file is empty');
      }
      
      print('Video file size: ${videoBytes.length} bytes');
      
      final pdsService = authAtProto.service;
      final serviceTokenRes = await authAtProto.server.getServiceAuth(
        aud: 'did:web:$pdsService',
        lxm: NSID.parse('com.atproto.repo.uploadBlob'),
      );

      final serviceToken = serviceTokenRes.data.token;
      final response = await http.post(
        Uri.parse('${AppConfig.videoServiceUrl}/xrpc/so.sprk.video.uploadVideo'),
        headers: {
          'Authorization': 'Bearer $serviceToken',
          'Content-Type': 'video/mp4',
        },
        body: videoBytes,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to upload video: ${response.statusCode} ${response.body}');
      }

      // Clean up temporary file if it's different from the original
      if (processedVideoPath != videoPath) {
        await File(processedVideoPath).delete().catchError((e) => print('Error deleting temp file: $e'));
      }

      return jsonDecode(response.body);
    } catch (e) {
      print('Error processing video: $e');
      rethrow;
    }
  }

  // Helper method to ensure video is in MP4 format
  Future<String> _ensureCompatibleFormat(String videoPath) async {
    // Handle file:// URL scheme
    if (videoPath.startsWith('file://')) {
      videoPath = videoPath.replaceFirst('file://', '');
    }
    
    // Check if the file is already in MP4 format with compatible encoding
    final extension = path.extension(videoPath).toLowerCase();
    
    // If already MP4, just return the path
    if (extension == '.mp4') {
      print('Video is already in MP4 format, using as is');
      return videoPath;
    }
    
    // Otherwise, convert to MP4
    final tempDir = await getTemporaryDirectory();
    final outputPath = path.join(tempDir.path, 'converted_${DateTime.now().millisecondsSinceEpoch}.mp4');
    
    print('Converting video to MP4 format: $outputPath');
    
    // Use FFmpeg to convert the video to MP4 with H.264 codec
    final session = await FFmpegKit.execute(
      '-i "$videoPath" -c:v libx264 -preset fast -crf 23 -c:a aac -b:a 128k "$outputPath"'
    );
    
    final returnCode = await session.getReturnCode();
    
    if (ReturnCode.isSuccess(returnCode)) {
      print('Video conversion successful');
      return outputPath;
    } else {
      print('Video conversion failed: ${await session.getOutput()}');
      // If conversion fails, try to use the original file
      return videoPath;
    }
  }

  Future<StrongRef> postVideo(Map<String, dynamic>? videoBlobRef, [String description = '']) async {
    final authAtProto = _authService.atproto;
    if (authAtProto == null || authAtProto.session == null) {
      throw Exception('AtProto not initialized');
    }

    if (videoBlobRef == null) {
      throw Exception('Video blob reference is null');
    }

    final postText = description.isNotEmpty ? description : 'New video';
    
    final postRecord = {
      '\$type': 'so.sprk.feed.post',
      'text': postText,
      'embed': {'\$type': 'so.sprk.embed.video', 'video': videoBlobRef},
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };

    final recordRes = await authAtProto.repo.createRecord(collection: NSID.parse('so.sprk.feed.post'), record: postRecord);

    if (recordRes.status != HttpStatus.ok) {
      throw Exception('Failed to post video: ${recordRes.status} ${recordRes.data}');
    }

    return recordRes.data;
  }
}
