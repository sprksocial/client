import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/media/media_playback_suspension_provider.dart';

typedef MediaPlaybackGateBuilder =
    Widget Function(BuildContext context, bool shouldPlay);

class MediaPlaybackGate extends ConsumerStatefulWidget {
  const MediaPlaybackGate({
    required this.isActive,
    required this.builder,
    super.key,
  });

  final bool isActive;
  final MediaPlaybackGateBuilder builder;

  @override
  ConsumerState<MediaPlaybackGate> createState() => _MediaPlaybackGateState();
}

class _MediaPlaybackGateState extends ConsumerState<MediaPlaybackGate> {
  AppLifecycleListener? _lifecycleListener;
  bool _isAppInForeground = true;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onInactive: _markAppUnfocused,
      onHide: _markAppUnfocused,
      onPause: _markAppUnfocused,
      onShow: _markAppFocused,
      onResume: _markAppFocused,
    );
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    super.dispose();
  }

  void _markAppUnfocused() {
    if (!_isAppInForeground) return;
    setState(() {
      _isAppInForeground = false;
    });
  }

  void _markAppFocused() {
    if (_isAppInForeground) return;
    setState(() {
      _isAppInForeground = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaPlaybackSuspended = ref.watch(mediaPlaybackSuspendedProvider);
    final shouldPlay =
        widget.isActive && !mediaPlaybackSuspended && _isAppInForeground;

    return widget.builder(context, shouldPlay);
  }
}
