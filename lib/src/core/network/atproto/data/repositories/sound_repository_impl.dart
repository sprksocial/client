import 'dart:convert';

import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sound_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';

class SoundRepositoryImpl implements SoundRepository {
  SoundRepositoryImpl(this._client) {
    _logger.v('SoundRepository initialized');
  }
  final SprkRepository _client;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger('SoundRepository');

  @override
  Future<RepoStrongRef> createSound({
    required Blob sound,
    required String title,
    AudioDetails? details,
  }) async {
    _logger.d('Creating sound record with title: $title');

    final audioRecord = AudioRecord(
      sound: sound,
      title: title,
      createdAt: DateTime.now().toUtc(),
      details: details,
    );

    final result = await _client.repo.createRecord(
      collection: 'so.sprk.sound.audio',
      record: audioRecord.toJson(),
    );

    _logger.i('Sound record created successfully: ${result.uri}');
    return result;
  }

  @override
  Future<AudioPostsResponse> getAudioPosts(
    AtUri uri, {
    int limit = 50,
    String? cursor,
  }) async {
    _logger.d('Getting audio posts for URI: $uri, limit: $limit, cursor: $cursor');
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final parameters = <String, dynamic>{
        'uri': uri.toString(),
        'limit': limit,
      };
      if (cursor != null) {
        parameters['cursor'] = cursor;
      }

      final result = await atproto.get(
        NSID.parse('so.sprk.sound.getAudioPosts'),
        parameters: parameters,
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) {
          return AudioPostsResponse.fromJson(jsonMap);
        },
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
      );

      _logger.d('Audio posts retrieved successfully: ${result.data.posts.length} posts');
      return result.data;
    });
  }

  @override
  Future<TrendingAudiosResponse> getTrendingAudios({
    int limit = 50,
    String? cursor,
  }) async {
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final parameters = <String, dynamic>{
        'limit': limit,
      };
      if (cursor != null) {
        parameters['cursor'] = cursor;
      }

      final result = await atproto.get(
        NSID.parse('so.sprk.sound.getTrendingAudios'),
        parameters: parameters,
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) {
          return TrendingAudiosResponse.fromJson(jsonMap);
        },
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
      );

      _logger.d('Trending audios retrieved successfully: ${result.data.audios.length} audios');
      return result.data;
    });
  }
}
