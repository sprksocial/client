import 'dart:typed_data';
import 'dart:convert';

import 'package:atproto/core.dart';
import 'package:atproto/atproto.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sparksocial/src/core/network/atproto/data/repositories/repo_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository_impl.dart';

/// Repository-related API endpoints implementation
class RepoRepositoryImpl implements RepoRepository {
  final SprkRepositoryImpl _client;
  final _logger = GetIt.instance<LogService>().getLogger('RepoAPI');

  RepoRepositoryImpl(this._client) {
    _logger.v('RepoAPI initialized');
  }

  @override
  Future<({Record record, StrongRef strongRef})> getRecord({required AtUri uri}) async {
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
      final result = await atproto.repo.getRecord(uri: uri);
      _logger.d('Record retrieved successfully');
      return (record: result.data, strongRef: StrongRef(uri: result.data.uri, cid: result.data.cid ?? ''));
    });
  }

  @override
  Future<StrongRef> editRecord({required AtUri uri, required Record record}) async {
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
      final result = await atproto.repo.putRecord(uri: uri, record: record.toJson());
      _logger.d('Record edited successfully');
      return StrongRef(uri: result.data.uri, cid: result.data.cid);
    });
  }

  @override
  Future<StrongRef> createRecord({required NSID collection, required Map<String, dynamic> record, String? rkey}) async {
    _logger.d('Creating record in collection: $collection');
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

      final result = await atproto.repo.createRecord(collection: collection, record: record, rkey: rkey);
      _logger.d('Record created successfully');
      return StrongRef(uri: result.data.uri, cid: result.data.cid);
    });
  }

  @override
  Future<void> deleteRecord({required AtUri uri}) async {
    _logger.d('Deleting record at URI: $uri');
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

      await atproto.repo.deleteRecord(uri: uri);
      _logger.d('Record deleted successfully');

      // Delete cross-posted Bluesky counterpart if it exists
      try {
        final String did = uri.hostname;
        final String rkey = uri.rkey;
        final AtUri blueskyUri = AtUri.parse('at://$did/app.bsky.feed.post/$rkey');

        _logger.d('Attempting to delete Bluesky counterpart post: $blueskyUri');

        try {
          await atproto.repo.deleteRecord(uri: blueskyUri);
          _logger.d('Bluesky counterpart post deleted successfully');
        } catch (e) {
          // Ignore errors like 404 – it simply means the counterpart does not exist.
          _logger.w('Bluesky counterpart post not found or deletion failed', error: e);
        }
      } catch (e) {
        // Best-effort only – do not fail original deletion.
        _logger.w('Failed during Bluesky cross-post deletion cleanup', error: e);
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

      final result = await atproto.repo.uploadBlob(data);
      _logger.d('Blob uploaded successfully');

      return result.data.blob;
    });
  }

  @override
  Future<List<Record>> listRecords({
    required String repo,
    required NSID collection,
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

      final records = result.data.records.map((record) => Record.fromJson(record.value)).toList();

      return records;
    });
  }

  @override
  Future<bool> createReport({
    required ReportSubject subject,
    required ModerationReasonType reasonType,
    String? reason,
    ModerationService? service,
  }) async {
    _logger.i('Creating moderation report for reason: ${reasonType.value}');

    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null || atproto.session == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      } else if (service != null) {
        _logger.d('Using provided moderation service');
        try {
          final report = await service.createReport(subject: subject, reasonType: reasonType, reason: reason);
          return report.status.code == 200;
        } catch (e) {
          _logger.e('Error creating report with service', error: e);
          throw Exception('Failed to create report: $e');
        }
      } else {
        _logger.d('Using direct API call for moderation report');
        final endpoint = NSID.parse('com.atproto.moderation.createReport');
        final subjectData = subject.data;

        Map<String, dynamic> body;

        if (subjectData is StrongRef) {
          final strongRef = subjectData.toJson();
          body = {
            'subject': {'\$type': 'com.atproto.repo.strongRef', 'uri': strongRef['uri'], 'cid': strongRef['cid']},
            'reasonType': reasonType.value,
          };
        } else if (subjectData is RepoRef) {
          body = {
            'subject': {'\$type': 'com.atproto.admin.defs.repoRef', 'did': subjectData.did},
            'reasonType': reasonType.value,
          };
        } else {
          _logger.e('Invalid subject data type: ${subjectData.runtimeType}');
          throw Exception('Invalid subject data');
        }

        if (reason != null) {
          body['reason'] = reason;
        }

        // Send to Spark's PDS (don't use the user's PDS as it might be different)
        // TODO: send to a chosen labeler's PDS
        final uri = Uri.parse('https://pds.sprk.so/xrpc/$endpoint');
        final headers = {'Authorization': 'Bearer ${atproto.session!.accessJwt}', 'Content-Type': 'application/json'};

        _logger.d('Sending report to: $uri');

        try {
          final response = await http.post(uri, headers: headers, body: jsonEncode(body));

          if (response.statusCode != 200) {
            _logger.e('Failed to create report: ${response.body}', error: 'HTTP ${response.statusCode}');
            throw Exception('Failed to create report: ${response.body}');
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
