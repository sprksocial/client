import 'dart:async';

import 'package:http/http.dart' as http;

class VideoAvailabilityClient {
  VideoAvailabilityClient({
    http.Client? client,
    this.timeout = const Duration(minutes: 2),
    this.retryDelay = const Duration(seconds: 2),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;
  final Duration retryDelay;
  final Completer<void> _closed = Completer<void>();
  Timer? _retryTimer;
  Completer<void>? _retryCompletion;
  bool _started = false;

  Future<void> waitUntilReady(String videoUrl) async {
    _checkOpen();
    if (_started) {
      throw StateError('Video availability check already started');
    }
    _started = true;
    try {
      await Future.any<void>([
        _poll(Uri.parse(videoUrl)),
        _closed.future.then<void>((_) => _checkOpen()),
      ]).timeout(timeout);
    } finally {
      close();
    }
  }

  Future<void> _poll(Uri uri) async {
    while (true) {
      _checkOpen();
      // The playlist request starts import; the thumbnail request does not.
      final response = await _client.send(http.Request('GET', uri));
      await response.stream.drain<void>();
      _checkOpen();
      if (response.statusCode == 200) return;

      switch (response.statusCode) {
        case 202:
        case 500:
        case 502:
        case 503:
        case 504:
          final retrySeconds = int.tryParse(
            response.headers['retry-after'] ?? '',
          );
          final delay = retrySeconds == null
              ? retryDelay
              : Duration(seconds: retrySeconds.clamp(1, 30));
          final completion = Completer<void>();
          _retryCompletion = completion;
          _retryTimer = Timer(delay, completion.complete);
          await completion.future;
        default:
          throw http.ClientException(
            'Video playlist returned HTTP ${response.statusCode}',
            uri,
          );
      }
    }
  }

  void _checkOpen() {
    if (_closed.isCompleted) {
      throw StateError('Video availability check closed');
    }
  }

  void close() {
    if (_closed.isCompleted) return;
    _closed.complete();
    _retryTimer?.cancel();
    final completion = _retryCompletion;
    if (completion != null && !completion.isCompleted) {
      completion.complete();
    }
    _client.close();
  }
}
