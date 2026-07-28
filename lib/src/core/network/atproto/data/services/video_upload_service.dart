import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/server/get_service_auth.dart'
    as server_get_service_auth;
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/config/app_config.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/core/utils/video_upload_exception.dart';
import 'package:sprk_poptart/so/sprk/sound/defs/audio_details.dart';

abstract interface class VideoUploadService {
  Future<VideoUploadResult> uploadVideo(
    String videoPath, {
    void Function(double progress)? onUploadProgress,
  });
}

class VideoUploadClient implements VideoUploadService {
  factory VideoUploadClient(
    AuthRepository authRepository, {
    required SparkLogger logger,
    DateTime Function()? now,
    http.Client Function()? httpClientFactory,
    Future<void> Function(Duration)? processingDelay,
    File Function(String)? file,
    Future<String> Function(PoptartClient)? serviceAuthTokenRequest,
  }) {
    return VideoUploadClient._(
      authRepository,
      logger,
      now ?? DateTime.now,
      httpClientFactory ?? http.Client.new,
      processingDelay ?? Future<void>.delayed,
      file ?? File.new,
      serviceAuthTokenRequest,
    );
  }

  VideoUploadClient._(
    this._authRepository,
    this._logger,
    this._now,
    this._httpClientFactory,
    this._processingDelay,
    this._file,
    this._serviceAuthTokenRequest,
  );

  final AuthRepository _authRepository;
  final SparkLogger _logger;
  final DateTime Function() _now;
  final http.Client Function() _httpClientFactory;
  final Future<void> Function(Duration) _processingDelay;
  final File Function(String) _file;
  final Future<String> Function(PoptartClient)? _serviceAuthTokenRequest;

  @override
  Future<VideoUploadResult> uploadVideo(
    String videoPath, {
    void Function(double progress)? onUploadProgress,
  }) async {
    _logger.d('Uploading video from path: $videoPath');

    if (!_authRepository.isAuthenticated) {
      _logger.w('Not authenticated');
      throw Exception('Not authenticated');
    }
    final authAtProto = _authRepository.atproto;
    if (authAtProto == null || authAtProto.oAuthSession == null) {
      throw Exception('AtProto not initialized');
    }

    final cleanVideoPath = videoPath.startsWith('file://')
        ? videoPath.replaceFirst('file://', '')
        : videoPath;
    final videoFile = _file(cleanVideoPath);
    if (!videoFile.existsSync()) {
      throw Exception('Video file not found: $cleanVideoPath');
    }

    final videoSizeBigInt = BigInt.from(await videoFile.length());
    if (videoSizeBigInt == BigInt.zero) {
      throw Exception('Video file is empty');
    }

    if (videoSizeBigInt > BigInt.from(2 * 1024 * 1024 * 1024)) {
      _logger.w(
        'Video file exceeds 2GB, may cause issues: $videoSizeBigInt bytes',
      );
      throw VideoUploadException(
        'Video is too large. Maximum supported size is 2GB.',
        statusCode: 413,
        uploadSizeBytes: videoSizeBigInt.toInt(),
        limitBytes: 2 * 1024 * 1024 * 1024,
      );
    }

    final videoSizeBytes = videoSizeBigInt.toInt();
    _logger.i('Video file size: $videoSizeBytes bytes');
    final maxUploadSizeBytes = (AppConfig.maxUploadSizeMB * 1024 * 1024)
        .round();
    if (maxUploadSizeBytes > 0 && videoSizeBytes > maxUploadSizeBytes) {
      _logger.w(
        'Video file exceeds upload limit: $videoSizeBytes bytes '
        '(limit: $maxUploadSizeBytes bytes)',
      );
      throw VideoUploadException(
        'Video is too large to upload.',
        statusCode: 413,
        uploadSizeBytes: videoSizeBytes,
        limitBytes: maxUploadSizeBytes,
      );
    }

    if (videoSizeBytes > 2147483647) {
      _logger.e('Video file too large for HTTP content-length header');
      throw VideoUploadException(
        'Video is too large to upload.',
        statusCode: 413,
        uploadSizeBytes: videoSizeBytes,
        limitBytes: 2147483647,
      );
    }

    var serviceToken = await _createServiceAuthToken();
    final httpClient = _httpClientFactory();
    try {
      final uploadRequest =
          http.StreamedRequest(
              'POST',
              Uri.parse(
                '${AppConfig.videoServiceUrl}/xrpc/so.sprk.video.uploadVideo',
              ),
            )
            ..contentLength = videoSizeBytes
            ..headers.addAll({
              'Authorization': 'Bearer $serviceToken',
              'Content-Type': _getContentType(cleanVideoPath),
            });

      onUploadProgress?.call(0);
      final uploadResponseFuture = httpClient.send(uploadRequest);
      try {
        await uploadRequest.sink.addStream(
          _trackUploadProgress(
            videoFile.openRead(),
            totalBytes: videoSizeBytes,
            onUploadProgress: onUploadProgress,
          ),
        );
      } finally {
        unawaited(uploadRequest.sink.close());
      }
      var response = await http.Response.fromStream(await uploadResponseFuture);

      if (response.statusCode != 200) {
        _logger.e(
          'Video upload failed: ${response.statusCode} ${response.body}',
        );
        throw VideoUploadException(
          _buildFailureMessage(
            fallback: response.statusCode == 413
                ? 'Video is too large to upload.'
                : 'Failed to upload video.',
            detail: response.body,
          ),
          statusCode: response.statusCode,
          uploadSizeBytes: videoSizeBytes,
          limitBytes: maxUploadSizeBytes > 0 ? maxUploadSizeBytes : null,
          responseBody: response.body,
        );
      }

      dynamic responseData = jsonDecode(response.body);
      _logger.d('Video upload response: $responseData');

      var jobState = responseData['jobStatus']?['state'] as String?;
      var attempts = 0;
      var consecutivePollErrors = 0;
      const maxAttempts = 120;
      const maxConsecutivePollErrors = 3;
      while (jobState == 'JOB_STATE_QUEUED' ||
          jobState == 'JOB_STATE_PROCESSING') {
        _logger.d('Video upload in progress, status: $jobState');
        await _processingDelay(const Duration(seconds: 2));
        attempts++;
        if (attempts > maxAttempts) {
          throw const VideoUploadException(
            'Video processing timed out. Please try again.',
          );
        }

        try {
          response = await httpClient.get(
            _jobStatusUri(responseData),
            headers: _videoHeaders(serviceToken, cleanVideoPath),
          );
          if (_isExpiredTokenResponse(response)) {
            _logger.i(
              'Video service token expired while polling; minting a new token',
            );
            serviceToken = await _createServiceAuthToken(
              refreshPdsSessionOnFailure: true,
            );
            response = await httpClient.get(
              _jobStatusUri(responseData),
              headers: _videoHeaders(serviceToken, cleanVideoPath),
            );
          }
          if (response.statusCode != 200) {
            throw Exception(
              'Failed to check video upload status: ${response.statusCode} '
              '${response.body}',
            );
          }
          responseData = jsonDecode(response.body);
          _logger.d('Video upload status response: $responseData');
          jobState = responseData['jobStatus']?['state'] as String?;
          consecutivePollErrors = 0;
        } catch (error) {
          consecutivePollErrors++;
          _logger.w(
            'Error polling video upload status on attempt '
            '$attempts/$maxAttempts '
            '(consecutive errors: '
            '$consecutivePollErrors/$maxConsecutivePollErrors): $error',
          );

          if (consecutivePollErrors >= maxConsecutivePollErrors) {
            _logger.e(
              'Too many consecutive polling errors, giving up: $error',
              error: error,
            );
            throw VideoUploadException(
              _buildFailureMessage(
                fallback: 'Failed to check video processing status.',
                detail: error.toString(),
              ),
              responseBody: error.toString(),
            );
          }

          _logger.d('Retrying poll after error...');
          jobState = 'JOB_STATE_PROCESSING';
        }
      }

      if (responseData['jobStatus']?['state'] == 'JOB_STATE_FAILED') {
        final failureMessage = _buildFailureMessage(
          fallback: 'Video processing failed.',
          detail: responseData['jobStatus'] ?? responseData,
        );
        _logger.e(
          'Video processing job failed: $failureMessage',
          error: responseData,
        );
        throw VideoUploadException(
          failureMessage,
          responseBody: jsonEncode(responseData),
        );
      }

      final Map<String, dynamic> videoBlobData;
      if (responseData case {'jobStatus': {'blob': final blobData}}) {
        videoBlobData = blobData as Map<String, dynamic>;
      } else if (responseData case {'blobRef': final blobRef}) {
        videoBlobData = blobRef as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response format: $responseData');
      }
      final videoBlob = Blob.fromJson(videoBlobData);

      Blob? audioBlob;
      AudioDetails? audioDetails;
      if (responseData case {'jobStatus': {'audio': final audioData}}) {
        final audio = audioData as Map<String, dynamic>;
        if (audio['blob'] != null) {
          audioBlob = Blob.fromJson(audio['blob'] as Map<String, dynamic>);
          _logger.d('Extracted audio blob: ${audioBlob.size} bytes');
        }
        if (audio['details'] != null) {
          audioDetails = AudioDetails.fromJson(
            audio['details'] as Map<String, dynamic>,
          );
        }
      }

      return VideoUploadResult(
        videoBlob: videoBlob,
        audioBlob: audioBlob,
        audioDetails: audioDetails,
      );
    } finally {
      httpClient.close();
    }
  }

  Uri _jobStatusUri(dynamic responseData) {
    return Uri.parse(
      '${AppConfig.videoServiceUrl}/xrpc/so.sprk.video.getJobStatus',
    ).replace(
      queryParameters: {
        'jobId': responseData['jobStatus']?['jobId'] as String?,
      },
    );
  }

  Map<String, String> _videoHeaders(String serviceToken, String videoPath) {
    return {
      'Authorization': 'Bearer $serviceToken',
      'Content-Type': _getContentType(videoPath),
    };
  }

  Stream<List<int>> _trackUploadProgress(
    Stream<List<int>> chunks, {
    required int totalBytes,
    void Function(double progress)? onUploadProgress,
  }) async* {
    var uploadedBytes = 0;

    await for (final chunk in chunks) {
      uploadedBytes += chunk.length;
      if (totalBytes > 0) {
        onUploadProgress?.call(
          (uploadedBytes / totalBytes).clamp(0, 1).toDouble(),
        );
      }
      yield chunk;
    }

    onUploadProgress?.call(1);
  }

  Future<String> _createServiceAuthToken({
    bool refreshPdsSessionOnFailure = false,
  }) async {
    final atproto = _authRepository.atproto;
    if (atproto == null) {
      throw Exception('AtProto not initialized');
    }

    try {
      return await _requestServiceAuthToken(atproto);
    } catch (error) {
      if (!refreshPdsSessionOnFailure) {
        rethrow;
      }

      _logger.i(
        'Refreshing PDS session before minting video service token',
        error: error,
      );
      final refreshed = await _authRepository.refreshToken();
      if (!refreshed) {
        throw Exception('Session expired. Please log in again.');
      }

      final refreshedAtproto = _authRepository.atproto;
      if (refreshedAtproto == null) {
        throw Exception('AtProto not initialized after refresh');
      }
      return _requestServiceAuthToken(refreshedAtproto);
    }
  }

  Future<String> _requestServiceAuthToken(PoptartClient atproto) async {
    final requestOverride = _serviceAuthTokenRequest;
    if (requestOverride != null) {
      return requestOverride(atproto);
    }
    final response = await atproto.call(
      server_get_service_auth.comAtprotoServerGetServiceAuth,
      parameters: server_get_service_auth.ServerGetServiceAuthInput(
        aud: 'did:web:${atproto.service}',
        lxm: 'com.atproto.repo.uploadBlob',
        exp:
            _now()
                .toUtc()
                .add(const Duration(minutes: 5))
                .millisecondsSinceEpoch ~/
            1000,
      ),
    );

    return response.data.token;
  }

  bool _isExpiredTokenResponse(http.Response response) {
    if (response.statusCode != 401) {
      return false;
    }

    final body = response.body.toLowerCase();
    return body.contains('jwt has expired') || body.contains('invalidtoken');
  }

  String _getContentType(String videoPath) {
    return switch (path.extension(videoPath).toLowerCase()) {
      '.mov' => 'video/quicktime',
      '.avi' => 'video/x-msvideo',
      '.webm' => 'video/webm',
      _ => 'video/mp4',
    };
  }

  String _buildFailureMessage({required String fallback, dynamic detail}) {
    final normalizedDetail = _extractFailureDetail(detail);
    if (normalizedDetail == null) {
      return fallback;
    }

    final normalizedFallback = fallback.trim();
    if (normalizedDetail.toLowerCase() == normalizedFallback.toLowerCase()) {
      return normalizedFallback;
    }
    if (normalizedDetail.toLowerCase().startsWith(
      normalizedFallback.toLowerCase(),
    )) {
      return normalizedDetail;
    }

    final separator = normalizedFallback.endsWith('.') ? ' ' : ': ';
    return '$normalizedFallback$separator$normalizedDetail';
  }

  String? _extractFailureDetail(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return null;
      }

      try {
        final decodedDetail = _extractFailureDetail(jsonDecode(trimmed));
        if (decodedDetail != null) {
          return decodedDetail;
        }
      } catch (_) {
        // Use the raw response when it is not JSON.
      }

      return _sanitizeFailureText(trimmed);
    }

    if (value is Map) {
      for (final key in const [
        'message',
        'status',
        'detail',
        'reason',
        'description',
        'error',
      ]) {
        final nestedDetail = _extractFailureDetail(value[key]);
        if (nestedDetail != null) {
          return nestedDetail;
        }
      }

      return _extractFailureDetail(value['jobStatus']);
    }

    if (value is Iterable) {
      for (final item in value) {
        final itemDetail = _extractFailureDetail(item);
        if (itemDetail != null) {
          return itemDetail;
        }
      }
      return null;
    }

    return _sanitizeFailureText(value.toString());
  }

  String? _sanitizeFailureText(String text) {
    final sanitized = text
        .replaceFirst(
          RegExp(r'^(exception|error):\s*', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (sanitized.isEmpty ||
        sanitized == '{}' ||
        sanitized == '[]' ||
        sanitized.startsWith('<!DOCTYPE html') ||
        sanitized.startsWith('<html')) {
      return null;
    }

    return sanitized;
  }
}
