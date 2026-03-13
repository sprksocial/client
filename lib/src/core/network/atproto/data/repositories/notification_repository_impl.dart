import 'dart:convert';

import 'package:atproto/core.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/network/atproto/data/models/notification_models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/notification_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/notifications/push_notification_service.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

/// Notification-related API endpoints implementation
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._client) {
    _logger.v('NotificationRepository initialized');
  }
  final SprkRepository _client;
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'NotificationRepository',
  );

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

      final parameters = <String, dynamic>{'limit': limit.toString()};
      if (cursor != null && cursor.isNotEmpty) {
        parameters['cursor'] = cursor;
      }
      if (priority != null) {
        parameters['priority'] = priority.toString();
      }
      if (reasons != null && reasons.isNotEmpty) {
        parameters['reasons'] = reasons;
      }

      final result = await atproto.get(
        NSID.parse('so.sprk.notification.listNotifications'),
        parameters: parameters,
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) =>
            jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
      );

      final rawResponse = result.data as Map<String, dynamic>;
      _logger.d('Notifications retrieved successfully');
      return ListNotificationsResponse.fromJson(rawResponse);
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

      final parameters = <String, String>{};
      if (priority != null) {
        parameters['priority'] = priority.toString();
      }

      final result = await atproto.get(
        NSID.parse('so.sprk.notification.getUnreadCount'),
        parameters: parameters,
        headers: {'atproto-proxy': _client.sprkDid},
        to: (jsonMap) => jsonMap,
        adaptor: (uint8) =>
            jsonDecode(utf8.decode(uint8 as List<int>)) as Map<String, dynamic>,
      );

      final rawResponse = result.data as Map<String, dynamic>;
      _logger.d('Unread count retrieved successfully');
      return UnreadCountResponse.fromJson(rawResponse);
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

      // Convert DateTime to ISO8601 string for the API
      final body = {'seenAt': seenAt.toIso8601String()};

      await atproto.post(
        NSID.parse('so.sprk.notification.updateSeen'),
        body: body,
        headers: {'atproto-proxy': _client.sprkDid},
      );

      // Clear app badge locally (server also sends silent push for background)
      try {
        await GetIt.instance<PushNotificationService>().clearBadge();
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

      final body = {
        'serviceDid': serviceDid,
        'token': token,
        'platform': platform,
        'appId': appId,
      };

      await atproto.post(
        NSID.parse('so.sprk.notification.registerPush'),
        body: body,
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

      final body = {
        'serviceDid': serviceDid,
        'token': token,
        'platform': platform,
        'appId': appId,
      };

      await atproto.post(
        NSID.parse('so.sprk.notification.unregisterPush'),
        body: body,
        headers: {'atproto-proxy': _client.sprkDid},
      );

      _logger.i('Push token unregistered successfully');
    });
  }
}
