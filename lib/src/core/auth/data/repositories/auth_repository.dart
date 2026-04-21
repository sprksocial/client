import 'package:atproto/atproto.dart';
import 'package:spark/src/core/auth/data/models/login_result.dart';

/// Authentication repository interface for AT Protocol using OAuth
abstract class AuthRepository {
  /// Future that completes when initialization is done
  Future<void> get initializationComplete;

  /// Checks if the user is authenticated
  bool get isAuthenticated;

  /// Gets the current user's DID
  String? get did;

  /// Gets the current user's handle
  String? get handle;

  /// Gets the current user's PDS endpoint
  String? get pdsEndpoint;

  /// Gets the AT Protocol client
  ATProto? get atproto;

  /// Initiates the OAuth flow for the given handle
  ///
  /// [handle] - The user handle to authenticate
  ///
  /// Returns the authorization URL that the user should be redirected to
  Future<String> initiateOAuth(String handle);

  /// Initiates the OAuth flow without a handle.
  ///
  /// [service] is retained as a compatibility parameter and is ignored in
  /// AIP-backed auth mode.
  ///
  /// Returns the authorization URL that the user should be redirected to
  Future<String> initiateOAuthWithService(String service);

  /// Completes the OAuth flow after receiving the callback
  ///
  /// [callbackUrl] - The full callback URL with authorization code
  ///
  /// Returns the result of the login attempt
  Future<LoginResult> completeOAuth(String callbackUrl);

  /// Logs out the current user
  Future<void> logout();

  /// Validates if the current session is still active
  /// Returns true if valid, false otherwise
  Future<bool> validateSession();

  /// Refreshes the authentication token
  /// Returns true if the session was successfully refreshed
  Future<bool> refreshToken();
}
