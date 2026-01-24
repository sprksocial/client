import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/network/atproto/data/repositories/notification_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

part 'unread_count_provider.g.dart';

@riverpod
class UnreadCountNotifier extends _$UnreadCountNotifier {
  late final NotificationRepository _notificationRepository;
  late final SparkLogger _logger;

  @override
  Future<int> build({bool? priority}) async {
    _notificationRepository = GetIt.instance<SprkRepository>().notification;
    _logger = GetIt.instance<LogService>().getLogger('UnreadCountNotifier');

    return _loadUnreadCount(priority: priority);
  }

  Future<int> _loadUnreadCount({bool? priority}) async {
    try {
      final response = await _notificationRepository.getUnreadCount(
        priority: priority,
      );
      _logger.d('Unread count: ${response.count}');
      return response.count;
    } catch (e, stackTrace) {
      _logger.e(
        'Error loading unread count: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return 0;
    }
  }

  /// Refresh the unread count
  Future<void> refresh({bool? priority}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadUnreadCount(priority: priority));
  }
}
