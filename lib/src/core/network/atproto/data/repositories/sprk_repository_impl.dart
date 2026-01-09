import 'package:get_it/get_it.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/config/app_config.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/actor_repository_impl.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/feed_repository_impl.dart';
import 'package:spark/src/core/network/atproto/data/repositories/graph_repository.dart';
// Feature-specific repositories
import 'package:spark/src/core/network/atproto/data/repositories/graph_repository_impl.dart';
import 'package:spark/src/core/network/atproto/data/repositories/labeler_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/labeler_repository_impl.dart';
import 'package:spark/src/core/network/atproto/data/repositories/repo_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/repo_repository_impl.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sound_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sound_repository_impl.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/story_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/story_repository_impl.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

/// Client for interacting with Spark API endpoints
class SprkRepositoryImpl implements SprkRepository {
  SprkRepositoryImpl(this._authRepository) : _sprkDid = _getSprkDid() {
    _logger.d('SprkRepository initialized with DID: $_sprkDid');
  }
  final AuthRepository _authRepository;
  final String _sprkDid;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'SprkRepository',
  );

  /// Get the authentication service
  @override
  AuthRepository get authRepository => _authRepository;

  /// Get the Spark DID
  @override
  String get sprkDid => _sprkDid;

  @override
  String get bskyDid => 'did:web:api.bsky.app#bsky_appview';

  @override
  String get modDid => 'did:plc:pbgyr67hftvpoqtvaurpsctc#atproto_labeler';

  static String _getSprkDid() {
    final sprkAppView = Uri.parse(AppConfig.appViewUrl);
    return 'did:web:${sprkAppView.host}#sprk_appview';
  }

  /// Execute API request with token expiration handling
  /// This method performs a single retry after refreshing the token.
  /// To prevent infinite loops, it does NOT call executeWithRetry recursively.
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

        _logger.i('Token refreshed successfully, retrying API call once');
        // Retry the call with the new token - do NOT wrap in executeWithRetry
        // to prevent potential infinite loops
        try {
          return await apiCall();
        } catch (retryError) {
          _logger.e('API call failed after token refresh', error: retryError);
          rethrow;
        }
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
  FeedRepository get feed => FeedRepositoryImpl(this);

  @override
  StoryRepository get story => StoryRepositoryImpl(this);

  @override
  LabelerRepository get labeler => LabelerRepositoryImpl(this);

  @override
  SoundRepository get sound => SoundRepositoryImpl(this);
}
