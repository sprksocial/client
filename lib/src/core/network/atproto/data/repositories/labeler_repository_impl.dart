import 'dart:convert';

import 'package:atproto_core/atproto_core.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/labeler_repository.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/core/utils/logging/logger.dart';

class LabelerRepositoryImpl extends LabelerRepository {
  LabelerRepositoryImpl(this._client) {
    _logger.v('LabelerAPI initialized');
  }
  final SprkRepository _client;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger('LabelerAPI');

  @override
  Future<LabelerView> getServices(List<String> dids) async {
    _logger.d('Getting labeler services for DIDs: $dids');
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
        NSID.parse('so.sprk.labeler.getServices'),
        parameters: {'dids': dids, 'detailed': false},
        headers: {'atproto-proxy': _client.sprkDid},
        to: LabelerView.fromJson,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
      );
      if (result.status != HttpStatus.ok) {
        _logger.e('Failed to retrieve labeler services for DIDs: $dids');
        throw Exception('Failed to retrieve labeler services for DIDs: $dids');
      }
      _logger.d('Labeler services retrieved successfully');
      return result.data;
    });
  }

  @override
  Future<LabelerViewDetailed> getServicesDetailed(List<String> dids) async {
    _logger.d('Getting detailed labeler services for DIDs: $dids');
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
        NSID.parse('so.sprk.labeler.getServices'),
        parameters: {'dids': dids, 'detailed': true},
        headers: {'atproto-proxy': _client.sprkDid},
        to: LabelerViewDetailed.fromJson,
        adaptor: (uint8) => jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
      );
      if (result.status != HttpStatus.ok) {
        _logger.e('Failed to retrieve labeler services for DIDs: $dids');
        throw Exception('Failed to retrieve labeler services for DIDs: $dids');
      }
      _logger.d('Labeler services retrieved successfully');
      return result.data;
    });
  }
}
