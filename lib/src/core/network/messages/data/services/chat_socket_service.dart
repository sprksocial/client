import 'package:get_it/get_it.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:sparksocial/src/core/auth/data/repositories/auth_repository.dart';
import 'package:sparksocial/src/core/config/app_config.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';

/// Service responsible for maintaining the Socket.io connection used by chat.
///
/// This service exposes a single [socket] getter that returns a connected
/// [IO.Socket] instance. The same instance is reused for the lifetime of the
/// application to ensure we do not create multiple connections for the same
/// host, which could lead to duplicated events and increased resource usage.
class ChatSocketService {
  ChatSocketService._();

  // Singleton instance (registered in GetIt but also exposed via factory).
  static final ChatSocketService _instance = ChatSocketService._();
  factory ChatSocketService() => _instance;

  final _sl = GetIt.instance;
  final _logger = GetIt.instance<LogService>().getLogger('ChatSocketService');

  io.Socket? _socket;

  /// Returns an active Socket.io connection or creates one if it does not exist.
  ///
  /// The JWT access token from the current [AuthRepository] session is included
  /// in the `Authorization` header so that the backend can authenticate the
  /// connection and automatically derive the user DID.
  Future<io.Socket> get socket async {
    if (_socket != null && _socket!.connected) {
      return _socket!;
    }

    final authRepository = _sl<AuthRepository>();
    if (!authRepository.isAuthenticated || authRepository.session == null) {
      _logger.w('Attempted to create chat socket without an authenticated user');
      throw Exception('User is not authenticated');
    }

    final jwt = authRepository.session!.accessJwt;
    final url = '${AppConfig.chatServiceUrl}/chat';

    _logger.i('Connecting to chat socket at $url');

    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket']) // Required for Flutter native
          .enableForceNew()
          .enableReconnection()
          .setExtraHeaders({'Authorization': 'Bearer $jwt'})
          .build(),
    );

    _socket!.onConnect((_) => _logger.i('Chat socket connected'));
    _socket!.onDisconnect((_) => _logger.w('Chat socket disconnected'));
    _socket!.onConnectError((err) => _logger.e('Chat socket connection error', error: err));

    return _socket!;
  }
}
