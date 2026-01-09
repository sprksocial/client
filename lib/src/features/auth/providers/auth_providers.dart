import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
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
@riverpod
class Auth extends _$Auth {
  late final AuthRepository _authRepository;
  late final LogService _logService;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    _logService = GetIt.instance<LogService>();

    return AuthState(
      isAuthenticated: _authRepository.isAuthenticated,
      session: _authRepository.session,
      atproto: _authRepository.atproto,
    );
  }

  SparkLogger get _logger => _logService.getLogger('AuthNotifier');

  /// Updates the state based on repository values
  void _updateState() {
    state = AuthState(
      isAuthenticated: _authRepository.isAuthenticated,
      session: _authRepository.session,
      atproto: _authRepository.atproto,
      isLoading: state.isLoading,
      error: state.error,
    );
  }

  /// Attempts to log in a user with the provided credentials
  ///
  /// [handle] - The user handle (e.g. username)
  /// [password] - The user password
  /// [authCode] - Optional authentication code for two-factor authentication
  Future<LoginResult> login(
    String handle,
    String password, {
    String? authCode,
  }) async {
    _logger.i('Login attempt by service layer');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authRepository.login(
        handle,
        password,
        authCode: authCode,
      );

      if (!result.isSuccess) {
        state = state.copyWith(isLoading: false, error: result.error);
      } else {
        _updateState();
        state = state.copyWith(isLoading: false);
      }

      return result;
    } catch (e, stackTrace) {
      _logger.e('Login error', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, error: 'Login failed: $e');
      return LoginResult.failed('Login failed: $e');
    }
  }

  /// Registers a new user account
  ///
  /// [handle] - The user handle (e.g. username)
  /// [email] - The user email address
  /// [password] - The user password
  /// [inviteCode] - Optional invite code for restricted registrations
  Future<LoginResult> register(
    String handle,
    String email,
    String password,
    String? inviteCode,
  ) async {
    _logger.i('Registration attempt by service layer');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authRepository.register(
        handle,
        email,
        password,
        inviteCode,
      );
      _updateState();
      state = state.copyWith(isLoading: false, error: result.error);
      return LoginResult.success();
    } catch (e, stackTrace) {
      _logger.e('Registration error', error: e, stackTrace: stackTrace);
      final errorMsg = 'Registration failed: $e';
      state = state.copyWith(isLoading: false, error: errorMsg);
      return LoginResult.failed(errorMsg);
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

/// Convenience provider for accessing the current session
@riverpod
Session? session(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.session;
}

/// Convenience provider for accessing the ATProto client
@riverpod
ATProto? atproto(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.atproto;
}
