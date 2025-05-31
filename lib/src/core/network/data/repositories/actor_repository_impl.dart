import 'dart:convert';

import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sparksocial/src/core/network/data/repositories/actor_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/network/data/models/actor_models.dart';
import 'package:atproto/atproto.dart' as atproto;

/// Actor-related API endpoints implementation
class ActorRepositoryImpl implements ActorRepository {
  final SprkRepository _client;
  final _logger = GetIt.instance<LogService>().getLogger('ActorAPI');

  ActorRepositoryImpl(this._client) {
    _logger.v('ActorAPI initialized');
  }

  @override
  Future<ProfileViewDetailed> getProfile(String did) async {
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
      if (result.status != HttpStatus.ok) {
        _logger.e('Failed to retrieve profile for DID: $did');
        throw Exception('Failed to retrieve profile for DID: $did');
      }
      _logger.d('Profile retrieved successfully');
      return ProfileViewDetailed.fromJson(result.data as Map<String, dynamic>);
    });
  }

  @override
  Future<List<ProfileView>> searchActors(String query) async {
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
      return (result.data as List).map((e) => ProfileView.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future<void> updateProfile({required String displayName, required String description, dynamic avatar}) async {
    if (!_client.authRepository.isAuthenticated) {
      throw Exception('Not authenticated');
    }

    final record = <String, dynamic>{
      '\$type': 'so.sprk.actor.profile',
      'displayName': displayName,
      'description': description,
      if (avatar != null) 'avatar': avatar,
    };

    await _client.repo.editRecord(
      uri: AtUri.parse('at://${_client.authRepository.session!.did}/so.sprk.actor.profile/self'),
      record: atproto.Record.fromJson(record),
    );
  }

  @override
  Future<bool> isEarlySupporter(String did) async {
    _logger.d('Checking early supporter status for DID: $did');
    try {
      final response = await http.get(Uri.parse('https://spark-match.sparksplatforms.workers.dev/?did=$did'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool isSupporter = data['found'] == true;
        _logger.d('Early supporter status for $did: $isSupporter');
        return isSupporter;
      }
      _logger.w('Failed to check early supporter status for $did, status code: ${response.statusCode}');
      return false;
    } catch (e, s) {
      _logger.e('Error checking early supporter status for $did', error: e, stackTrace: s);
      return false;
    }
  }
}
