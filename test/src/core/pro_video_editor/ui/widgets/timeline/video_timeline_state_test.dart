import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/timeline/video_timeline_state.dart';

void main() {
  group('VideoTimelineState trimming', () {
    test('maps source position to the trimmed timeline', () {
      final state =
          VideoTimelineState(videoDuration: const Duration(seconds: 10))
            ..setTrimRange(0.2, 0.8)
            ..setProgressFromDuration(const Duration(seconds: 4));

      expect(state.trimStartPosition, const Duration(seconds: 2));
      expect(state.trimEndPosition, const Duration(seconds: 8));
      expect(state.trimmedDuration, const Duration(seconds: 6));
      expect(state.trimmedPosition, const Duration(seconds: 2));
      expect(state.trimmedProgress, closeTo(1 / 3, 0.0001));
    });

    test('maps trimmed progress back to source progress', () {
      final state = VideoTimelineState(
        videoDuration: const Duration(seconds: 10),
      )..setTrimRange(0.2, 0.8);

      expect(state.sourceProgressFromTrimmedProgress(0), 0.2);
      expect(state.sourceProgressFromTrimmedProgress(0.5), 0.5);
      expect(state.sourceProgressFromTrimmedProgress(1), 0.8);
    });
  });
}
