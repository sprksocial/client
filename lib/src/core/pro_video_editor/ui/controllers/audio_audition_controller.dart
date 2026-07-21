import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/pro_video_editor/models/audio_audition_timing.dart';
import 'package:spark/src/core/pro_video_editor/ui/controllers/audio_audition_playback.dart';

typedef AudioAuditionErrorHandler =
    void Function(String message, Object error, StackTrace stackTrace);

enum AudioPickerPreviewStatus { idle, loading, ready, failed }

@immutable
sealed class AudioAuditionState {
  const AudioAuditionState({
    required this.previousTrack,
    required this.hostSpan,
  });

  final AudioTrack? previousTrack;
  final TrimDurationSpan hostSpan;

  bool get blocksHostInteraction;
}

@immutable
final class AudioPickerAuditionState extends AudioAuditionState {
  const AudioPickerAuditionState({
    required super.previousTrack,
    required super.hostSpan,
    required this.selectedTrack,
    required this.previewStatus,
  });

  final AudioTrack? selectedTrack;
  final AudioPickerPreviewStatus previewStatus;

  bool get canContinue =>
      selectedTrack != null && previewStatus == AudioPickerPreviewStatus.ready;

  @override
  bool get blocksHostInteraction => false;

  AudioPickerAuditionState copyWith({
    AudioTrack? selectedTrack,
    bool clearSelectedTrack = false,
    AudioPickerPreviewStatus? previewStatus,
  }) {
    return AudioPickerAuditionState(
      previousTrack: previousTrack,
      hostSpan: hostSpan,
      selectedTrack: clearSelectedTrack
          ? null
          : selectedTrack ?? this.selectedTrack,
      previewStatus: previewStatus ?? this.previewStatus,
    );
  }
}

@immutable
final class AudioRangeAuditionState extends AudioAuditionState {
  const AudioRangeAuditionState({
    required super.previousTrack,
    required super.hostSpan,
    required this.draft,
    required this.playbackSpan,
    required this.waveform,
    required this.isWaveformLoading,
    required this.isScrubbing,
  });

  final AudioTrack draft;
  final TrimDurationSpan playbackSpan;
  final List<double> waveform;
  final bool isWaveformLoading;
  final bool isScrubbing;

  @override
  bool get blocksHostInteraction => true;

  AudioRangeAuditionState copyWith({
    AudioTrack? draft,
    List<double>? waveform,
    bool? isWaveformLoading,
    bool? isScrubbing,
  }) {
    return AudioRangeAuditionState(
      draft: draft ?? this.draft,
      previousTrack: previousTrack,
      playbackSpan: playbackSpan,
      hostSpan: hostSpan,
      waveform: waveform ?? this.waveform,
      isWaveformLoading: isWaveformLoading ?? this.isWaveformLoading,
      isScrubbing: isScrubbing ?? this.isScrubbing,
    );
  }
}

@immutable
final class AudioAuditionRestoringState extends AudioAuditionState {
  const AudioAuditionRestoringState({
    required super.previousTrack,
    required super.hostSpan,
    required this.blocksHostInteraction,
  });

  @override
  final bool blocksHostInteraction;
}

class AudioAuditionResult {
  const AudioAuditionResult({required this.track, required this.waveform});

  final AudioTrack track;
  final List<double> waveform;
}

class AudioAuditionController extends ChangeNotifier {
  AudioAuditionController(
    this._playback,
    this._loadWaveform,
    this._onCommit,
    this._onError,
  );

  final AudioAuditionPlayback _playback;
  final Future<List<double>> Function(AudioTrack track) _loadWaveform;
  final ValueChanged<AudioAuditionResult> _onCommit;
  final AudioAuditionErrorHandler _onError;
  final playbackProgress = ValueNotifier(0.0);

  AudioAuditionState? _state;
  int _sessionRevision = 0;
  int _playbackRevision = 0;
  bool _isPlaybackArmed = false;
  bool _isDisposed = false;
  Future<void>? _scrubPauseFuture;

  AudioAuditionState? get state => _state;

  AudioRangeAuditionState? get rangeState => switch (_state) {
    final AudioRangeAuditionState state => state,
    _ => null,
  };

  bool get isActive => _state != null;

  Future<bool> beginPicker({
    required AudioTrack? previousTrack,
    required TrimDurationSpan hostSpan,
  }) async {
    if (_state != null) return false;
    final session = ++_sessionRevision;
    _invalidatePlayback(clearScrubPause: true);
    _setState(
      AudioPickerAuditionState(
        previousTrack: previousTrack,
        hostSpan: hostSpan,
        selectedTrack: previousTrack,
        previewStatus: previousTrack == null
            ? AudioPickerPreviewStatus.idle
            : AudioPickerPreviewStatus.ready,
      ),
    );
    await _playback.pausePreview();
    return !_isDisposed &&
        session == _sessionRevision &&
        _state is AudioPickerAuditionState;
  }

  Future<bool> selectPickerTrack(AudioTrack track) async {
    final current = _state;
    if (current is! AudioPickerAuditionState) return false;
    final request = ++_playbackRevision;
    _setState(
      current.copyWith(
        selectedTrack: track,
        previewStatus: AudioPickerPreviewStatus.loading,
      ),
    );
    bool isCurrent() {
      final state = _state;
      return !_isDisposed &&
          request == _playbackRevision &&
          state is AudioPickerAuditionState &&
          state.selectedTrack?.id == track.id;
    }

    try {
      await _playback.previewCandidate(
        track,
        current.hostSpan,
        isCurrent: isCurrent,
      );
      if (!isCurrent()) return false;
      final state = _state! as AudioPickerAuditionState;
      _setState(state.copyWith(previewStatus: AudioPickerPreviewStatus.ready));
      return true;
    } catch (error, stackTrace) {
      _onError('Failed to preview a sound picker track', error, stackTrace);
      if (!isCurrent()) return false;
      try {
        await _playback.pausePreview();
      } catch (pauseError, pauseStackTrace) {
        _onError(
          'Failed to pause audio after a sound picker failure',
          pauseError,
          pauseStackTrace,
        );
      }
      if (!isCurrent()) return false;
      final state = _state! as AudioPickerAuditionState;
      _setState(
        state.copyWith(
          clearSelectedTrack: true,
          previewStatus: AudioPickerPreviewStatus.failed,
        ),
      );
      return false;
    }
  }

  bool confirmPicker() {
    final current = _state;
    if (current is! AudioPickerAuditionState || !current.canContinue) {
      return false;
    }
    _beginRange(
      track: current.selectedTrack!,
      previousTrack: current.previousTrack,
      playbackSpan: current.hostSpan,
      hostSpan: current.hostSpan,
    );
    return true;
  }

  bool beginAdjustment({
    required AudioTrack track,
    required TrimDurationSpan hostSpan,
    required List<double> waveform,
  }) {
    if (_state != null) return false;
    _beginRange(
      track: track,
      previousTrack: track,
      playbackSpan: audioTrackPreviewRange(
        track: track,
        hostStart: hostSpan.start,
        hostEnd: hostSpan.end,
      ),
      hostSpan: hostSpan,
      waveform: waveform,
    );
    return true;
  }

  void _beginRange({
    required AudioTrack track,
    required AudioTrack? previousTrack,
    required TrimDurationSpan playbackSpan,
    required TrimDurationSpan hostSpan,
    List<double> waveform = const [],
  }) {
    final session = ++_sessionRevision;
    _invalidatePlayback(clearScrubPause: true);
    final draft = audioTrackForAuditionRange(track, playbackSpan: playbackSpan);
    _setState(
      AudioRangeAuditionState(
        draft: draft,
        previousTrack: previousTrack,
        playbackSpan: playbackSpan,
        hostSpan: hostSpan,
        waveform: waveform,
        isWaveformLoading: waveform.isEmpty,
        isScrubbing: false,
      ),
    );
    if (waveform.isEmpty) {
      unawaited(_loadSessionWaveform(draft, session: session));
    }
    unawaited(_restartPreview());
  }

  Future<void> _loadSessionWaveform(
    AudioTrack track, {
    required int session,
  }) async {
    try {
      final waveform = await _loadWaveform(track);
      final current = _state;
      if (_isDisposed ||
          current is! AudioRangeAuditionState ||
          session != _sessionRevision ||
          current.draft.id != track.id) {
        return;
      }
      _setState(current.copyWith(waveform: waveform, isWaveformLoading: false));
    } catch (error, stackTrace) {
      _onError('Failed to extract audio picker waveform', error, stackTrace);
      final current = _state;
      if (_isDisposed ||
          current is! AudioRangeAuditionState ||
          session != _sessionRevision) {
        return;
      }
      _setState(current.copyWith(isWaveformLoading: false));
    }
  }

  Future<void> pauseForScrub() async {
    final current = _state;
    if (current is! AudioRangeAuditionState) return;
    final request = _invalidatePlayback(clearScrubPause: false);
    _setState(current.copyWith(isScrubbing: true));
    final previousPause = _scrubPauseFuture;
    final pause = _pausePreviewForScrub();
    final Future<void> barrier = previousPause == null
        ? pause
        : Future.wait<void>([previousPause, pause]).then<void>((_) {});
    _scrubPauseFuture = barrier;
    await barrier;
    if (request == _playbackRevision && identical(_scrubPauseFuture, barrier)) {
      _scrubPauseFuture = null;
    }
  }

  Future<void> _pausePreviewForScrub() async {
    try {
      await _playback.pausePreview();
    } catch (error, stackTrace) {
      _onError('Failed to pause audio range preview', error, stackTrace);
    }
  }

  Future<void> previewRange(Duration sourceStart) async {
    final session = _sessionRevision;
    final request = _playbackRevision;
    final pause = _scrubPauseFuture;
    await pause;
    final current = _state;
    if (_isDisposed ||
        session != _sessionRevision ||
        request != _playbackRevision) {
      return;
    }
    if (current is! AudioRangeAuditionState) return;
    final draft = audioTrackForAuditionRange(
      current.draft,
      playbackSpan: current.playbackSpan,
      sourceStart: sourceStart,
    );
    _setState(current.copyWith(draft: draft, isScrubbing: false));
    unawaited(_restartPreview());
  }

  Future<void> _restartPreview() async {
    final current = _state;
    if (current is! AudioRangeAuditionState) return;
    final request = _invalidatePlayback(clearScrubPause: false);
    final session = _sessionRevision;
    bool isCurrent() =>
        !_isDisposed &&
        request == _playbackRevision &&
        session == _sessionRevision &&
        _state is AudioRangeAuditionState;

    try {
      await _playback.prepareRangePreview(
        current.draft,
        current.playbackSpan,
        isCurrent: isCurrent,
      );
      if (!isCurrent()) return;
      _isPlaybackArmed = true;
      await _playback.startRangePreview(
        current.draft,
        current.playbackSpan,
        isCurrent: isCurrent,
      );
    } catch (error, stackTrace) {
      await _failPreview(
        request: request,
        message: 'Failed to start audio range preview',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  AudioRangeAuditionState? handlePlaybackSnapshot(
    AudioAuditionPlaybackSnapshot snapshot,
  ) {
    final current = _state;
    if (current is! AudioRangeAuditionState) return null;
    if (!current.isScrubbing) {
      playbackProgress.value = audioRangePlaybackProgress(
        position: snapshot.position,
        rangeStart: current.playbackSpan.start,
        rangeEnd: current.playbackSpan.end,
      );
    }
    final loopTarget = audioRangeLoopTarget(
      isPlaybackArmed: _isPlaybackArmed,
      isPlaybackCompleted: snapshot.isCompleted,
      position: snapshot.position,
      range: current.playbackSpan,
    );
    if (loopTarget != null) {
      _isPlaybackArmed = false;
      unawaited(_restartPreview());
      return null;
    }
    return current;
  }

  bool finish(Duration sourceStart) {
    final current = _state;
    if (current is! AudioRangeAuditionState) return false;
    _sessionRevision++;
    _invalidatePlayback(clearScrubPause: true);
    final track = audioTrackForAuditionRange(
      current.draft,
      playbackSpan: current.playbackSpan,
      sourceStart: sourceStart,
    );
    _onCommit(AudioAuditionResult(track: track, waveform: current.waveform));
    _setState(null);
    return true;
  }

  Future<void> cancel() async {
    final current = _state;
    if (current == null || current is AudioAuditionRestoringState) return;
    final session = ++_sessionRevision;
    _invalidatePlayback(clearScrubPause: true);
    _setState(
      AudioAuditionRestoringState(
        previousTrack: current.previousTrack,
        hostSpan: current.hostSpan,
        blocksHostInteraction: current.blocksHostInteraction,
      ),
    );
    bool isCurrent() =>
        !_isDisposed &&
        session == _sessionRevision &&
        _state is AudioAuditionRestoringState;

    try {
      await _playback.pausePreview();
      if (!isCurrent()) return;
      await _playback.restorePrevious(
        current.previousTrack,
        current.hostSpan,
        isCurrent: isCurrent,
      );
    } catch (error, stackTrace) {
      _onError(
        'Failed to restore audio after cancelling sound selection',
        error,
        stackTrace,
      );
      if (!isCurrent()) return;
      try {
        await _playback.pausePreview();
      } catch (pauseError, pauseStackTrace) {
        _onError(
          'Failed to pause audio after sound restoration failure',
          pauseError,
          pauseStackTrace,
        );
      }
    }
    if (isCurrent()) _setState(null);
  }

  Future<void> _failPreview({
    required int request,
    required String message,
    required Object error,
    required StackTrace stackTrace,
  }) async {
    _onError(message, error, stackTrace);
    final current = _state;
    if (_isDisposed ||
        current is! AudioRangeAuditionState ||
        request != _playbackRevision) {
      return;
    }
    _invalidatePlayback(clearScrubPause: true);
    _setState(current.copyWith(isScrubbing: true));
    try {
      await _playback.pausePreview();
    } catch (pauseError, pauseStackTrace) {
      _onError(
        'Failed to pause audio after range preview failure',
        pauseError,
        pauseStackTrace,
      );
    }
  }

  void _setState(AudioAuditionState? value) {
    if (_isDisposed) return;
    _state = value;
    notifyListeners();
  }

  int _invalidatePlayback({required bool clearScrubPause}) {
    _isPlaybackArmed = false;
    if (clearScrubPause) _scrubPauseFuture = null;
    playbackProgress.value = 0;
    return ++_playbackRevision;
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _sessionRevision++;
    _invalidatePlayback(clearScrubPause: true);
    _state = null;
    playbackProgress.dispose();
    super.dispose();
  }
}
