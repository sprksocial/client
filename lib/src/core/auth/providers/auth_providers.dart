import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/auth/models/auth_state.dart';
import 'package:sparksocial/src/core/auth/models/login_result.dart';
import 'package:sparksocial/src/core/auth/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';

/// Authentication notifier for the application
/// Provides higher-level authentication operations and state management
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final _logger = GetIt.instance<LogService>().getLogger('AuthNotifier');

  /// Creates a new instance of AuthNotifier
  /// 
  /// [authRepository] - The repository to use for authentication operations
  AuthNotifier(this._authRepository) 
      : super(AuthState(
          isAuthenticated: _authRepository.isAuthenticated,
          session: _authRepository.session,
          atproto: _authRepository.atproto,
        ));

  /// Updates the state based on repository values
  void _updateState() {
    state = AuthState(
      isAuthenticated: _authRepository.isAuthenticated,
      session: _authRepository.session,
      atproto: _authRepository.atproto,
    );
  }

  /// Attempts to log in a user with the provided credentials
  /// 
  /// [handle] - The user handle (e.g. username)
  /// [password] - The user password
  /// [authCode] - Optional authentication code for two-factor authentication
  Future<LoginResult> login(String handle, String password, {String? authCode}) async {
    _logger.i('Login attempt by service layer');
    final result = await _authRepository.login(handle, password, authCode: authCode);
    _updateState();
    return result;
  }

  /// Registers a new user account
  /// 
  /// [handle] - The user handle (e.g. username)
  /// [email] - The user email address
  /// [password] - The user password
  /// [inviteCode] - Optional invite code for restricted registrations
  Future<(bool, String?)> register(String handle, String email, String password, String? inviteCode) async {
    _logger.i('Registration attempt by service layer');
    final result = await _authRepository.register(handle, email, password, inviteCode);
    _updateState();
    return result;
  }

  /// Logs out the current user
  Future<void> logout() async {
    _logger.i('Logout attempt by service layer');
    await _authRepository.logout();
    _updateState();
  }

  /// Validates if the current session is still active
  /// Returns true if valid, false otherwise
  Future<bool> validateSession() async {
    _logger.d('Session validation by service layer');
    final result = await _authRepository.validateSession();
    _updateState();
    return result;
  }

  /// Refreshes the authentication token
  /// Returns true if the session was successfully refreshed
  Future<bool> refreshToken() async {
    _logger.i('Token refresh by service layer');
    final result = await _authRepository.refreshToken();
    _updateState();
    return result;
  }
}

/// Provider for the AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return GetIt.instance<AuthRepository>();
});

/// StateNotifierProvider for authentication state and operations
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Convenience provider for checking if the user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

/// Convenience provider for accessing the current session
final sessionProvider = Provider<Session?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.session;
});

/// Convenience provider for accessing the ATProto client
final atprotoProvider = Provider<ATProto?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.atproto;
}); 