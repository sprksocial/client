import 'package:bluesky_poptart/app/bsky/graph/follow.dart' as bsky_follow;
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/repo/list_records.dart'
    as repo_list_records;
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/network/atproto/data/repositories/graph_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:sprk_poptart/so/sprk/graph/block.dart' as sprk_block;
import 'package:sprk_poptart/so/sprk/graph/follow.dart' as sprk_follow;
import 'package:sprk_poptart/so/sprk/graph/get_blocks.dart' as sprk_get_blocks;
import 'package:sprk_poptart/so/sprk/graph/get_followers.dart'
    as sprk_get_followers;
import 'package:sprk_poptart/so/sprk/graph/get_follows.dart'
    as sprk_get_follows;
import 'package:sprk_poptart/so/sprk/graph/get_known_followers.dart'
    as sprk_get_known_followers;

/// Implementation of Graph-related API endpoints
class GraphRepositoryImpl implements GraphRepository {
  GraphRepositoryImpl(
    this._client, {
    SparkLogger? logger,
    DateTime Function()? now,
  }) : _logger =
           logger ?? GetIt.instance<LogService>().getLogger('GraphRepository'),
       _now = now ?? DateTime.now {
    _logger.v('GraphRepository initialized');
  }
  final SprkRepository _client;
  final SparkLogger _logger;
  final DateTime Function() _now;

  @override
  Future<sprk_get_followers.GraphGetFollowersOutput> getFollowers(
    String did, {
    String? cursor,
  }) async {
    _logger.d('Getting followers for DID: $did with cursor: $cursor');
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
        final params = <String, dynamic>{'actor': did};
        if (cursor != null) {
          params['cursor'] = cursor;
        }
        final result = await atproto.call(
          sprk_get_followers.soSprkGraphGetFollowers,
          parameters: sprk_get_followers.GraphGetFollowersInput(
            actor: did,
            cursor: cursor,
          ),
          headers: _client.appViewHeaders(_client.sprkDid),
        );
        _logger.d('Followers retrieved successfully');
        return result.data;
      } on FormatException catch (fe) {
        _logger.e('Error retrieving followers for DID: $did', error: fe);
        throw Exception('Failed to retrieve followers for DID: $did');
      }
    });
  }

  @override
  Future<sprk_get_known_followers.GraphGetKnownFollowersOutput>
  getKnownFollowers(String did, {String? cursor}) async {
    _logger.d('Getting known followers for DID: $did with cursor: $cursor');
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
        final params = <String, dynamic>{'actor': did};
        if (cursor != null) {
          params['cursor'] = cursor;
        }
        final result = await atproto.call(
          sprk_get_known_followers.soSprkGraphGetKnownFollowers,
          parameters: sprk_get_known_followers.GraphGetKnownFollowersInput(
            actor: did,
            cursor: cursor,
          ),
          headers: _client.appViewHeaders(_client.sprkDid),
        );
        _logger.d('Known followers retrieved successfully');
        return result.data;
      } on FormatException catch (fe) {
        _logger.e('Error retrieving known followers for DID: $did', error: fe);
        throw Exception('Failed to retrieve known followers for DID: $did');
      }
    });
  }

  @override
  Future<sprk_get_follows.GraphGetFollowsOutput> getFollows(
    String did, {
    String? cursor,
  }) async {
    _logger.d('Getting follows for DID: $did with cursor: $cursor');
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
        final params = <String, dynamic>{'actor': did};
        if (cursor != null) {
          params['cursor'] = cursor;
        }
        final result = await atproto.call(
          sprk_get_follows.soSprkGraphGetFollows,
          parameters: sprk_get_follows.GraphGetFollowsInput(
            actor: did,
            cursor: cursor,
          ),
          headers: _client.appViewHeaders(_client.sprkDid),
        );
        _logger.d('Follows retrieved successfully');
        return result.data;
      } on FormatException catch (fe) {
        _logger.e('Error retrieving follows for DID: $did', error: fe);
        throw Exception('Failed to retrieve follows for DID: $did');
      }
    });
  }

  @override
  Future<RepoStrongRef> followUser(String did, {bool bsky = false}) async {
    _logger.d('Following user with DID: $did, bsky: $bsky');
    return _client.executeWithRetry(() async {
      final context = _followWriteContext(bsky);

      try {
        _logger.d('Checking if already following user: $did');
        final existingFollow = (await _findExistingFollows(
          atproto: context.atproto,
          repo: context.sessionDid,
          collection: context.collection,
          subjects: {did},
        ))[did];

        if (existingFollow != null) {
          _logger.w('Already following this user: $did');
          throw Exception('Already following this user');
        }

        final result = await _createFollow(
          did,
          bsky: bsky,
          collection: context.collection,
          sessionDid: context.sessionDid,
        );

        _logger.i(
          'User followed successfully with ${context.collection}: '
          '${result.uri}',
        );

        return result;
      } catch (e) {
        _logger.e('Error in followUser', error: e);
        rethrow;
      }
    });
  }

  @override
  Future<void> ensureFollowingBatch(
    Iterable<String> dids, {
    bool bsky = false,
  }) {
    final requestedDids = dids.toSet();
    if (requestedDids.isEmpty) return Future<void>.value();

    _logger.d(
      'Ensuring ${requestedDids.length} follow relationships, bsky: $bsky',
    );
    return _client.executeWithRetry(() async {
      final context = _followWriteContext(bsky);
      final existingFollows = await _findExistingFollows(
        atproto: context.atproto,
        repo: context.sessionDid,
        collection: context.collection,
        subjects: requestedDids,
      );
      final ensuredDids = <String>{};

      for (final did in requestedDids) {
        if (existingFollows.containsKey(did)) {
          ensuredDids.add(did);
          continue;
        }

        try {
          await _createFollow(
            did,
            bsky: bsky,
            collection: context.collection,
            sessionDid: context.sessionDid,
          );
          ensuredDids.add(did);
        } catch (error, stackTrace) {
          Error.throwWithStackTrace(
            EnsureFollowingBatchException(
              ensuredDids: Set.unmodifiable(ensuredDids),
              failedDid: did,
              cause: error,
            ),
            stackTrace,
          );
        }
      }
    });
  }

  ({PoptartClient atproto, String sessionDid, String collection})
  _followWriteContext(bool bsky) {
    if (!_client.authRepository.isAuthenticated) {
      _logger.w('Not authenticated');
      throw Exception('Not authenticated');
    }

    final atproto = _client.authRepository.atproto;
    if (atproto == null) {
      _logger.e('AtProto not initialized');
      throw Exception('AtProto not initialized');
    }

    final sessionDid = _client.authRepository.did;
    if (sessionDid == null) {
      _logger.e('Session DID not available for authenticated user');
      throw Exception('Session DID not available');
    }

    return (
      atproto: atproto,
      sessionDid: sessionDid,
      collection: bsky ? 'app.bsky.graph.follow' : 'so.sprk.graph.follow',
    );
  }

  Future<RepoStrongRef> _createFollow(
    String did, {
    required bool bsky,
    required String collection,
    required String sessionDid,
  }) {
    final createdAt = _now().toUtc();
    final followRecord = bsky
        ? bsky_follow.GraphFollowRecord(
            subject: did,
            createdAt: createdAt,
          ).toJson()
        : sprk_follow.GraphFollowRecord(
            subject: did,
            createdAt: createdAt,
          ).toJson();

    return _client.repo.createRecord(
      collection: collection,
      record: followRecord,
      repo: sessionDid,
    );
  }

  Future<Map<String, RepoStrongRef>> _findExistingFollows({
    required PoptartClient atproto,
    required String repo,
    required String collection,
    required Set<String> subjects,
  }) async {
    final matches = <String, RepoStrongRef>{};
    final remainingSubjects = {...subjects};
    if (remainingSubjects.isEmpty) return matches;

    final seenCursors = <String>{};
    String? cursor;

    do {
      final response = await atproto.call(
        repo_list_records.comAtprotoRepoListRecords,
        parameters: repo_list_records.RepoListRecordsInput(
          repo: repo,
          collection: collection,
          cursor: cursor,
          limit: 100,
        ),
      );
      for (final record in response.data.records) {
        final subject = record.value['subject'];
        if (subject is! String || !remainingSubjects.remove(subject)) continue;
        matches[subject] = RepoStrongRef(uri: record.uri, cid: record.cid);
      }
      if (remainingSubjects.isEmpty) return matches;

      cursor = response.data.cursor;
      if (cursor != null && !seenCursors.add(cursor)) {
        throw StateError('Follow lookup returned a repeated cursor');
      }
    } while (cursor != null);

    return matches;
  }

  @override
  Future<void> unfollowUser(AtUri followUri) async {
    _logger.d('Unfollowing user with follow URI: $followUri');
    return _client.executeWithRetry(() async {
      await _client.repo.deleteRecord(
        uri: followUri,
        skipBskyCrosspostCleanup: true,
      );
      _logger.i('User unfollowed successfully');
    });
  }

  @override
  Future<sprk_get_blocks.GraphGetBlocksOutput> getBlocks(
    String did, {
    String? cursor,
  }) async {
    _logger.d('Getting blocks for DID: $did with cursor: $cursor');
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
        final params = <String, dynamic>{'actor': did};
        if (cursor != null) {
          params['cursor'] = cursor;
        }
        final result = await atproto.call(
          sprk_get_blocks.soSprkGraphGetBlocks,
          parameters: sprk_get_blocks.GraphGetBlocksInput(cursor: cursor),
          headers: _client.appViewHeaders(_client.sprkDid),
        );
        _logger.d('Blocks retrieved successfully');
        return result.data;
      } on FormatException catch (fe) {
        _logger.e('Error retrieving blocks for DID: $did', error: fe);
        throw Exception('Failed to retrieve blocks for DID: $did');
      }
    });
  }

  @override
  Future<RepoStrongRef> blockUser(String did) async {
    _logger.d('Blocking user with DID: $did');
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

      final sessionDid = _client.authRepository.did;
      if (sessionDid == null) {
        _logger.e('Session DID not available for authenticated user');
        throw Exception('Session DID not available');
      }

      const collection = 'so.sprk.graph.block';

      try {
        _logger.d('Checking if already blocking user: $did');
        final existingBlocks = await atproto.call(
          repo_list_records.comAtprotoRepoListRecords,
          parameters: repo_list_records.RepoListRecordsInput(
            repo: sessionDid,
            collection: collection,
          ),
        );

        final isAlreadyBlocking = existingBlocks.data.records.any(
          (record) => record.value['subject'] == did,
        );

        if (isAlreadyBlocking) {
          _logger.w('Already blocking this user: $did');
          throw Exception('Already blocking this user');
        }

        final blockRecord = sprk_block.GraphBlockRecord(
          subject: did,
          createdAt: _now().toUtc(),
        ).toJson();

        final result = await _client.repo.createRecord(
          collection: collection,
          record: blockRecord,
          repo: sessionDid,
        );

        _logger.i('User blocked successfully with $collection: ${result.uri}');

        return result;
      } catch (e) {
        _logger.e('Error in blockUser', error: e);
        rethrow;
      }
    });
  }

  @override
  Future<void> unblockUser(AtUri blockUri) async {
    _logger.d('Unblocking user with block URI: $blockUri');
    return _client.executeWithRetry(() async {
      await _client.repo.deleteRecord(
        uri: blockUri,
        skipBskyCrosspostCleanup: true,
      );
      _logger.i('User unblocked successfully');
    });
  }

  @override
  Future<String?> toggleBlock(String did, AtUri? currentBlockUri) async {
    _logger.d('Toggling block for DID: $did, current URI: $currentBlockUri');
    return _client.executeWithRetry(() async {
      if (currentBlockUri != null) {
        // User is blocking, so unblock
        await unblockUser(currentBlockUri);
        _logger.i('User unblocked via toggle');
        return null;
      } else {
        // User is not blocking, so block
        final response = await blockUser(did);
        _logger.i('User blocked via toggle: ${response.uri}');
        return response.uri.toString();
      }
    });
  }
}
