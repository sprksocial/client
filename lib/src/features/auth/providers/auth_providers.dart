import 'package:atproto/atproto.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/auth/data/models/login_result.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:spark/src/features/auth/providers/auth_state.dart';

part 'auth_providers.g.dart';

/// Repository provider for authentication operations
@riverpod
AuthRepository authRepository(Ref ref) {
  return GetIt.instance<AuthRepository>();
}

/// Authentication notifier for the application
/// Provides higher-level authentication operations and state management
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  late final AuthRepository _authRepository;
  late final LogService _logService;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    _logService = GetIt.instance<LogService>();

    // Schedule state update after initialization completes
    _initializeState();

    return AuthState(
      isAuthenticated: _authRepository.isAuthenticated,
      did: _authRepository.did,
      handle: _authRepository.handle,
      atproto: _authRepository.atproto,
    );
  }

  /// Waits for repository initialization and updates state
  Future<void> _initializeState() async {
    try {
      await _authRepository.initializationComplete;
      _updateState();
    } catch (e) {
      _logger.e('Failed to initialize auth state', error: e);
    }
  }

  SparkLogger get _logger => _logService.getLogger('AuthNotifier');

  /// Updates the state based on repository values
  void _updateState() {
    state = AuthState(
      isAuthenticated: _authRepository.isAuthenticated,
      did: _authRepository.did,
      handle: _authRepository.handle,
      atproto: _authRepository.atproto,
      isLoading: state.isLoading,
      error: state.error,
    );
  }

  /// Initiates the OAuth flow for the given handle
  ///
  /// [handle] - The user handle to authenticate
  ///
  /// Returns the authorization URL that the user should be redirected to
  Future<String> initiateOAuth(String handle) async {
    _logger.i('Initiating OAuth for handle: $handle');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final authUrl = await _authRepository.initiateOAuth(handle);
      // Don't set isLoading to false here - we're waiting for the callback
      return authUrl;
    } catch (e, stackTrace) {
      _logger.e('OAuth initiation error', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to start login: $e',
      );
      rethrow;
    }
  }

  /// Initiates the OAuth flow without a handle, using a specific service
  ///
  /// [service] - The OAuth service host (e.g., 'pds.sprk.so')
  ///
  /// Returns the authorization URL that the user should be redirected to
  Future<String> initiateOAuthWithService(String service) async {
    _logger.i('Initiating OAuth with service: $service');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final authUrl = await _authRepository.initiateOAuthWithService(service);
      // Don't set isLoading to false here - we're waiting for the callback
      return authUrl;
    } catch (e, stackTrace) {
      _logger.e('OAuth initiation error', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to start sign up: $e',
      );
      rethrow;
    }
  }

  /// Resets the OAuth loading state, typically called when the OAuth flow is cancelled or errored
  ///
  /// [error] - Optional error message to set. If null, error is cleared.
  void resetOAuthState({String? error}) {
    state = state.copyWith(isLoading: false, error: error);
  }

  /// Completes the OAuth flow after receiving the callback
  ///
  /// [callbackUrl] - The full callback URL with authorization code
  ///
  /// Returns the result of the login attempt
  Future<LoginResult> completeOAuth(String callbackUrl) async {
    _logger.i('Completing OAuth with callback');

    try {
      final result = await _authRepository.completeOAuth(callbackUrl);

      if (!result.isSuccess) {
        state = state.copyWith(isLoading: false, error: result.error);
      } else {
        _updateState();
        state = state.copyWith(isLoading: false);
      }

      return result;
    } catch (e, stackTrace) {
      _logger.e('OAuth completion error', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed: $e',
      );
      return LoginResult.failed('Login failed: $e');
    }
  }

  /// Logs out the current user
  Future<void> logout() async {
    _logger.i('Logout attempt by service layer');
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authRepository.logout();
      _updateState();
      state = state.copyWith(isLoading: false);
    } catch (e, stackTrace) {
      _logger.e('Logout error', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, error: 'Logout failed: $e');
    }
  }

  /// Validates if the current session is still active
  /// Returns true if valid, false otherwise
  Future<bool> validateSession() async {
    _logger.d('Session validation by service layer');

    try {
      final result = await _authRepository.validateSession();
      _updateState();
      return result;
    } catch (e, stackTrace) {
      _logger.e('Session validation error', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: 'Session validation failed: $e');
      return false;
    }
  }

  /// Refreshes the authentication token
  /// Returns true if the session was successfully refreshed
  Future<bool> refreshToken() async {
    _logger.i('Token refresh by service layer');

    try {
      final result = await _authRepository.refreshToken();
      _updateState();
      return result;
    } catch (e, stackTrace) {
      _logger.e('Token refresh error', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: 'Token refresh failed: $e');
      return false;
    }
  }
}

/// Convenience provider for checking if the user is authenticated
@riverpod
bool isAuthenticated(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
}

/// Convenience provider for accessing the current user's DID
@riverpod
String? currentDid(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.did;
}

/// Convenience provider for accessing the current user's handle
@riverpod
String? currentHandle(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.handle;
}

/// Convenience provider for accessing the ATProto client
@riverpod
ATProto? atproto(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.atproto;
}
