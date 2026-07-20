import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/pro_video_editor/models/audio_audition_timing.dart';
import 'package:spark/src/core/pro_video_editor/ui/controllers/video_editor_media_session.dart';
import 'package:video_player/video_player.dart';

typedef AudioAuditionErrorHandler =
    void Function(String message, Object error, StackTrace stackTrace);

enum AudioPickerPreviewStatus { idle, loading, ready, failed }

@immutable
sealed class AudioAuditionState {
  const AudioAuditionState({
    required this.previousTrack,
    required this.editorSpan,
  });

  final AudioTrack? previousTrack;
  final TrimDurationSpan editorSpan;

  bool get suspendsChrome;
}

@immutable
final class AudioPickerAuditionState extends AudioAuditionState {
  const AudioPickerAuditionState({
    required super.previousTrack,
    required super.editorSpan,
    required this.selectedTrack,
    required this.previewStatus,
  });

  final AudioTrack? selectedTrack;
  final AudioPickerPreviewStatus previewStatus;

  bool get canContinue =>
      selectedTrack != null && previewStatus == AudioPickerPreviewStatus.ready;

  @override
  bool get suspendsChrome => false;

  AudioPickerAuditionState copyWith({
    AudioTrack? selectedTrack,
    bool clearSelectedTrack = false,
    AudioPickerPreviewStatus? previewStatus,
  }) {
    return AudioPickerAuditionState(
      previousTrack: previousTrack,
      editorSpan: editorSpan,
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
    required super.editorSpan,
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
  bool get suspendsChrome => true;

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
      editorSpan: editorSpan,
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
    required super.editorSpan,
    required this.suspendsChrome,
  });

  @override
  final bool suspendsChrome;
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

  final VideoEditorAudioPlayback _playback;
  final Future<List<double>> Function(AudioTrack track) _loadWaveform;
  final ValueChanged<AudioAuditionResult> _onCommit;
  final AudioAuditionErrorHandler _onError;
  final playbackProgress = ValueNotifier(0.0);

  AudioAuditionState? _state;
  int _sessionRevision = 0;
  int _playbackRevision = 0;
  bool _isPlaybackArmed = false;
  bool _isDisposed = false;

  AudioAuditionState? get state => _state;

  AudioRangeAuditionState? get rangeState => switch (_state) {
    final AudioRangeAuditionState state => state,
    _ => null,
  };

  bool get isActive => _state != null;

  void beginPicker({
    required AudioTrack? previousTrack,
    required TrimDurationSpan editorSpan,
  }) {
    _sessionRevision++;
    _playbackRevision++;
    _isPlaybackArmed = false;
    playbackProgress.value = 0;
    _setState(
      AudioPickerAuditionState(
        previousTrack: previousTrack,
        editorSpan: editorSpan,
        selectedTrack: previousTrack,
        previewStatus: previousTrack == null
            ? AudioPickerPreviewStatus.idle
            : AudioPickerPreviewStatus.ready,
      ),
    );
    _playback.pauseEditor();
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
      await _playback.previewPickerTrack(
        track,
        current.editorSpan,
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
        await _playback.stopAudio();
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
      playbackSpan: current.editorSpan,
      editorSpan: current.editorSpan,
    );
    return true;
  }

  void beginAdjustment({
    required AudioTrack track,
    required TrimDurationSpan editorSpan,
    required List<double> waveform,
  }) {
    _beginRange(
      track: track,
      previousTrack: track,
      playbackSpan: audioTrackPreviewRange(
        track: track,
        videoStart: editorSpan.start,
        videoEnd: editorSpan.end,
      ),
      editorSpan: editorSpan,
      waveform: waveform,
    );
  }

  void _beginRange({
    required AudioTrack track,
    required AudioTrack? previousTrack,
    required TrimDurationSpan playbackSpan,
    required TrimDurationSpan editorSpan,
    List<double> waveform = const [],
  }) {
    final session = ++_sessionRevision;
    _playbackRevision++;
    _isPlaybackArmed = false;
    playbackProgress.value = 0;
    final draft = audioTrackForAuditionRange(track, playbackSpan: playbackSpan);
    _playback.setTrack(draft);
    _setState(
      AudioRangeAuditionState(
        draft: draft,
        previousTrack: previousTrack,
        playbackSpan: playbackSpan,
        editorSpan: editorSpan,
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

  void pauseForScrub() {
    final current = _state;
    if (current is! AudioRangeAuditionState) return;
    _playbackRevision++;
    _isPlaybackArmed = false;
    playbackProgress.value = 0;
    _playback.pauseEditor();
    _setState(current.copyWith(isScrubbing: true));
  }

  void previewRange(Duration sourceStart) {
    final current = _state;
    if (current is! AudioRangeAuditionState) return;
    final draft = audioTrackForAuditionRange(
      current.draft,
      playbackSpan: current.playbackSpan,
      sourceStart: sourceStart,
    );
    _playback.setTrack(draft);
    _setState(current.copyWith(draft: draft, isScrubbing: false));
    unawaited(_restartPreview());
  }

  Future<void> _restartPreview() async {
    final current = _state;
    if (current is! AudioRangeAuditionState) return;
    final request = ++_playbackRevision;
    final session = _sessionRevision;
    _isPlaybackArmed = false;
    playbackProgress.value = 0;
    bool isCurrent() =>
        !_isDisposed &&
        request == _playbackRevision &&
        session == _sessionRevision &&
        _state is AudioRangeAuditionState;

    try {
      await _playback.preparePreview(
        current.draft,
        current.playbackSpan,
        isCurrent: isCurrent,
      );
      if (!isCurrent()) return;
      _playback.requestEditorPlay();
    } catch (error, stackTrace) {
      await _failPreview(
        request: request,
        message: 'Failed to start audio range preview',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  bool handlePlayRequested() {
    final current = _state;
    if (current is! AudioRangeAuditionState) return false;
    final request = _playbackRevision;
    final session = _sessionRevision;
    _isPlaybackArmed = true;
    bool isCurrent() =>
        !_isDisposed &&
        request == _playbackRevision &&
        session == _sessionRevision &&
        _state is AudioRangeAuditionState;
    unawaited(_playPreview(current, request: request, isCurrent: isCurrent));
    return true;
  }

  Future<void> _playPreview(
    AudioRangeAuditionState current, {
    required int request,
    required bool Function() isCurrent,
  }) async {
    try {
      await _playback.playTrack(
        current.draft,
        current.playbackSpan,
        isCurrent: isCurrent,
      );
    } catch (error, stackTrace) {
      await _failPreview(
        request: request,
        message: 'Failed to play audio range preview',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  bool handleVideoValue(VideoPlayerValue videoValue) {
    final current = _state;
    if (current == null) return false;
    if (current is! AudioRangeAuditionState) return true;
    if (!current.isScrubbing) {
      playbackProgress.value = audioRangePlaybackProgress(
        position: videoValue.position,
        rangeStart: current.playbackSpan.start,
        rangeEnd: current.playbackSpan.end,
      );
    }
    final loopTarget = audioRangeLoopTarget(
      isPlaybackArmed: _isPlaybackArmed,
      isVideoCompleted: videoValue.isCompleted,
      position: videoValue.position,
      range: current.playbackSpan,
    );
    if (loopTarget != null) {
      _isPlaybackArmed = false;
      unawaited(_restartPreview());
      return true;
    }
    unawaited(_synchronize(current, videoValue));
    return true;
  }

  Future<void> _synchronize(
    AudioRangeAuditionState current,
    VideoPlayerValue videoValue,
  ) async {
    try {
      await _playback.synchronize(
        current.draft,
        current.playbackSpan,
        videoValue,
      );
    } catch (error, stackTrace) {
      _onError('Failed to synchronize audio range preview', error, stackTrace);
    }
  }

  bool finish(Duration sourceStart) {
    final current = _state;
    if (current is! AudioRangeAuditionState) return false;
    _sessionRevision++;
    _playbackRevision++;
    _isPlaybackArmed = false;
    playbackProgress.value = 0;
    final track = audioTrackForAuditionRange(
      current.draft,
      playbackSpan: current.playbackSpan,
      sourceStart: sourceStart,
    );
    _playback.setTrack(track);
    _onCommit(AudioAuditionResult(track: track, waveform: current.waveform));
    _setState(null);
    return true;
  }

  Future<void> cancel() async {
    final current = _state;
    if (current == null || current is AudioAuditionRestoringState) return;
    final session = ++_sessionRevision;
    _playbackRevision++;
    _isPlaybackArmed = false;
    playbackProgress.value = 0;
    _playback.pauseEditor();
    _playback.setTrack(current.previousTrack);
    _setState(
      AudioAuditionRestoringState(
        previousTrack: current.previousTrack,
        editorSpan: current.editorSpan,
        suspendsChrome: current.suspendsChrome,
      ),
    );
    bool isCurrent() =>
        !_isDisposed &&
        session == _sessionRevision &&
        _state is AudioAuditionRestoringState;

    try {
      await _playback.restore(
        current.previousTrack,
        current.editorSpan,
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
        await _playback.stopAudio();
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
    _isPlaybackArmed = false;
    playbackProgress.value = 0;
    _playback.pauseEditor();
    _setState(current.copyWith(isScrubbing: true));
    try {
      await _playback.stopAudio();
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

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _sessionRevision++;
    _playbackRevision++;
    _state = null;
    playbackProgress.dispose();
    super.dispose();
  }
}
