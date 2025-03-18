import 'dart:convert';
import 'dart:io';
import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
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

    final file = File(videoPath);
    if (!await file.exists()) {
      throw Exception('Video file not found');
    }

    final videoBytes = await file.readAsBytes();
    final pdsService = authAtProto.service;
    final serviceTokenRes = await authAtProto.server.getServiceAuth(
      aud: 'did:web:$pdsService',
      lxm: NSID.parse('com.atproto.repo.uploadBlob'),
    );

    final serviceToken = serviceTokenRes.data.token;
    final response = await http.post(
      Uri.parse('${AppConfig.videoServiceUrl}/xrpc/so.sprk.video.uploadVideo'),
      headers: {'Authorization': 'Bearer $serviceToken'},
      body: videoBytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to upload video: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body);
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
