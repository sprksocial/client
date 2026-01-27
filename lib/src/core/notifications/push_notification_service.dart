import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

/// Service for managing push notifications via Firebase Cloud Messaging
class PushNotificationService {
  PushNotificationService() {
    _logger.v('PushNotificationService initialized');
  }

  late final FirebaseMessaging _messaging;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'PushNotificationService',
  );

  String? _currentToken;
  bool _badgeSupported = false;
  bool _initialized = false;

  /// Initializes Firebase without requesting permissions
  /// Permissions should be requested separately via [requestPermissionAndGetToken]
  Future<void> initialize() async {
    _logger.i('Initializing push notification service');

    try {
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;
      _logger.d('Firebase initialized');

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_onTokenRefresh);

      // Check if badge is supported on this device
      _badgeSupported = await AppBadgePlus.isSupported();
      _logger.d('Badge support: $_badgeSupported');

      _initialized = true;
      _logger.i('Push notification service initialized successfully');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize push notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Returns true if notification permissions are already granted
  Future<bool> hasPermission() async {
    if (!_initialized) return false;

    try {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      _logger.e('Failed to check permission status', error: e);
      return false;
    }
  }

  /// Requests notification permissions from the user
  /// Returns true if permission was granted
  Future<bool> requestPermission() async {
    if (!_initialized) return false;

    _logger.d('Requesting notification permissions');

    try {
      final settings = await _messaging.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.i('User granted notification permission');
        return true;
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        _logger.i('User granted provisional notification permission');
        return true;
      } else {
        _logger.w('User denied notification permission');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to request permission',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Requests permission (if needed) and returns the FCM token
  /// Returns null if permission denied or error occurs
  Future<String?> requestPermissionAndGetToken() async {
    if (!_initialized) return null;

    final hasExistingPermission = await hasPermission();

    if (!hasExistingPermission) {
      final granted = await requestPermission();
      if (!granted) return null;
    }

    return getToken();
  }

  /// Handles FCM token refresh
  void _onTokenRefresh(String token) {
    _logger.d('FCM token refreshed: ${token.substring(0, 10)}...');
    _currentToken = token;
    // Token refresh registration is handled by the auth flow
    // which will call registerPush with the new token
  }

  /// Returns the current FCM token, or null if not available
  /// Note: This requires permission to be granted first
  Future<String?> getToken() async {
    if (!_initialized) return null;

    try {
      _currentToken ??= await _messaging.getToken();
      if (_currentToken != null) {
        _logger.d('FCM token obtained: ${_currentToken!.substring(0, 10)}...');
      }
      return _currentToken;
    } catch (e) {
      _logger.e('Failed to get FCM token', error: e);
      return null;
    }
  }

  /// Returns the platform identifier ('ios' or 'android')
  String get platform => Platform.isIOS ? 'ios' : 'android';

  /// Callback for when token is refreshed - allows external registration
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Clears the app badge count (iOS only, no-op on Android)
  Future<void> clearBadge() async {
    if (!_badgeSupported) return;

    try {
      await AppBadgePlus.updateBadge(0);
      _logger.d('Badge cleared');
    } catch (e, stackTrace) {
      _logger.e('Failed to clear badge', error: e, stackTrace: stackTrace);
    }
  }

  /// Updates the app badge count (iOS only, no-op on Android)
  Future<void> updateBadge(int count) async {
    if (!_badgeSupported) return;

    try {
      await AppBadgePlus.updateBadge(count);
      _logger.d('Badge updated to $count');
    } catch (e, stackTrace) {
      _logger.e('Failed to update badge', error: e, stackTrace: stackTrace);
    }
  }
}
