import 'dart:convert';
import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';

import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/pref_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

class PrefRepositoryImpl implements PrefRepository {
  PrefRepositoryImpl(this._client) {
    _logger.v('PrefRepository initialized');
  }
  final SprkRepository _client;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'PrefRepository',
  );
  @override
  Future<Preferences> getPreferences() async {
    _logger.d('Getting user preferences');
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
        NSID.parse('so.sprk.actor.getPreferences'),
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) =>
            jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
      );

      if (result.status != HttpStatus.ok) {
        _logger.e('Failed to retrieve preferences');
        throw Exception('Failed to retrieve preferences');
      }

      return Preferences.fromJson(result.data as Map<String, dynamic>);
    });
  }

  @override
  Future<void> putPreferences(Preferences preferences) async {
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

      final result = await atproto.post(
        NSID.parse('so.sprk.actor.putPreferences'),
        body: preferences.toJson(),
        headers: {'atproto-proxy': _client.sprkDid},
      );

      if (result.status != HttpStatus.ok) {
        _logger.e('Failed to update preferences');
        throw Exception('Failed to update preferences: ${result.status}');
      }

      _logger.d('Preferences updated successfully');
    });
  }
}
