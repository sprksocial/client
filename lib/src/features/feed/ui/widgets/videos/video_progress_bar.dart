import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spark/src/core/design_system/components/atoms/video_progress_bar.dart'
    as ds;

class FeedVideoProgressBar extends StatefulWidget {
  const FeedVideoProgressBar({
    required this.controller,
    super.key,
    this.enableGestures = true,
    this.tapTargetHeight = 30,
    this.debugShowHitbox = false,
    this.onSeekStart,
    this.onSeek,
    this.onSeekEnd,
    this.updateInterval = const Duration(milliseconds: 250),
  });

  final BetterPlayerController controller;
  final bool enableGestures;
  final double tapTargetHeight;
  final bool debugShowHitbox;
  final ValueChanged<Duration>? onSeekStart;
  final ValueChanged<Duration>? onSeek;
  final ValueChanged<Duration>? onSeekEnd;
  final Duration updateInterval;

  @override
  State<FeedVideoProgressBar> createState() => _FeedVideoProgressBarState();
}

class _FeedVideoProgressBarState extends State<FeedVideoProgressBar> {
  Duration _total = Duration.zero;
  Duration _position = Duration.zero;
  List<DurationRange> _buffered = const [];
  Timer? _ticker;
  bool _dragging = false;
  Duration? _pendingSeek;

  @override
  void initState() {
    super.initState();
    _attach();
  }

  @override
  void didUpdateWidget(covariant FeedVideoProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detach(oldWidget.controller);
      _attach();
    }
  }

  void _attach() {
    _updateFromController();
    widget.controller.addVideoListener(_listener);
    _ticker = Timer.periodic(widget.updateInterval, (_) => _throttledUpdate());
  }

  void _detach(BetterPlayerController controller) {
    controller.removeVideoListener(_listener);
    _ticker?.cancel();
  }

  void _listener() {
    final v = widget.controller.videoPlayerValue;
    if (v == null) return;
    if (v.duration != _total) {
      _updateFromController(force: true);
    }
  }

  void _throttledUpdate() {
    if (!mounted) return;
    _updateFromController();
  }

  void _updateFromController({bool force = false}) {
    final v = widget.controller.videoPlayerValue;
    if (v == null) return;
    final pos = v.position;
    final dur = v.duration ?? Duration.zero;
    final buf = v.buffered;

    if (!force &&
        !_dragging &&
        pos == _position &&
        dur == _total &&
        listEquals(buf, _buffered)) {
      return;
    }

    if (!_dragging) {
      setState(() {
        _position = pos;
        _total = dur;
        _buffered = buf;
      });
    } else if (force) {
      setState(() => _total = dur);
    }
  }

  @override
  void dispose() {
    _detach(widget.controller);
    super.dispose();
  }

  double get _progressFraction {
    if (_total.inMilliseconds == 0) return 0;
    final effective = _dragging && _pendingSeek != null
        ? _pendingSeek!
        : _position;
    return effective.inMilliseconds / _total.inMilliseconds;
  }

  List<(double, double)> get _bufferedFractions {
    if (_total.inMilliseconds == 0) return const [];
    return _buffered
        .map<(double, double)>(
          (r) => (
            (r.start.inMilliseconds / _total.inMilliseconds).clamp(0.0, 1.0),
            (r.end.inMilliseconds / _total.inMilliseconds).clamp(0.0, 1.0),
          ),
        )
        .toList(growable: false);
  }

  void _handleDragStart() {
    if (_dragging) return;
    _dragging = true;
    _pendingSeek = _position;
    widget.onSeekStart?.call(_position);
  }

  void _handleDragUpdate(double fraction) {
    if (_total == Duration.zero) return;
    final targetMs = (fraction * _total.inMilliseconds)
        .clamp(0, _total.inMilliseconds)
        .toInt();
    final target = Duration(milliseconds: targetMs);
    _pendingSeek = target;
    widget.onSeek?.call(target);
    setState(() {}); // update visual preview
  }

  Future<void> _handleDragEnd(double fraction) async {
    if (_total == Duration.zero) {
      _dragging = false;
      return;
    }
    final finalMs = (fraction * _total.inMilliseconds)
        .clamp(0, _total.inMilliseconds)
        .toInt();
    final finalPos = Duration(milliseconds: finalMs);
    _pendingSeek = finalPos;
    setState(() {});
    try {
      await widget.controller.seekTo(finalPos);
    } catch (_) {
      // Video controller may be disposed during seek, ignore error
    }
    if (!mounted) return;
    widget.onSeekEnd?.call(finalPos);
    _dragging = false;
    _pendingSeek = null;
  }

  @override
  Widget build(BuildContext context) {
    final showThumb = widget.enableGestures && _dragging;
    return ds.DSVideoProgressBar(
      progress: _progressFraction,
      bufferedSegments: _bufferedFractions,
      showThumb: showThumb,
      enableGestures: widget.enableGestures,
      tapTargetHeight: widget.tapTargetHeight,
      debugShowHitbox: widget.debugShowHitbox,
      onDragStart: _handleDragStart,
      onDragUpdate: _handleDragUpdate,
      onDragEnd: _handleDragEnd,
      height: 3,
      thumbRadius: 5,
    );
  }
}
