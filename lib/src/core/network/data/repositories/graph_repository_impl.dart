import 'dart:convert';

import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/data/repositories/graph_repository.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/storage/preferences/settings_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/network/data/models/graph_models.dart';
import 'package:sparksocial/src/features/settings/ui/pages/profile_settings_page.dart';

/// Implementation of Graph-related API endpoints
class GraphRepositoryImpl implements GraphRepository {
  final SprkRepository _client;
  late final SettingsRepository _settingsRepository;
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

      final sessionDid = _client.authRepository.session?.did;
      if (sessionDid == null) {
        _logger.e('Session DID not available for authenticated user');
        throw Exception('Session DID not available');
      }
      _settingsRepository = GetIt.instance<SettingsRepository>();

      final followMode = await _settingsRepository.getFollowMode();
      _logger.d('Using follow mode: $followMode');

      final collection = followMode == FollowMode.sprk ? NSID.parse('so.sprk.graph.follow') : NSID.parse('app.bsky.graph.follow');
      final recordType = followMode == FollowMode.sprk ? 'so.sprk.graph.follow' : 'app.bsky.graph.follow';

      try {
        _logger.d('Checking if already following user: $did');
        final existingFollows = await atproto.repo.listRecords(repo: sessionDid, collection: collection);

        final isAlreadyFollowing = existingFollows.data.records.any((record) => record.value['subject'] == did);

        if (isAlreadyFollowing) {
          _logger.w('Already following this user: $did');
          throw Exception('Already following this user');
        }

        final followRecord = {"\$type": recordType, "subject": did, "createdAt": DateTime.now().toUtc().toIso8601String()};

        final result = await atproto.repo.createRecord(collection: collection, record: followRecord);

        _logger.i('User followed successfully with $recordType: ${result.data.uri}');

        return FollowUserResponse(uri: result.data.uri.toString(), cid: result.data.cid);
      } catch (e) {
        _logger.e('Error in followUser', error: e);
        rethrow;
      }
    });
  }

  @override
  Future<void> unfollowUser(AtUri followUri) async {
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

      await atproto.repo.deleteRecord(uri: followUri);
      _logger.i('User unfollowed successfully');
    });
  }

  @override
  Future<String?> toggleFollow(String did, AtUri? currentFollowUri) async {
    _logger.d('Toggling follow for DID: $did, current URI: $currentFollowUri');
    return _client.executeWithRetry(() async {
      if (currentFollowUri != null) {
        // User is following, so unfollow
        await unfollowUser(currentFollowUri);
        _logger.i('User unfollowed via toggle');
        return null;
      } else {
        // User is not following, so follow
        final response = await followUser(did);
        _logger.i('User followed via toggle: ${response.uri}');
        return response.uri;
      }
    });
  }
}
