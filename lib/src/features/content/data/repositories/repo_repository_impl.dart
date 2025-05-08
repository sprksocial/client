import 'dart:typed_data';

import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
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
} 