import 'dart:async';

import 'package:atproto/atproto.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/auth/data/models/login_result.dart';
import 'package:spark/src/core/auth/data/repositories/auth_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/notification_repository.dart';
import 'package:spark/src/core/notifications/push_notification_service.dart';
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
  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _pendingPushRegistration = false;

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

  /// Resets OAuth loading state, typically when the OAuth cancelled or errored
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
    try {
      final result = await _authRepository.completeOAuth(callbackUrl);

      if (!result.isSuccess) {
        state = state.copyWith(isLoading: false, error: result.error);
      } else {
        _updateState();
        state = state.copyWith(isLoading: false);

        // Register for push notifications after successful login
        await _registerPushNotifications();
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
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Unregister push notifications before logout
      await _unregisterPushNotifications();

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

  /// Registers the device for push notifications
  /// Only registers if permission is already granted, otherwise defers
  Future<void> _registerPushNotifications() async {
    try {
      final pushService = GetIt.instance<PushNotificationService>();

      // Check if we already have permission
      final hasPermission = await pushService.hasPermission();

      if (hasPermission) {
        // Permission already granted, register immediately
        await _doRegisterPush(pushService);
      } else {
        // Permission not granted yet, defer until main screen
        _pendingPushRegistration = true;
      }
    } catch (e, stackTrace) {
      // Don't fail login if push registration fails
      _logger.e(
        'Failed to register push notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Actually performs push registration (called when we have permission)
  Future<void> _doRegisterPush(PushNotificationService pushService) async {
    final token = await pushService.getToken();

    if (token != null) {
      final notificationRepo = GetIt.instance<NotificationRepository>();
      await notificationRepo.registerPush(
        token: token,
        platform: pushService.platform,
        appId: 'so.sprk.app',
      );

      // Set up listener for token refresh
      await _setupTokenRefreshListener(pushService, notificationRepo);
      _pendingPushRegistration = false;
    }
  }

  /// True if push registration is pending (permission not yet requested)
  bool get hasPendingPushRegistration => _pendingPushRegistration;

  /// Requests push notification permission and registers if granted
  /// Call this from the main screen after login
  Future<bool> requestPushPermissionAndRegister() async {
    if (!_pendingPushRegistration) {
      return true;
    }

    try {
      final pushService = GetIt.instance<PushNotificationService>();
      final granted = await pushService.requestPermission();

      if (granted) {
        await _doRegisterPush(pushService);
        return true;
      } else {
        _pendingPushRegistration = false;
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to request push permission',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Sets up a listener for FCM token refresh to re-register
  Future<void> _setupTokenRefreshListener(
    PushNotificationService pushService,
    NotificationRepository notificationRepo,
  ) async {
    // Cancel any existing subscription and wait for it to complete
    await _tokenRefreshSubscription?.cancel();

    _tokenRefreshSubscription = pushService.onTokenRefresh.listen(
      (newToken) async {
        try {
          await notificationRepo.registerPush(
            token: newToken,
            platform: pushService.platform,
            appId: 'so.sprk.app',
          );
        } catch (e, stackTrace) {
          _logger.e(
            'Failed to re-register push notifications after token refresh',
            error: e,
            stackTrace: stackTrace,
          );
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        _logger.e(
          'Error in token refresh stream',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  /// Unregisters the device from push notifications
  Future<void> _unregisterPushNotifications() async {
    // Cancel token refresh listener
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;

    try {
      final pushService = GetIt.instance<PushNotificationService>();
      final token = await pushService.getToken();

      if (token != null) {
        final notificationRepo = GetIt.instance<NotificationRepository>();
        await notificationRepo.unregisterPush(
          token: token,
          platform: pushService.platform,
          appId: 'so.sprk.app',
        );
      }
    } catch (e, stackTrace) {
      // Don't fail logout if push unregistration fails
      _logger.e(
        'Failed to unregister push notifications',
        error: e,
        stackTrace: stackTrace,
      );
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
