import 'package:flutter/material.dart';
import 'package:pro_video_editor/pro_video_editor.dart';

/// A dialog that displays real-time export progress for video generation.
///
/// Listens to the ProVideoEditor progress stream and shows a circular
/// progress indicator with percentage text.
class VideoProgressAlert extends StatelessWidget {
  const VideoProgressAlert({super.key, this.taskId = ''});

  /// Optional taskId to scope the progress stream.
  final String taskId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ModalBarrier(
          dismissible: false,
          color: Colors.black54,
        ),
        Center(
          child: Theme(
            data: Theme.of(context),
            child: AlertDialog(
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              content: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 260),
                child: _buildProgressBody(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBody() {
    return StreamBuilder<ProgressModel>(
      stream: ProVideoEditor.instance.progressStreamById(taskId),
      builder: (context, snapshot) {
        final progress = snapshot.data?.progress ?? 0;
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress),
          duration: const Duration(milliseconds: 300),
          builder: (context, animatedValue, _) {
            final percent = (animatedValue * 100).clamp(0, 100).toStringAsFixed(0);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 6),
                SizedBox(
                  width: 42,
                  height: 42,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(value: animatedValue == 0 ? null : animatedValue),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Exporting video…'),
                    const SizedBox(height: 6),
                    Text('$percent%', style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
