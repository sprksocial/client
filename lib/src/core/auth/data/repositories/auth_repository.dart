import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:sparksocial/src/core/auth/data/models/login_result.dart';

/// Authentication repository interface for AT Protocol
abstract class AuthRepository {
  /// Checks if the user is authenticated
  bool get isAuthenticated;

  /// Gets the current session
  Session? get session;

  /// Gets the AT Protocol client
  ATProto? get atproto;

  /// Attempts to log in a user with the provided credentials
  ///
  /// [handle] - The user handle
  /// [password] - The user password
  /// [authCode] - Optional authentication code for two-factor authentication
  Future<LoginResult> login(String handle, String password, {String? authCode});

  /// Registers a new user account
  ///
  /// [handle] - The user handle
  /// [email] - The user email
  /// [password] - The user password
  /// [inviteCode] - Optional invite code for restricted registrations
  ///
  /// Returns a tuple with a boolean indicating success and an optional error message
  Future<({bool success, String? error})> register(String handle, String email, String password, String? inviteCode);

  /// Logs out the current user
  Future<void> logout();

  /// Validates if the current session is still active
  /// Returns true if valid, false otherwise
  Future<bool> validateSession();

  /// Refreshes the authentication token
  /// Returns true if the session was successfully refreshed
  Future<bool> refreshToken();
}
