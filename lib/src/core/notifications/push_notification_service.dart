import 'dart:async';
import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/firebase_options.dart';
import 'package:spark/src/core/notifications/notification_navigation.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

enum PushAuthorizationStatus { authorized, provisional, denied }

abstract interface class PushMessagingClient {
  Stream<String> get onTokenRefresh;
  Stream<RemoteMessage> get onMessageOpenedApp;
  Stream<RemoteMessage> get onMessage;

  Future<RemoteMessage?> getInitialMessage();
  Future<PushAuthorizationStatus> getPermissionStatus();
  Future<PushAuthorizationStatus> requestPermission();
  Future<String?> getToken();
}

typedef PushMessagingInitializer = Future<PushMessagingClient> Function();
typedef NotificationRoutePusher = void Function(PageRouteInfo route);

/// Service for managing push notifications via Firebase Cloud Messaging
class PushNotificationService {
  PushNotificationService({
    PushMessagingInitializer? initializeMessaging,
    Future<bool> Function()? isBadgeSupported,
    Future<void> Function(int count)? updateBadge,
    bool Function()? isRouterAvailable,
    NotificationRoutePusher? pushRoute,
    SparkLogger? logger,
  }) : _initializeMessaging =
           initializeMessaging ?? _initializeFirebaseMessaging,
       _isBadgeSupported = isBadgeSupported ?? AppBadgePlus.isSupported,
       _updateBadge = updateBadge ?? AppBadgePlus.updateBadge,
       _isRouterAvailable =
           isRouterAvailable ??
           (() => GetIt.instance.isRegistered<AppRouter>()),
       _pushRoute =
           pushRoute ?? ((route) => GetIt.instance<AppRouter>().push(route)),
       _logger =
           logger ??
           GetIt.instance<LogService>().getLogger('PushNotificationService');

  final PushMessagingInitializer _initializeMessaging;
  final Future<bool> Function() _isBadgeSupported;
  final Future<void> Function(int count) _updateBadge;
  final bool Function() _isRouterAvailable;
  final NotificationRoutePusher _pushRoute;
  final SparkLogger _logger;

  PushMessagingClient? _messaging;
  Future<void>? _initialization;

  String? _currentToken;
  bool _badgeSupported = false;
  bool _navigationReady = false;

  /// Queued notification data for cold start navigation
  /// This is set when the app is opened from terminated state via notification
  RemoteMessage? _pendingNotification;

  /// Initializes Firebase without requesting permissions
  /// Permissions should be requested via [requestPermissionAndGetToken]
  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    try {
      final messaging = await _initializeMessaging();
      _messaging = messaging;

      // Listen for token refresh
      messaging.onTokenRefresh.listen(
        _onTokenRefresh,
        onError: _onMessagingError,
      );

      try {
        _badgeSupported = await _isBadgeSupported();
      } catch (e, stackTrace) {
        _logger.e(
          'Failed to check badge support',
          error: e,
          stackTrace: stackTrace,
        );
      }

      // Set up message handlers for deep linking
      await _setupMessageHandlers(messaging);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize push notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sets up FCM message handlers for deep linking
  Future<void> _setupMessageHandlers(PushMessagingClient messaging) async {
    // Handle notification tap when app is in background
    messaging.onMessageOpenedApp.listen(
      _handleNotificationTap,
      onError: _onMessagingError,
    );

    // Handle foreground messages (for badge updates)
    messaging.onMessage.listen(
      _handleForegroundMessage,
      onError: _onMessagingError,
    );

    // Handle notification tap when app was terminated
    try {
      final initialMessage = await messaging.getInitialMessage().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          _logger.w('Timed out waiting for initial FCM message');
          return null;
        },
      );
      if (initialMessage != null) {
        // Queue the navigation - will be processed after auth completes
        _pendingNotification = initialMessage;
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to fetch initial FCM message',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _onMessagingError(Object error, StackTrace stackTrace) {
    _logger.e(
      'Push notification stream failed',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Handles notification tap when app is in background or foreground
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final reason = notificationPayloadString(data['reason']);
    final recordUri = notificationRecordUri(data);
    final authorDid = notificationRecordAuthorDid(recordUri);
    final replyTarget = reason == 'reply'
        ? replyNotificationTargetFromPayload(data)
        : null;
    final postRouteUri = notificationPostRouteUri(
      reason: reason,
      recordUri: recordUri,
      payload: data,
    );

    if (!_navigationReady || !_isRouterAvailable()) {
      _pendingNotification = message;
      return;
    }

    if (reason == 'follow' && authorDid != null) {
      // Navigate to profile for follow notifications
      _pushRoute(ProfileRoute(did: authorDid));
    } else if (replyTarget != null) {
      _pushRoute(
        StandalonePostRoute(
          postUri: replyTarget.postUri,
          highlightedReplyUri: replyTarget.highlightedReplyUri,
        ),
      );
    } else if (postRouteUri != null) {
      _pushRoute(StandalonePostRoute(postUri: postRouteUri));
    }
  }

  /// Handles foreground messages (updates badge count)
  void _handleForegroundMessage(RemoteMessage message) {
    // Badge is already set by the server in the APNS payload
    // We could optionally show an in-app notification here
  }

  /// Returns true if there's a pending notification navigation
  bool get hasPendingNotification => _pendingNotification != null;

  /// Enables notification navigation only while the authenticated main page is ready.
  void setNavigationReady(bool ready) {
    _navigationReady = ready;
    if (!ready) return;

    final pendingNotification = _pendingNotification;
    if (pendingNotification == null) return;

    _pendingNotification = null;
    _handleNotificationTap(pendingNotification);
  }

  /// Returns true if notification permissions are already granted
  Future<bool> hasPermission() async {
    await initialize();
    final messaging = _messaging;
    if (messaging == null) return false;

    try {
      final status = await messaging.getPermissionStatus();
      return status == PushAuthorizationStatus.authorized ||
          status == PushAuthorizationStatus.provisional;
    } catch (e) {
      _logger.e('Failed to check permission status', error: e);
      return false;
    }
  }

  /// Requests notification permissions from the user
  /// Returns true if permission was granted
  Future<bool> requestPermission() async {
    await initialize();
    final messaging = _messaging;
    if (messaging == null) return false;

    try {
      final status = await messaging.requestPermission();

      return status == PushAuthorizationStatus.authorized ||
          status == PushAuthorizationStatus.provisional;
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
    final hasExistingPermission = await hasPermission();

    if (!hasExistingPermission) {
      final granted = await requestPermission();
      if (!granted) return null;
    }

    return getToken();
  }

  /// Handles FCM token refresh
  void _onTokenRefresh(String token) {
    _currentToken = token;
    // Token refresh registration is handled by the auth flow
    // which will call registerPush with the new token
  }

  /// Returns the current FCM token, or null if not available
  /// Note: This requires permission to be granted first
  Future<String?> getToken() async {
    await initialize();
    final messaging = _messaging;
    if (messaging == null) return null;

    try {
      return _currentToken ??= await messaging.getToken();
    } catch (e) {
      _logger.e('Failed to get FCM token', error: e);
      return null;
    }
  }

  /// Returns the platform identifier ('ios' or 'android')
  String get platform => Platform.isIOS ? 'ios' : 'android';

  /// Callback for when token is refreshed - allows external registration
  Stream<String> get onTokenRefresh async* {
    await initialize();
    final messaging = _messaging;
    if (messaging != null) yield* messaging.onTokenRefresh;
  }

  /// Clears the app badge count (iOS only, no-op on Android)
  Future<void> clearBadge() async {
    await initialize();
    if (!_badgeSupported) return;

    try {
      await _updateBadge(0);
    } catch (e, stackTrace) {
      _logger.e('Failed to clear badge', error: e, stackTrace: stackTrace);
    }
  }

  /// Updates the app badge count (iOS only, no-op on Android)
  Future<void> updateBadge(int count) async {
    await initialize();
    if (!_badgeSupported) return;

    try {
      await _updateBadge(count);
    } catch (e, stackTrace) {
      _logger.e('Failed to update badge', error: e, stackTrace: stackTrace);
    }
  }

  static Future<PushMessagingClient> _initializeFirebaseMessaging() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return _FirebasePushMessagingClient(FirebaseMessaging.instance);
  }
}

class _FirebasePushMessagingClient implements PushMessagingClient {
  const _FirebasePushMessagingClient(this._messaging);

  final FirebaseMessaging _messaging;

  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  @override
  // Spark's push API uses FCM tokens; onRegistered emits installation IDs.
  // ignore: deprecated_member_use
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();

  @override
  Future<PushAuthorizationStatus> getPermissionStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return _authorizationStatus(settings.authorizationStatus);
  }

  @override
  Future<PushAuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return _authorizationStatus(settings.authorizationStatus);
  }

  @override
  // Keep FCM tokens until Spark's push API supports installation IDs.
  // ignore: deprecated_member_use
  Future<String?> getToken() => _messaging.getToken();

  PushAuthorizationStatus _authorizationStatus(
    AuthorizationStatus authorizationStatus,
  ) {
    return switch (authorizationStatus) {
      AuthorizationStatus.authorized => PushAuthorizationStatus.authorized,
      AuthorizationStatus.provisional => PushAuthorizationStatus.provisional,
      _ => PushAuthorizationStatus.denied,
    };
  }
}
