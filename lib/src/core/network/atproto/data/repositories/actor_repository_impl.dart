import 'dart:convert';

import 'package:atproto/core.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sparksocial/src/core/network/atproto/data/models/models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';

/// Actor-related API endpoints implementation
class ActorRepositoryImpl implements ActorRepository {
  ActorRepositoryImpl(this._client) {
    _logger.v('ActorAPI initialized');
  }
  final SprkRepository _client;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger('ActorAPI');

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
      try {
        final result = await atproto.get(
          NSID.parse('so.sprk.actor.getProfile'),
          parameters: {'actor': did},
          headers: {'atproto-proxy': _client.sprkDid},
          to: (jsonMap) => jsonMap,
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
        );
        return ProfileViewDetailed.fromJson(result.data as Map<String, dynamic>);
      } catch (e) {
        _logger
          ..e('Failed to retrieve profile for DID: $did', error: e)
          ..i('Trying to get profile from bluesky');
        final bluesky = bsky.Bluesky.fromSession(_client.authRepository.session!);
        final profile = await bluesky.actor.getProfile(actor: did);
        _logger.d('Profile retrieved successfully from bluesky');
        return ProfileViewDetailed.fromJson(profile.toJson());
      }
    });
  }

  @override
  Future<SearchActorsResponse> searchActors(String query, {String? cursor}) async {
    _logger.d('Searching actors with query: $query, cursor: $cursor');
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

      final parameters = <String, String>{'q': query};
      if (cursor != null && cursor.isNotEmpty) {
        parameters['cursor'] = cursor;
      }

      final result = await atproto.get(
        NSID.parse('so.sprk.actor.searchActors'),
        parameters: parameters,
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
      );

      _logger.d('Actor search completed successfully');

      final data = result.data as Map<String, dynamic>;
      final actorsJson = (data['actors'] as List? ?? []).cast<dynamic>();
      final cursorNext = data['cursor'] as String?;

      final actors = actorsJson.map((e) => ProfileView.fromJson(e as Map<String, dynamic>)).toList();

      return SearchActorsResponse(actors: actors, cursor: cursorNext);
    });
  }

  @override
  Future<void> updateProfile({required String displayName, required String description, Blob? avatar}) async {
    if (!_client.authRepository.isAuthenticated) {
      throw Exception('Not authenticated');
    }

    final record = ProfileRecord(displayName: displayName, description: description, avatar: avatar);

    final atproto = _client.authRepository.atproto;
    if (atproto == null) {
      throw Exception('AtProto not initialized');
    }

    await atproto.repo.putRecord(
      uri: AtUri.parse('at://${_client.authRepository.session!.did}/so.sprk.actor.profile/self'),
      record: record.toJson(),
    );
  }

  @override
  Future<bool> isEarlySupporter(String did) async {
    _logger.d('Checking early supporter status for DID: $did');
    try {
      final response = await http.get(Uri.parse('https://spark-match.sparksplatforms.workers.dev/?did=$did'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isSupporter = data['found'] == true;
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

  @override
  Future<List<ProfileViewDetailed>> getProfiles(List<String> dids) {
    return _client.executeWithRetry(() async {
      _logger.d('Getting profiles for DIDs: $dids');
      if (dids.isEmpty) {
        _logger.w('No DIDs provided, returning empty list');
        return <ProfileViewDetailed>[];
      }
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }
      try {
        final result = await atproto.get(
          NSID.parse('so.sprk.actor.getProfiles'),
          parameters: {'actors': dids},
          headers: {'atproto-proxy': _client.sprkDid},
          to: (jsonMap) => jsonMap,
          adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
        );
        return (result.data['profiles']! as List)
            .map((json) => ProfileViewDetailed.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _logger
          ..e('Failed to retrieve profile for DIDs: $dids', error: e)
          ..i('Trying to get profiles from bluesky');
        final bluesky = bsky.Bluesky.fromSession(_client.authRepository.session!);
        final profiles = await bluesky.actor.getProfiles(actors: dids);
        _logger.d('Profiles retrieved successfully from bluesky');
        return profiles.data.profiles.map((p) => ProfileViewDetailed.fromJson(p.toJson())).toList();
      }
    });
  }
}
