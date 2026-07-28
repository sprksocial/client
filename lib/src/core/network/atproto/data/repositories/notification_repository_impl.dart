import 'package:get_it/get_it.dart';
import 'package:spark/src/core/network/atproto/data/models/notification_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/notification_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/notifications/push_notification_service.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';
import 'package:sprk_poptart/so/sprk/notification/get_unread_count.dart'
    as sprk_get_unread_count;
import 'package:sprk_poptart/so/sprk/notification/list_notifications.dart'
    as sprk_list_notifications;
import 'package:sprk_poptart/so/sprk/notification/register_push.dart'
    as sprk_register_push;
import 'package:sprk_poptart/so/sprk/notification/update_seen.dart'
    as sprk_update_seen;
import 'package:sprk_poptart/so/sprk/notification/unregister_push.dart'
    as sprk_unregister_push;

/// Notification-related API endpoints implementation
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(
    this._client, {
    SparkLogger? logger,
    Future<void> Function()? clearBadge,
  }) : _logger =
           logger ??
           GetIt.instance<LogService>().getLogger('NotificationRepository'),
       _clearBadge =
           clearBadge ??
           (() => GetIt.instance<PushNotificationService>().clearBadge()) {
    _logger.v('NotificationRepository initialized');
  }
  final SprkRepository _client;
  final SparkLogger _logger;
  final Future<void> Function() _clearBadge;

  @override
  Future<ListNotificationsResponse> listNotifications({
    int limit = 50,
    String? cursor,
    bool? priority,
    List<String>? reasons,
  }) async {
    _logger.d(
      'Listing notifications: limit=$limit, cursor=$cursor, '
      'priority=$priority, reasons=$reasons',
    );
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.call(
        sprk_list_notifications.soSprkNotificationListNotifications,
        parameters: sprk_list_notifications.NotificationListNotificationsInput(
          limit: limit,
          cursor: cursor == null || cursor.isEmpty ? null : cursor,
          priority: priority,
          reasons: reasons == null || reasons.isEmpty ? null : reasons,
        ),
        headers: {'atproto-proxy': _client.sprkDid},
      );

      _logger.d('Notifications retrieved successfully');
      return result.data;
    });
  }

  @override
  Future<UnreadCountResponse> getUnreadCount({bool? priority}) async {
    _logger.d('Getting unread count: priority=$priority');
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      final result = await atproto.call(
        sprk_get_unread_count.soSprkNotificationGetUnreadCount,
        parameters: sprk_get_unread_count.NotificationGetUnreadCountInput(
          priority: priority,
        ),
        headers: {'atproto-proxy': _client.sprkDid},
      );

      final output = result.data;
      _logger.d('Unread count retrieved successfully');
      return output;
    });
  }

  @override
  Future<void> updateSeen(DateTime seenAt) async {
    _logger.d('Updating seen timestamp: $seenAt');
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      await atproto.call(
        sprk_update_seen.soSprkNotificationUpdateSeen,
        input: sprk_update_seen.NotificationUpdateSeenInput(seenAt: seenAt),
        headers: {'atproto-proxy': _client.sprkDid},
      );

      // Clear app badge locally (server also sends silent push for background)
      try {
        await _clearBadge();
      } catch (e) {
        _logger.w('Failed to clear badge: $e');
      }

      _logger.d('Seen timestamp updated successfully');
    });
  }

  @override
  Future<void> registerPush({
    required String token,
    required String platform,
    required String appId,
  }) async {
    _logger.d('Registering push token: platform=$platform, appId=$appId');
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      // serviceDid needs just the DID without fragment (format validation)
      final serviceDid = _client.sprkDid.split('#').first;

      final input = sprk_register_push.NotificationRegisterPushInput(
        serviceDid: serviceDid,
        token: token,
        platform:
            sprk_register_push.NotificationRegisterPushPlatform.valueOf(
              platform,
            ) ??
            sprk_register_push.NotificationRegisterPushPlatform.unknown(
              data: platform,
            ),
        appId: appId,
      );

      await atproto.call(
        sprk_register_push.soSprkNotificationRegisterPush,
        input: input,
        headers: {'atproto-proxy': _client.sprkDid},
      );

      _logger.i('Push token registered successfully');
    });
  }

  @override
  Future<void> unregisterPush({
    required String token,
    required String platform,
    required String appId,
  }) async {
    _logger.d('Unregistering push token: platform=$platform, appId=$appId');
    return _client.executeWithRetry(() async {
      if (!_client.authRepository.isAuthenticated) {
        _logger.w('Not authenticated');
        throw Exception('Not authenticated');
      }

      final atproto = _client.authRepository.atproto;
      if (atproto == null) {
        _logger.e('AtProto not initialized');
        throw Exception('AtProto not initialized');
      }

      // serviceDid needs just the DID without fragment (format validation)
      final serviceDid = _client.sprkDid.split('#').first;

      final input = sprk_unregister_push.NotificationUnregisterPushInput(
        serviceDid: serviceDid,
        token: token,
        platform:
            sprk_unregister_push.NotificationUnregisterPushPlatform.valueOf(
              platform,
            ) ??
            sprk_unregister_push.NotificationUnregisterPushPlatform.unknown(
              data: platform,
            ),
        appId: appId,
      );

      await atproto.call(
        sprk_unregister_push.soSprkNotificationUnregisterPush,
        input: input,
        headers: {'atproto-proxy': _client.sprkDid},
      );

      _logger.i('Push token unregistered successfully');
    });
  }
}
