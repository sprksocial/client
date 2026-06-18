import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final _mediaPlaybackSuspensionCountProvider = StateProvider<int>((ref) => 0);

final mediaPlaybackSuspendedProvider = Provider<bool>(
  (ref) => ref.watch(_mediaPlaybackSuspensionCountProvider) > 0,
);

MediaPlaybackSuspension suspendMediaPlayback(ProviderContainer container) {
  final controller = container.read(
    _mediaPlaybackSuspensionCountProvider.notifier,
  );
  controller.state += 1;
  return MediaPlaybackSuspension._(container);
}

class MediaPlaybackSuspension {
  MediaPlaybackSuspension._(this._container);

  final ProviderContainer _container;
  bool _released = false;

  void release() {
    if (_released) return;
    _released = true;

    final controller = _container.read(
      _mediaPlaybackSuspensionCountProvider.notifier,
    );
    controller.state -= 1;
  }
}
