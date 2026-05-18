import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:poptart/poptart.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sound_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:sprk_poptart/so/sprk/sound/audio.dart' as sprk_audio;
import 'package:sprk_poptart/so/sprk/sound/defs/audio_details.dart';
import 'package:sprk_poptart/so/sprk/sound/get_audio_posts.dart'
    as sprk_get_audio_posts;
import 'package:sprk_poptart/so/sprk/sound/get_trending_audios.dart'
    as sprk_get_trending_audios;
import 'package:sprk_poptart/so/sprk/sound/search_audios.dart'
    as sprk_search_audios;

class SoundRepositoryImpl implements SoundRepository {
  SoundRepositoryImpl(this._client) {
    _logger.v('SoundRepository initialized');
  }
  final SprkRepository _client;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'SoundRepository',
  );

  @override
  Future<RepoStrongRef> createSound({
    required Blob sound,
    String? title,
    AudioDetails? details,
  }) async {
    _logger.d('Creating sound record with title: ${title ?? '<none>'}');

    final audioRecord = sprk_audio.SoundAudioRecord(
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
    _logger.d(
      'Getting audio posts for URI: $uri, limit: $limit, cursor: $cursor',
    );
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

      final result = await atproto.call(
        sprk_get_audio_posts.soSprkSoundGetAudioPosts,
        parameters: sprk_get_audio_posts.SoundGetAudioPostsInput(
          uri: uri,
          limit: limit,
          cursor: cursor,
        ),
        headers: {'atproto-proxy': _client.sprkDid},
      );
      final response = AudioPostsResponse.fromJson(result.data.toJson());

      _logger.d(
        'Audio posts retrieved successfully: ${response.posts.length} posts',
      );
      return response;
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

      final parameters = <String, dynamic>{'limit': limit};
      if (cursor != null) {
        parameters['cursor'] = cursor;
      }

      final result = await atproto.call(
        sprk_get_trending_audios.soSprkSoundGetTrendingAudios,
        parameters: sprk_get_trending_audios.SoundGetTrendingAudiosInput(
          limit: limit,
          cursor: cursor,
        ),
        headers: {'atproto-proxy': _client.sprkDid},
      );
      final response = TrendingAudiosResponse.fromJson(result.data.toJson());

      _logger.d(
        'Trending audios retrieved successfully: '
        '${response.audios.length} audios',
      );
      return response;
    });
  }

  @override
  Future<SearchAudiosResponse> searchAudios(
    String query, {
    int limit = 25,
    String? cursor,
  }) async {
    final trimmedQuery = query.trim();
    _logger.d(
      'Searching audios for query: $trimmedQuery, '
      'limit: $limit, cursor: $cursor',
    );

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

      final parameters = <String, dynamic>{'q': trimmedQuery, 'limit': limit};
      if (cursor != null) {
        parameters['cursor'] = cursor;
      }

      final result = await atproto.call(
        sprk_search_audios.soSprkSoundSearchAudios,
        parameters: sprk_search_audios.SoundSearchAudiosInput(
          q: trimmedQuery,
          limit: limit,
          cursor: cursor,
        ),
        headers: {'atproto-proxy': _client.sprkDid},
      );
      final response = SearchAudiosResponse.fromJson(result.data.toJson());

      _logger.d(
        'Audio search retrieved successfully: '
        '${response.audios.length} audios',
      );
      return response;
    });
  }
}
