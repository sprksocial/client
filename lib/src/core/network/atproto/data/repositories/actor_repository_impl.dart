import 'dart:convert';

import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/repo/put_record.dart'
    as repo_put_record;

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:spark/src/core/config/app_config.dart';
import 'package:spark/src/core/network/atproto/data/adapters/bsky/actor_adapter.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:sprk_poptart/so/sprk/actor/defs.dart';
import 'package:sprk_poptart/so/sprk/actor/get_profile.dart'
    as sprk_get_profile;
import 'package:sprk_poptart/so/sprk/actor/get_profiles.dart'
    as sprk_get_profiles;
import 'package:sprk_poptart/so/sprk/actor/profile.dart' as sprk_profile;
import 'package:sprk_poptart/so/sprk/actor/search_actors.dart';
import 'package:sprk_poptart/so/sprk/actor/search_actors_typeahead.dart';

/// Actor-related API endpoints implementation
class ActorRepositoryImpl implements ActorRepository {
  ActorRepositoryImpl(this._client, {SparkLogger? logger})
    : _logger = logger ?? GetIt.instance<LogService>().getLogger('ActorAPI') {
    _logger.v('ActorAPI initialized');
  }
  final SprkRepository _client;
  final SparkLogger _logger;

  @override
  Future<ProfileViewDetailed> getProfile(
    String did, {
    bool useBluesky = false,
  }) async {
    _logger.d('Getting profile for DID: $did, useBluesky: $useBluesky');
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

      // Use Bluesky API if explicitly requested
      if (useBluesky) {
        final oauthSession = atproto.oAuthSession;
        if (oauthSession == null) {
          throw Exception('No OAuth session available');
        }
        final blueskyClient = PoptartClient.fromOAuthSession(oauthSession);
        final profile = await bskyActorAdapter.getProfileFromBluesky(
          blueskyClient,
          did,
        );
        _logger.d('Profile retrieved successfully from Bluesky');
        return profile;
      }

      // Use Spark API (no fallback)
      final result = await atproto.call(
        sprk_get_profile.soSprkActorGetProfile,
        parameters: sprk_get_profile.ActorGetProfileInput(actor: did),
        headers: {'atproto-proxy': _client.sprkDid},
      );
      _logger.d('Profile retrieved successfully from Spark');
      return result.data;
    });
  }

  @override
  Future<ActorSearchActorsOutput> searchActors(
    String query, {
    String? cursor,
  }) async {
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

      final result = await atproto.call(
        soSprkActorSearchActors,
        parameters: ActorSearchActorsInput(q: query, cursor: cursor),
        headers: {'atproto-proxy': _client.sprkDid},
      );

      _logger.d('Actor search completed successfully');
      return result.data;
    });
  }

  @override
  Future<ActorSearchActorsTypeaheadOutput> searchActorsTypeahead(
    String query, {
    int limit = 10,
  }) async {
    _logger.d('Searching actor typeahead with query: $query, limit: $limit');
    return _client.executeWithRetry(() async {
      final clampedLimit = limit.clamp(1, 100);
      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        return _searchActorsTypeaheadFromAppView(query, limit: clampedLimit);
      }

      final result = await atproto.call(
        soSprkActorSearchActorsTypeahead,
        parameters: ActorSearchActorsTypeaheadInput(
          q: query,
          limit: clampedLimit,
        ),
        headers: {'atproto-proxy': _client.sprkDid},
      );

      _logger.d('Actor typeahead search completed successfully');

      return result.data;
    });
  }

  Future<ActorSearchActorsTypeaheadOutput> _searchActorsTypeaheadFromAppView(
    String query, {
    required int limit,
  }) async {
    final baseUri = Uri.parse(AppConfig.appViewUrl);
    final client = XRPCClient(
      protocol: baseUri.scheme == 'http' ? Protocol.http : Protocol.https,
      service: baseUri.hasPort
          ? '${baseUri.host}:${baseUri.port}'
          : baseUri.host,
    );

    final response = await client.call(
      soSprkActorSearchActorsTypeahead,
      parameters: ActorSearchActorsTypeaheadInput(q: query, limit: limit),
    );

    return response.data;
  }

  @override
  Future<void> updateProfile({
    required String displayName,
    required String description,
    Blob? avatar,
  }) async {
    if (!_client.authRepository.isAuthenticated) {
      throw Exception('Not authenticated');
    }

    final record = sprk_profile.ActorProfileRecord(
      displayName: displayName,
      description: description,
      avatar: avatar,
    );

    final atproto = _client.authRepository.atproto;
    if (atproto == null) {
      throw Exception('AtProto not initialized');
    }

    final did = _client.authRepository.did;
    if (did == null) {
      throw Exception('User DID not available');
    }

    await atproto.call(
      repo_put_record.comAtprotoRepoPutRecord,
      input: repo_put_record.RepoPutRecordInput(
        repo: did,
        collection: 'so.sprk.actor.profile',
        rkey: 'self',
        record: record.toJson(),
      ),
    );
  }

  @override
  Future<bool> isEarlySupporter(String did) async {
    _logger.d('Checking early supporter status for DID: $did');
    try {
      final response = await http.get(
        Uri.parse('https://early-supporters.sprk.so/?did=$did'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isSupporter = data['found'] == true;
        _logger.d('Early supporter status for $did: $isSupporter');
        return isSupporter;
      }
      _logger.w(
        'Failed to check early supporter status for $did, status code: '
        '${response.statusCode}',
      );
      return false;
    } catch (e, s) {
      _logger.e(
        'Error checking early supporter status for $did',
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }

  @override
  Future<List<ProfileViewDetailed>> getProfiles(
    List<String> dids, {
    bool useBluesky = false,
  }) {
    return _client.executeWithRetry(() async {
      _logger.d('Getting profiles for DIDs: $dids, useBluesky: $useBluesky');
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

      // Use Bluesky API if explicitly requested
      if (useBluesky) {
        final oauthSession = atproto.oAuthSession;
        if (oauthSession == null) {
          throw Exception('No OAuth session available');
        }
        final blueskyClient = PoptartClient.fromOAuthSession(oauthSession);
        final profiles = await bskyActorAdapter.getProfilesFromBluesky(
          blueskyClient,
          dids,
        );
        _logger.d('Profiles retrieved successfully from Bluesky');
        return profiles;
      }

      // Use Spark API (no fallback)
      final result = await atproto.call(
        sprk_get_profiles.soSprkActorGetProfiles,
        parameters: sprk_get_profiles.ActorGetProfilesInput(actors: dids),
        headers: {'atproto-proxy': _client.sprkDid},
      );
      _logger.d('Profiles retrieved successfully from Spark');
      return result.data.profiles;
    });
  }
}
