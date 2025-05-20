import 'dart:convert';

import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/repositories/actor_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/network/data/models/actor_models.dart';

/// Actor-related API endpoints implementation
class ActorRepositoryImpl implements ActorRepository {
  final SprkRepository _client;
  final _logger = GetIt.instance<LogService>().getLogger('ActorAPI');

  ActorRepositoryImpl(this._client) {
    _logger.v('ActorAPI initialized');
  }

  @override
  Future<ProfileResponse> getProfile(String did) async {
    _logger.d('Getting profile for DID: $did');
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

      final result = await atproto.get(
        NSID.parse('so.sprk.actor.getProfile'),
        parameters: {'actor': did},
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Profile retrieved successfully');
      return ProfileResponse.fromJson(result.data as Map<String, dynamic>);
    });
  }

  @override
  Future<ActorSearchResponse> searchActors(String query) async {
    _logger.d('Searching actors with query: $query');
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

      final result = await atproto.get(
        NSID.parse('so.sprk.actor.searchActors'),
        parameters: {'q': query},
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Actor search completed successfully');
      return ActorSearchResponse.fromJson(result.data as Map<String, dynamic>);
    });
  }
} 