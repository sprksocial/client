import 'package:poptart/poptart.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/network/atproto/data/models/labeler_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/labeler_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:sprk_poptart/so/sprk/labeler/get_services.dart'
    as sprk_get_services;
import 'package:sprk_poptart/so/sprk/labeler/get_services/union_main_views.dart';

class LabelerRepositoryImpl extends LabelerRepository {
  LabelerRepositoryImpl(this._client) {
    _logger.v('LabelerAPI initialized');
  }
  final SprkRepository _client;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'LabelerAPI',
  );

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

      final result = await atproto.call(
        sprk_get_services.soSprkLabelerGetServices,
        parameters: sprk_get_services.LabelerGetServicesInput(
          dids: dids,
          detailed: false,
        ),
        headers: {'atproto-proxy': _client.sprkDid},
      );
      if (result.status != HttpStatus.ok) {
        _logger.e('Failed to retrieve labeler services for DIDs: $dids');
        throw Exception('Failed to retrieve labeler services for DIDs: $dids');
      }
      if (result.data.views.isEmpty) {
        throw Exception('No labeler services returned for DIDs: $dids');
      }
      final view = result.data.views.first.labelerView;
      if (view == null) {
        throw Exception('No basic labeler service returned for DIDs: $dids');
      }
      _logger.d('Labeler services retrieved successfully');
      return view;
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

      final result = await atproto.call(
        sprk_get_services.soSprkLabelerGetServices,
        parameters: sprk_get_services.LabelerGetServicesInput(
          dids: dids,
          detailed: true,
        ),
        headers: {'atproto-proxy': _client.sprkDid},
      );
      if (result.status != HttpStatus.ok) {
        _logger.e('Failed to retrieve labeler services for DIDs: $dids');
        throw Exception('Failed to retrieve labeler services for DIDs: $dids');
      }
      if (result.data.views.isEmpty) {
        throw Exception('No labeler services returned for DIDs: $dids');
      }
      final view = result.data.views.first.labelerViewDetailed;
      if (view == null) {
        throw Exception('No detailed labeler service returned for DIDs: $dids');
      }
      _logger.d('Labeler services retrieved successfully');
      return view;
    });
  }
}
