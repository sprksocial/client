import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/identity/resolve_handle.dart'
    as identity_resolve_handle;
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart_lex/com/atproto/label/query_labels.dart'
    as label_query_labels;
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
  LabelerRepositoryImpl(this._client, {SparkLogger? logger})
    : _logger = logger ?? GetIt.instance<LogService>().getLogger('LabelerAPI') {
    _logger.v('LabelerAPI initialized');
  }
  final SprkRepository _client;
  final SparkLogger _logger;
  final Map<String, Future<LabelerViewDetailed>> _detailedServiceCache = {};

  @override
  Future<String> resolveIdentifier(String identifier) async {
    final normalized = identifier.trim().replaceFirst(RegExp(r'^@'), '');
    if (normalized.startsWith('did:')) {
      return normalized.split('#').first;
    }
    if (normalized.isEmpty) {
      throw ArgumentError.value(identifier, 'identifier', 'Cannot be empty');
    }

    return _client.executeWithRetry(() async {
      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        throw Exception('AtProto not initialized');
      }
      final result = await atproto.call(
        identity_resolve_handle.comAtprotoIdentityResolveHandle,
        parameters: identity_resolve_handle.IdentityResolveHandleInput(
          handle: normalized,
        ),
      );
      return result.data.did;
    });
  }

  @override
  Future<void> validateService(String did) async {
    final service = await getServicesDetailed([did]);
    if (service.creator.did != did) {
      throw const LabelerServiceUnavailableException(
        'Labeler service DID does not match requested DID',
      );
    }
    if (service.labels?.any(
          (label) => label.val == '!takedown' && label.neg != true,
        ) ??
        false) {
      throw LabelerServiceUnavailableException(
        'Labeler service is taken down: $did',
      );
    }
  }

  @override
  Future<({List<Label> labels, String? cursor})> queryLabels(
    List<AtUri> uris, {
    List<String>? sources,
    int? limit,
    String? cursor,
  }) async {
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

      final defaultLabelerDid = _client.modDid.split('#').first;
      final labelers = sources != null && sources.isNotEmpty
          ? sources
          : _client.labelerDids;
      final parameters = label_query_labels.LabelQueryLabelsInput(
        uriPatterns: uris.map((uri) => uri.toString()).toList(),
        sources: labelers,
        limit: limit ?? 50,
        cursor: cursor,
      );
      final response = await atproto.call(
        label_query_labels.comAtprotoLabelQueryLabels,
        headers: {'atproto-proxy': _client.modDid},
        parameters: parameters,
      );
      final responseJson = response.data.toJson();
      _logger
        ..d('parameters: ${parameters.toJson()}')
        ..d('Labels retrieved: $responseJson');

      final labels = <Label>[];
      for (final label in responseJson['labels']! as List<dynamic>) {
        final cleanLabel = label as Map<String, Object?>
          ..remove('sig')
          ..putIfAbsent('src', () => defaultLabelerDid);
        labels.add(Label.fromJson(cleanLabel));
      }

      return (labels: labels, cursor: responseJson['cursor'] as String?);
    });
  }

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
        headers: _client.appViewHeaders(_client.sprkDid),
      );
      if (result.status != HttpStatus.ok) {
        _logger.e('Failed to retrieve labeler services for DIDs: $dids');
        throw Exception('Failed to retrieve labeler services for DIDs: $dids');
      }
      if (result.data.views.isEmpty) {
        throw LabelerServiceUnavailableException(
          'No labeler services returned for DIDs: $dids',
        );
      }
      final view = result.data.views.first.labelerView;
      if (view == null) {
        throw LabelerServiceUnavailableException(
          'No basic labeler service returned for DIDs: $dids',
        );
      }
      _logger.d('Labeler services retrieved successfully');
      return view;
    });
  }

  @override
  Future<LabelerViewDetailed> getServicesDetailed(List<String> dids) async {
    if (dids.length != 1) return _fetchServicesDetailed(dids);

    final did = dids.single;
    final request = _detailedServiceCache.putIfAbsent(
      did,
      () => _fetchServicesDetailed(dids),
    );
    try {
      return await request;
    } finally {
      if (identical(_detailedServiceCache[did], request)) {
        _detailedServiceCache.remove(did);
      }
    }
  }

  Future<LabelerViewDetailed> _fetchServicesDetailed(List<String> dids) async {
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
        headers: _client.appViewHeaders(_client.sprkDid),
      );
      if (result.status != HttpStatus.ok) {
        _logger.e('Failed to retrieve labeler services for DIDs: $dids');
        throw Exception('Failed to retrieve labeler services for DIDs: $dids');
      }
      if (result.data.views.isEmpty) {
        throw LabelerServiceUnavailableException(
          'No labeler services returned for DIDs: $dids',
        );
      }
      final view = result.data.views.first.labelerViewDetailed;
      if (view == null) {
        throw LabelerServiceUnavailableException(
          'No detailed labeler service returned for DIDs: $dids',
        );
      }
      _logger.d('Labeler services retrieved successfully');
      return view;
    });
  }

  @override
  Future<List<CompatibleModerationService>> getCompatibleModerationServices(
    Iterable<String> dids,
    ModerationServiceQuery query,
  ) async {
    final fallbackDid = query.fallbackDid.split('#').first;
    final candidates = <String>{fallbackDid, ...dids};
    final services = await Future.wait([
      for (final did in candidates)
        _compatibleService(did, fallbackDid: fallbackDid, query: query),
    ]);
    final compatible = services.nonNulls.toList()
      ..sort((left, right) {
        if (left.isDefault != right.isDefault) {
          return left.isDefault ? -1 : 1;
        }
        return left.displayName.compareTo(right.displayName);
      });
    return compatible;
  }

  Future<CompatibleModerationService?> _compatibleService(
    String did, {
    required String fallbackDid,
    required ModerationServiceQuery query,
  }) async {
    try {
      final service = await getServicesDetailed([did]);
      final subjectTypes = service.subjectTypes?.map((type) => type.toJson());
      if (subjectTypes != null && !subjectTypes.contains(query.subjectType)) {
        return null;
      }
      if (query.subjectCollection != null &&
          service.subjectCollections != null &&
          !service.subjectCollections!.contains(query.subjectCollection)) {
        return null;
      }
      final reasonTypes = service.reasonTypes?.map((type) => type.toJson());
      if (reasonTypes != null && !reasonTypes.contains(query.reasonType)) {
        return null;
      }
      return CompatibleModerationService(
        did: did,
        displayName: service.creator.displayName ?? service.creator.handle,
        isDefault: did == fallbackDid,
      );
    } catch (error, stackTrace) {
      _logger.w(
        'Unable to inspect moderation service capabilities for $did',
        error: error,
        stackTrace: stackTrace,
      );
      if (did == fallbackDid) {
        return CompatibleModerationService(
          did: did,
          displayName: did,
          isDefault: true,
        );
      }
      return null;
    }
  }
}
