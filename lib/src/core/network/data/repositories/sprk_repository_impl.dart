import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/config/app_config.dart';
import 'package:sparksocial/src/core/network/data/repositories/actor_repository.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository.dart';
import 'package:sparksocial/src/core/network/data/repositories/graph_repository.dart';
import 'package:sparksocial/src/core/network/data/repositories/label_repository.dart';
import 'package:sparksocial/src/core/network/data/repositories/repo_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/network/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/network/data/repositories/repo_repository_impl.dart';
import 'package:sparksocial/src/core/network/data/repositories/feed_repository_impl.dart';
import 'package:sparksocial/src/core/network/data/repositories/actor_repository_impl.dart';

// Feature-specific repositories
import 'package:sparksocial/src/core/network/data/repositories/graph_repository_impl.dart';
import 'package:sparksocial/src/core/network/data/repositories/label_repository_impl.dart';

/// Client for interacting with Spark API endpoints
class SprkRepositoryImpl implements SprkRepository {
  final AuthRepository _authRepository;
  final String _sprkDid;
  final _logger = GetIt.instance<LogService>().getLogger('SprkRepository');

  /// Get the authentication service
  @override
  AuthRepository get authRepository => _authRepository;

  /// Get the Spark DID
  @override
  String get sprkDid => _sprkDid;

  SprkRepositoryImpl(this._authRepository) : _sprkDid = _getSprkDid() {
    _logger.d('SprkRepository initialized with DID: $_sprkDid');
  }

  static String _getSprkDid() {
    final sprkAppView = Uri.parse(AppConfig.appViewUrl);
    return "did:web:${sprkAppView.host}#sprk_appview";
  }

  /// Execute API request with token expiration handling
  @override
  Future<T> executeWithRetry<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (e) {
      // Check if the error is a token expired error
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('400') && (errorStr.contains('expired'))) {
        _logger.i('Token expired, attempting to refresh');
        // Try to refresh the token
        final refreshed = await _authRepository.refreshToken();
        if (!refreshed) {
          _logger.e('Failed to refresh expired token');
          throw Exception('Failed to refresh expired token');
        }

        _logger.i('Token refreshed successfully, retrying API call');
        // Retry the call with the new token
        return await apiCall();
      }

      _logger.e('API call failed', error: e);
      // Rethrow other errors
      rethrow;
    }
  }

  @override
  ActorRepository get actor => ActorRepositoryImpl(this);

  @override
  RepoRepository get repo => RepoRepositoryImpl(this);

  @override
  GraphRepository get graph => GraphRepositoryImpl(this);

  @override
  LabelRepository get label => LabelRepositoryImpl(this);

  @override
  FeedRepository get feed => FeedRepositoryImpl(this, label);
}
