import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/features/feed/ui/widgets/post/static_media_sound_player.dart';

void main() {
  group('StaticMediaSoundController', () {
    test('plays, pauses, resumes, and switches static media audio', () async {
      final player = _FakeStaticMediaAudioPlayer();
      final controller = StaticMediaSoundController(audioPlayer: player);

      await controller.sync(
        audioUrl: 'https://example.com/a.mp3',
        shouldPlay: true,
      );
      await controller.sync(
        audioUrl: 'https://example.com/a.mp3',
        shouldPlay: true,
      );
      await controller.sync(
        audioUrl: 'https://example.com/a.mp3',
        shouldPlay: false,
      );
      await controller.sync(
        audioUrl: 'https://example.com/a.mp3',
        shouldPlay: true,
      );
      await controller.sync(
        audioUrl: 'https://example.com/b.mp3',
        shouldPlay: true,
      );
      await controller.dispose();

      expect(player.calls, [
        'play:https://example.com/a.mp3:',
        'pause',
        'resume',
        'play:https://example.com/b.mp3:',
        'dispose',
      ]);
    });

    test(
      'does not play when static media audio is unavailable or inactive',
      () async {
        final player = _FakeStaticMediaAudioPlayer();
        final controller = StaticMediaSoundController(audioPlayer: player);

        await controller.sync(audioUrl: null, shouldPlay: true);
        await controller.sync(audioUrl: '', shouldPlay: true);
        await controller.sync(
          audioUrl: 'https://example.com/a.mp3',
          shouldPlay: false,
        );
        await controller.dispose();

        expect(player.calls, ['dispose']);
      },
    );

    test('pauses when playback finishes after becoming inactive', () async {
      final player = _SlowPlayStaticMediaAudioPlayer();
      final controller = StaticMediaSoundController(audioPlayer: player);

      final playFuture = controller.sync(
        audioUrl: 'https://example.com/a.mp3',
        shouldPlay: true,
      );
      await controller.sync(
        audioUrl: 'https://example.com/a.mp3',
        shouldPlay: false,
      );

      player.completePlay();
      await playFuture;

      expect(player.calls, ['play:https://example.com/a.mp3:', 'pause']);
    });

    test('applies latest URL after an in-flight play completes', () async {
      final player = _ControlledPlayStaticMediaAudioPlayer();
      final controller = StaticMediaSoundController(audioPlayer: player);

      final playFuture = controller.sync(
        audioUrl: 'https://example.com/a.mp3',
        shouldPlay: true,
      );
      await Future<void>.delayed(Duration.zero);

      unawaited(
        controller.sync(
          audioUrl: 'https://example.com/b.mp3',
          shouldPlay: true,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(player.calls, ['play:https://example.com/a.mp3:']);

      player.completeNextPlay();
      await Future<void>.delayed(Duration.zero);

      expect(player.calls, [
        'play:https://example.com/a.mp3:',
        'play:https://example.com/b.mp3:',
      ]);

      player.completeNextPlay();
      await playFuture;
    });

    test('replays when the URL MIME type changes', () async {
      final player = _FakeStaticMediaAudioPlayer();
      final controller = StaticMediaSoundController(audioPlayer: player);

      await controller.sync(
        audioUrl: 'https://example.com/audio',
        mimeType: 'audio/mpeg',
        shouldPlay: true,
      );
      await controller.sync(
        audioUrl: 'https://example.com/audio',
        mimeType: 'audio/mp4',
        shouldPlay: true,
      );

      expect(player.calls, [
        'play:https://example.com/audio:audio/mpeg',
        'play:https://example.com/audio:audio/mp4',
      ]);
    });
  });
}

class _FakeStaticMediaAudioPlayer implements StaticMediaAudioPlayer {
  final List<String> calls = [];

  @override
  Future<void> playUrl(String url, {String? mimeType}) async {
    calls.add('play:$url:${mimeType ?? ''}');
  }

  @override
  Future<void> resume() async {
    calls.add('resume');
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
  }
}

class _ControlledPlayStaticMediaAudioPlayer implements StaticMediaAudioPlayer {
  final List<String> calls = [];
  final List<Completer<void>> _playCompleters = [];

  void completeNextPlay() {
    _playCompleters.removeAt(0).complete();
  }

  @override
  Future<void> playUrl(String url, {String? mimeType}) async {
    calls.add('play:$url:${mimeType ?? ''}');
    final completer = Completer<void>();
    _playCompleters.add(completer);
    await completer.future;
  }

  @override
  Future<void> resume() async {
    calls.add('resume');
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
  }
}

class _SlowPlayStaticMediaAudioPlayer implements StaticMediaAudioPlayer {
  final List<String> calls = [];
  final Completer<void> _playCompleter = Completer<void>();

  void completePlay() {
    _playCompleter.complete();
  }

  @override
  Future<void> playUrl(String url, {String? mimeType}) async {
    calls.add('play:$url:${mimeType ?? ''}');
    await _playCompleter.future;
  }

  @override
  Future<void> resume() async {
    calls.add('resume');
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
  }
}
