import 'package:get_it/get_it.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/config/app_config.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

/// Helper class for managing AT Protocol service authentication tokens
/// Used for authenticating with chat service via XRPC
class ServiceAuthHelper {
  ServiceAuthHelper(this._authRepository) {
    _logger = GetIt.I<LogService>().getLogger('ServiceAuthHelper');
  }

  final AuthRepository _authRepository;
  late final SparkLogger _logger;

  // Cache tokens by NSID to avoid redundant requests
  final Map<String, ({String token, DateTime expiry})> _tokenCache = {};

  /// Service DID for the chat service (audience for JWT)
  String get serviceDid => AppConfig.chatServiceDid;

  /// Gets a service auth token for the specified NSID (lexicon method)
  /// Tokens are cached and reused if not expired
  Future<String> getServiceToken(String nsid) async {
    // Check cache first
    final cached = _tokenCache[nsid];
    if (cached != null &&
        DateTime.now().isBefore(
          cached.expiry.subtract(const Duration(seconds: 30)),
        )) {
      _logger.d('Using cached service token for $nsid');
      return cached.token;
    }

    try {
      final atproto = _authRepository.atproto;
      if (atproto == null) {
        throw Exception('Not authenticated - ATProto client not available');
      }

      _logger.d(
        'Requesting service auth token for $nsid with aud: $serviceDid',
      );

      // Calculate expiration (60 seconds from now)
      final exp =
          DateTime.now()
              .add(const Duration(seconds: 60))
              .millisecondsSinceEpoch ~/
          1000;

      // Use official atproto API to request service auth
      final res = await atproto.server.getServiceAuth(
        aud: serviceDid,
        lxm: nsid,
        exp: exp,
      );

      final token = res.data.token;

      // Cache the token with its expiry
      _tokenCache[nsid] = (
        token: token,
        expiry: DateTime.fromMillisecondsSinceEpoch(exp * 1000),
      );

      _logger.d('Successfully obtained service auth token for $nsid');
      return token;
    } catch (e) {
      _logger.e('Failed to get service auth token for $nsid', error: e);
      rethrow;
    }
  }

  /// Clears the token cache
  void clearCache() {
    _tokenCache.clear();
    _logger.d('Service auth token cache cleared');
  }

  /// Clears a specific token from cache
  void clearToken(String nsid) {
    _tokenCache.remove(nsid);
    _logger.d('Cleared service auth token for $nsid');
  }
}
