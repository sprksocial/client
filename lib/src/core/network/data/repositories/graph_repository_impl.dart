import 'dart:convert';

import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/repositories/graph_repository.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/network/data/models/graph_models.dart';

/// Implementation of Graph-related API endpoints
class GraphRepositoryImpl implements GraphRepository {
  final SprkRepository _client;
  final _logger = GetIt.instance<LogService>().getLogger('GraphRepository');

  GraphRepositoryImpl(this._client) {
    _logger.v('GraphRepository initialized');
  }

  @override
  Future<FollowersResponse> getFollowers(String did) async {
    _logger.d('Getting followers for DID: $did');
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
        NSID.parse('so.sprk.graph.getFollowers'),
        parameters: {'actor': did},
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Followers retrieved successfully');
      return FollowersResponse.fromJson(result.data as Map<String, dynamic>);
    });
  }

  @override
  Future<FollowsResponse> getFollows(String did) async {
    _logger.d('Getting follows for DID: $did');
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
        NSID.parse('so.sprk.graph.getFollows'),
        parameters: {'actor': did},
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8)),
      );
      _logger.d('Follows retrieved successfully');
      return FollowsResponse.fromJson(result.data as Map<String, dynamic>);
    });
  }
  
  @override
  Future<FollowUserResponse> followUser(String did) async {
    _logger.d('Following user with DID: $did');
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

      // Check if already following
      try {
        _logger.d('Checking if already following user: $did');
        // Query existing follow records
        final existingFollows = await atproto.repo.listRecords(
          repo: _client.authRepository.session!.did,
          collection: NSID.parse('so.sprk.graph.follow'),
        );

        // Check if we're already following this specific user
        for (final record in existingFollows.data.records) {
          if (record.value['subject'] == did) {
            _logger.w('Already following this user: $did');
            throw Exception('Already following this user');
          }
        }

        // If not already following, create new follow record
        final followRecord = {
          "\$type": "so.sprk.graph.follow",
          "subject": did,
          "createdAt": DateTime.now().toUtc().toIso8601String(),
        };

        final result = await atproto.repo.createRecord(
          collection: NSID.parse('so.sprk.graph.follow'),
          record: followRecord
        );
        
        _logger.i('User followed successfully: ${result.data.uri}');
        
        return FollowUserResponse(
          uri: result.data.uri.toString(),
          cid: result.data.cid,
        );
      } catch (e) {
        _logger.e('Error in followUser', error: e);
        rethrow;
      }
    });
  }
  
  @override
  Future<void> unfollowUser(String followUri) async {
    _logger.d('Unfollowing user with follow URI: $followUri');
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

      await atproto.repo.deleteRecord(uri: AtUri.parse(followUri));
      _logger.i('User unfollowed successfully');
    });
  }
} 