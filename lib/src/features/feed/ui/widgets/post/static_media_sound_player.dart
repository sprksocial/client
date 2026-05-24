import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

abstract class StaticMediaAudioPlayer {
  Future<void> playUrl(String url, {String? mimeType});
  Future<void> resume();
  Future<void> pause();
  Future<void> dispose();
}

class AudioplayersStaticMediaAudioPlayer implements StaticMediaAudioPlayer {
  AudioplayersStaticMediaAudioPlayer({AudioPlayer? audioPlayer})
    : _audioPlayer = audioPlayer ?? AudioPlayer();

  final AudioPlayer _audioPlayer;

  @override
  Future<void> playUrl(String url, {String? mimeType}) async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(UrlSource(url, mimeType: mimeType));
  }

  @override
  Future<void> resume() => _audioPlayer.resume();

  @override
  Future<void> pause() => _audioPlayer.pause();

  @override
  Future<void> dispose() => _audioPlayer.dispose();
}

class StaticMediaSoundController {
  StaticMediaSoundController({StaticMediaAudioPlayer? audioPlayer})
    : _audioPlayer = audioPlayer ?? AudioplayersStaticMediaAudioPlayer();

  final StaticMediaAudioPlayer _audioPlayer;
  String? _loadedUrl;
  String? _loadedMimeType;
  bool _isPlaying = false;
  String? _desiredUrl;
  String? _desiredMimeType;
  bool _shouldPlayDesiredUrl = false;
  int _desiredRevision = 0;
  bool _isSyncing = false;

  Future<void> sync({
    required String? audioUrl,
    String? mimeType,
    required bool shouldPlay,
  }) async {
    final url = audioUrl?.trim();
    _desiredUrl = url == null || url.isEmpty ? null : url;
    _desiredMimeType = mimeType?.trim();
    _shouldPlayDesiredUrl = shouldPlay;
    _desiredRevision++;

    if (_isSyncing) return;

    await _syncDesiredState();
  }

  Future<void> _syncDesiredState() async {
    _isSyncing = true;
    try {
      while (true) {
        final revision = _desiredRevision;
        final desiredUrl = _desiredUrl;
        final desiredMimeType = _desiredMimeType;
        final shouldPlay = _shouldPlayDesiredUrl;

        if (desiredUrl == null || !shouldPlay) {
          if (_isPlaying) {
            await _audioPlayer.pause();
            _isPlaying = false;
          }
        } else if (_loadedUrl != desiredUrl ||
            _loadedMimeType != desiredMimeType) {
          await _audioPlayer.playUrl(desiredUrl, mimeType: desiredMimeType);
          _loadedUrl = desiredUrl;
          _loadedMimeType = desiredMimeType;
          _isPlaying = true;
        } else if (!_isPlaying) {
          await _audioPlayer.resume();
          _isPlaying = true;
        }

        if (revision == _desiredRevision) return;
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

class StaticMediaSoundPlayer extends StatefulWidget {
  const StaticMediaSoundPlayer({
    required this.child,
    required this.audioUrl,
    required this.shouldPlay,
    super.key,
    this.mimeType,
    this.controller,
  });

  final Widget child;
  final String? audioUrl;
  final String? mimeType;
  final bool shouldPlay;
  final StaticMediaSoundController? controller;

  @override
  State<StaticMediaSoundPlayer> createState() => _StaticMediaSoundPlayerState();
}

class _StaticMediaSoundPlayerState extends State<StaticMediaSoundPlayer> {
  late final StaticMediaSoundController _controller =
      widget.controller ?? StaticMediaSoundController();
  late final bool _ownsController = widget.controller == null;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(StaticMediaSoundPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl ||
        oldWidget.mimeType != widget.mimeType ||
        oldWidget.shouldPlay != widget.shouldPlay) {
      _sync();
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      unawaited(_controller.dispose());
    } else {
      unawaited(
        _controller.sync(
          audioUrl: widget.audioUrl,
          mimeType: widget.mimeType,
          shouldPlay: false,
        ),
      );
    }
    super.dispose();
  }

  void _sync() {
    unawaited(
      _controller
          .sync(
            audioUrl: widget.audioUrl,
            mimeType: widget.mimeType,
            shouldPlay: widget.shouldPlay,
          )
          .catchError((_) {}),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
