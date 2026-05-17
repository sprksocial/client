import 'package:poptart/poptart.dart';
import 'package:get_it/get_it.dart';

import 'package:spark/src/core/network/atproto/data/models/pref_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/pref_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:sprk_poptart/so/sprk/actor/get_preferences.dart'
    as sprk_get_preferences;
import 'package:sprk_poptart/so/sprk/actor/put_preferences.dart'
    as sprk_put_preferences;

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
    _logger.d('Getting user preferences from server');
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
        sprk_get_preferences.soSprkActorGetPreferences,
        headers: {'atproto-proxy': _client.sprkDid},
      );

      if (result.status != HttpStatus.ok) {
        _logger.e('Failed to retrieve preferences');
        throw Exception('Failed to retrieve preferences');
      }

      return result.data;
    });
  }

  @override
  Future<void> putPreferences(Preferences preferences) async {
    await _client.executeWithRetry(() async {
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
        sprk_put_preferences.soSprkActorPutPreferences,
        input: sprk_put_preferences.ActorPutPreferencesInput(
          preferences: preferences.preferences,
        ),
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
