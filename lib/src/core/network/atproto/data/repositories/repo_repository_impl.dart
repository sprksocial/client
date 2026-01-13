import 'dart:typed_data';

import 'package:atproto/com_atproto_moderation_createreport.dart';
import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto/com_atproto_services.dart';
import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/network/atproto/data/adapters/bsky/repo_adapter.dart';
import 'package:spark/src/core/network/atproto/data/models/record_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/repo_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository_impl.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

/// Repository-related API endpoints implementation
class RepoRepositoryImpl implements RepoRepository {
  RepoRepositoryImpl(this._client) {
    _logger.v('RepoAPI initialized');
  }
  final SprkRepositoryImpl _client;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger('RepoAPI');

  @override
  Future<({Record record, RepoStrongRef strongRef})> getRecord({
    required AtUri uri,
  }) async {
    _logger.d('Getting record for URI: $uri');
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
      final result = await atproto.repo.getRecord(
        repo: uri.hostname,
        collection: uri.collection.toString(),
        rkey: uri.rkey,
      );
      _logger.d('Record retrieved successfully');
      return (
        record: Record.fromJson(result.data.value),
        strongRef: RepoStrongRef(
          uri: result.data.uri,
          cid: result.data.cid ?? '',
        ),
      );
    });
  }

  @override
  Future<RepoStrongRef> editRecord({
    required AtUri uri,
    required Record record,
  }) async {
    _logger.d('Editing record at URI: $uri');
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
      final result = await atproto.repo.putRecord(
        repo: uri.hostname,
        collection: uri.collection.toString(),
        rkey: uri.rkey,
        record: record.toJson(),
      );
      _logger.d('Record edited successfully');
      return RepoStrongRef(uri: result.data.uri, cid: result.data.cid);
    });
  }

  @override
  Future<RepoStrongRef> createRecord({
    required String collection,
    required Map<String, dynamic> record,
    String? rkey,
    String? repo,
  }) async {
    _logger.d('Creating record in collection: $collection');
    return _client.executeWithRetry(() async {
      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      // Use provided repo DID or fall back to session DID
      final repoDid = repo ?? _client.authRepository.did;
      if (repoDid == null) {
        _logger.e('User session DID not available');
        throw Exception('User session DID not available');
      }

      final result = await atproto.repo.createRecord(
        repo: repoDid,
        collection: collection,
        record: record,
        rkey: rkey,
      );
      _logger.d('Record created successfully');
      return RepoStrongRef(uri: result.data.uri, cid: result.data.cid);
    });
  }

  @override
  Future<void> deleteRecord({
    required AtUri uri,
    bool skipBskyCrosspostCleanup = false,
  }) async {
    _logger.d('Deleting record at URI: $uri');
    return _client.executeWithRetry(() async {
      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      await atproto.repo.deleteRecord(
        repo: uri.hostname,
        collection: uri.collection.toString(),
        rkey: uri.rkey,
      );
      _logger.d('Record deleted successfully');

      // Delete cross-posted Bluesky counterpart if it exists (only for posts)
      if (!skipBskyCrosspostCleanup) {
        final blueskyUri = bskyRepoAdapter.buildBlueskyCounterpartUri(uri);
        _logger.d('Attempting to delete Bluesky counterpart post: $blueskyUri');

        final deleted = await bskyRepoAdapter.deleteBlueskyCounterpart(
          ({required repo, required collection, required rkey}) => atproto.repo
              .deleteRecord(repo: repo, collection: collection, rkey: rkey),
          uri,
        );

        if (deleted) {
          _logger.d('Bluesky counterpart post deleted successfully');
        } else {
          _logger.w('Bluesky counterpart post not found or deletion failed');
        }
      }
    });
  }

  @override
  Future<Blob> uploadBlob(Uint8List data) async {
    _logger.d('Uploading blob of size: ${data.length} bytes');
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

      final result = await atproto.repo.uploadBlob(bytes: data);
      _logger.d('Blob uploaded successfully');

      return result.data.blob;
    });
  }

  @override
  Future<List<Record>> listRecords({
    required String repo,
    required String collection,
    String? cursor,
    int? limit,
    bool? reverse,
  }) async {
    _logger.d('Listing records in repo: $repo, collection: $collection');
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

      final result = await atproto.repo.listRecords(
        repo: repo,
        collection: collection,
        cursor: cursor,
        limit: limit,
        reverse: reverse,
      );

      _logger.d('Records listed successfully');

      final records = result.data.records
          .map((record) => Record.fromJson(record.value))
          .toList();

      return records;
    });
  }

  @override
  Future<bool> createReport({
    required ModerationCreateReportInput input,
    ModerationService? service,
  }) async {
    _logger.i('Creating moderation report for reason: ${input.reasonType}');

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null || atproto.oAuthSession == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      } else if (service != null) {
        _logger.d('Using provided moderation service');
        try {
          final report = await service.createReport(
            subject: input.subject,
            reasonType: input.reasonType,
            reason: input.reason,
          );
          return report.status.code == 200;
        } catch (e) {
          _logger.e('Error creating report with service', error: e);
          throw Exception('Failed to create report: $e');
        }
      } else {
        _logger.d('Using direct API call for moderation report');
        final endpoint = NSID.parse('com.atproto.moderation.createReport');
        final subjectData = input.subject.data;

        Map<String, dynamic> body;

        if (subjectData is RepoStrongRef) {
          body = {
            'subject': {
              r'$type': 'com.atproto.repo.strongRef',
              'uri': subjectData.uri.toString(),
              'cid': subjectData.cid,
            },
            'reasonType': input.reasonType.toJson(),
          };
        } else {
          _logger.e('Invalid subject data type: ${subjectData.runtimeType}');
          throw Exception('Invalid subject data');
        }

        if (input.reason != null) {
          body['reason'] = input.reason;
        }

        // Send to Spark's Mod service
        final headers = {
          'Authorization': 'Bearer ${atproto.session!.accessJwt}',
          'Content-Type': 'application/json',
          'atproto-proxy': _client.modDid,
        };

        try {
          final response = await atproto.post(
            endpoint,
            headers: headers,
            body: body,
          );

          if (response.status != HttpStatus.ok) {
            _logger.e(
              'Failed to create report: ${response.data}',
              error: 'HTTP ${response.status}',
            );
            throw Exception('Failed to create report: ${response.data}');
          }

          _logger.i('Report created successfully');
          return true;
        } catch (e) {
          _logger.e('Error creating report', error: e);
          throw Exception('Failed to create report: $e');
        }
      }
    });
  }
}
