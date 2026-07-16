import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/pro_video_editor/ui/controllers/video_editor_media_session.dart';
import 'package:video_player/video_player.dart';

void main() {
  group('VideoEditorTimelineSeekCoordinator', () {
    test('latest seek supersedes a pending timeline seek safely', () async {
      final controller = _ControlledVideoPlayerController();
      final coordinator = VideoEditorTimelineSeekCoordinator(
        videoController: controller,
        onError: (_, _) {},
      );

      final first = coordinator.seekLatest(const Duration(seconds: 1));
      final superseded = coordinator.seekLatest(const Duration(seconds: 2));
      final trim = coordinator.seekLatest(const Duration(seconds: 3));

      await superseded;
      expect(controller.targets, [const Duration(seconds: 1)]);

      controller.completeNextSeek();
      await first;
      await Future<void>.delayed(Duration.zero);
      expect(controller.targets, [
        const Duration(seconds: 1),
        const Duration(seconds: 3),
      ]);

      controller.completeNextSeek();
      await trim;
      await coordinator.dispose();
    });

    test(
      'dispose waits for an active seek and suppresses its late error',
      () async {
        final controller = _ControlledVideoPlayerController();
        final errors = <Object>[];
        final coordinator = VideoEditorTimelineSeekCoordinator(
          videoController: controller,
          onError: (error, _) => errors.add(error),
        );
        final seek = coordinator.seekLatest(const Duration(seconds: 1));
        var disposed = false;

        final disposal = coordinator.dispose().then((_) => disposed = true);
        await Future<void>.delayed(Duration.zero);
        expect(disposed, isFalse);

        controller.failNextSeek(StateError('late seek failure'));
        await disposal;
        await seek;
        expect(errors, isEmpty);
      },
    );
  });
}

class _ControlledVideoPlayerController extends VideoPlayerController {
  _ControlledVideoPlayerController() : super.asset('unused');

  final List<Duration> targets = [];
  final List<Completer<void>> _seeks = [];

  @override
  Future<void> seekTo(Duration position) {
    targets.add(position);
    final completer = Completer<void>();
    _seeks.add(completer);
    return completer.future;
  }

  void completeNextSeek() => _seeks.removeAt(0).complete();

  void failNextSeek(Object error) => _seeks.removeAt(0).completeError(error);
}
