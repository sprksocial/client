import 'dart:typed_data';
import 'dart:convert';

import 'package:atproto/core.dart';
import 'package:atproto/atproto.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sparksocial/src/core/network/atproto/data/repositories/repo_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository_impl.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/repo_models.dart';

/// Repository-related API endpoints implementation
class RepoRepositoryImpl implements RepoRepository {
  final SprkRepositoryImpl _client;
  final _logger = GetIt.instance<LogService>().getLogger('RepoAPI');

  RepoRepositoryImpl(this._client) {
    _logger.v('RepoAPI initialized');
  }

  @override
  Future<RecordResponse> getRecord({required AtUri uri}) async {
    _logger.d('Getting record for URI: $uri');
    return _client.executeWithRetry(() async {
      if (!_client.authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }
      final atproto = _client.authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }
      final result = await atproto.repo.getRecord(uri: uri);
      _logger.d('Record retrieved successfully');
      final value = result.data.value;
      return RecordResponse(
        uri: result.data.uri.toString(),
        cid: result.data.cid ?? '',
        value: value,
      );
    });
  }

  @override
  Future<RecordResponse> editRecord({required AtUri uri, required Map<String, dynamic> record}) async {
    _logger.d('Editing record at URI: $uri');
    return _client.executeWithRetry(() async {
      if (!_client.authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }
      final atproto = _client.authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }
      final result = await atproto.repo.putRecord(uri: uri, record: record);
      _logger.d('Record edited successfully');
      return RecordResponse(
        uri: result.data.uri.toString(),
        cid: result.data.cid,
        value: record,
      );
    });
  }

  @override
  Future<RecordResponse> createRecord({required NSID collection, required Map<String, dynamic> record, String? rkey}) async {
    _logger.d('Creating record in collection: $collection');
    return _client.executeWithRetry(() async {
      if (!_client.authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.repo.createRecord(collection: collection, record: record, rkey: rkey);
      _logger.d('Record created successfully');
      return RecordResponse(
        uri: result.data.uri.toString(),
        cid: result.data.cid,
        value: record,
      );
    });
  }

  @override
  Future<void> deleteRecord({required AtUri uri}) async {
    _logger.d('Deleting record at URI: $uri');
    return _client.executeWithRetry(() async {
      if (!_client.authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      await atproto.repo.deleteRecord(uri: uri);
      _logger.d('Record deleted successfully');
    });
  }

  @override
  Future<BlobResponse> uploadBlob(Uint8List data) async {
    _logger.d('Uploading blob of size: ${data.length} bytes');
    return _client.executeWithRetry(() async {
      if (!_client.authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.repo.uploadBlob(data);
      _logger.d('Blob uploaded successfully');
      
      // Create blobRef map
      final Map<String, dynamic> blobRef = {};
      blobRef['\$type'] = 'blob';
      blobRef['ref'] = result.data.blob.ref;
      blobRef['mimeType'] = result.data.blob.mimeType;
      
      return BlobResponse(
        blob: result.data.blob.toString(),
        blobRef: blobRef,
      );
    });
  }

  @override
  Future<RecordsListResponse> listRecords({
    required String repo, 
    required NSID collection, 
    String? cursor, 
    int? limit, 
    bool? reverse
  }) async {
    _logger.d('Listing records in repo: $repo, collection: $collection');
    return _client.executeWithRetry(() async {
      if (!_client.authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authService.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.repo.listRecords(
        repo: repo, 
        collection: collection, 
        cursor: cursor, 
        limit: limit, 
        reverse: reverse
      );
      
      _logger.d('Records listed successfully');
      
      final records = result.data.records.map((record) => RecordItem(
        uri: record.uri.toString(),
        cid: record.cid ?? '',
        value: record.value,
      )).toList();
      
      return RecordsListResponse(
        records: records,
        cursor: result.data.cursor,
      );
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
      if (!_client.authService.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }
      
      final atproto = _client.authService.atproto;
      if (atproto == null || atproto.session == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      } else if (service != null) {
        _logger.d('Using provided moderation service');
        try {
          final report = await service.createReport(
            subject: subject, 
            reasonType: reasonType, 
            reason: reason
          );
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
            'subject': {
              '\$type': 'com.atproto.repo.strongRef', 
              'uri': strongRef['uri'], 
              'cid': strongRef['cid']
            },
            'reasonType': reasonType.value,
          };
        } else if (subjectData is RepoRef) {
          body = {
            'subject': {
              '\$type': 'com.atproto.admin.defs.repoRef', 
              'did': subjectData.did
            },
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
        final headers = {
          'Authorization': 'Bearer ${atproto.session!.accessJwt}', 
          'Content-Type': 'application/json'
        };

        _logger.d('Sending report to: $uri');
        
        try {
          final response = await http.post(
            uri, 
            headers: headers, 
            body: jsonEncode(body)
          );

          if (response.statusCode != 200) {
            _logger.e('Failed to create report: ${response.body}', 
              error: 'HTTP ${response.statusCode}');
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