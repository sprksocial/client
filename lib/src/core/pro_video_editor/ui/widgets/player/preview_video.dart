import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

/// A widget that previews a video from a file path.
///
/// Displays the video and optionally shows generation meta.
class PreviewVideo extends StatefulWidget {
  const PreviewVideo({
    required this.filePath,
    required this.generationTime,
    super.key,
  });

  final String filePath;
  final Duration generationTime;

  @override
  State<PreviewVideo> createState() => _PreviewVideoState();
}

class _PreviewVideoState extends State<PreviewVideo> {
  final _valueStyle = const TextStyle(fontStyle: FontStyle.italic);

  late Future<VideoMetadata> _videoMetadata;
  late final int _generationTime = widget.generationTime.inMilliseconds;

  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    _videoMetadata = ProVideoEditor.instance.getMetadata(
      EditorVideo.file(widget.filePath),
    );
    _initializePlayer();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    final controller = VideoPlayerController.networkUrl(
      Uri.file(widget.filePath),
    );
    await controller.initialize();
    await controller.setLooping(false);
    await controller.setVolume(1);
    if (mounted) {
      setState(() => _videoController = controller);
    } else {
      controller.dispose();
    }
  }

  String _formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    final size = bytes / pow(1024, i);
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pageTitleResult)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(child: _buildVideoPlayer(constraints)),
              _buildGenerationInfos(l10n),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVideoPlayer(BoxConstraints constraints) {
    return FutureBuilder<VideoMetadata>(
      future: _videoMetadata,
      builder: (context, snapshot) {
        if (_videoController == null ||
            !_videoController!.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        final aspectRatio = snapshot.data?.resolution.aspectRatio ?? 1;

        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        var width = maxWidth;
        var height = width / aspectRatio;

        if (height > maxHeight) {
          height = maxHeight;
          width = height * aspectRatio;
        }

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Hero(
              tag: const ProImageEditorConfigs().heroTag,
              child: VideoPlayer(_videoController!),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenerationInfos(AppLocalizations l10n) {
    const tableSpace = TableRow(children: [SizedBox(height: 3), SizedBox()]);
    return Positioned(
      top: 10,
      left: 10,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(7),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: FutureBuilder<VideoMetadata>(
              future: _videoMetadata,
              builder: (context, snapshot) {
                final md = snapshot.data;
                return Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {0: IntrinsicColumnWidth()},
                  children: [
                    TableRow(
                      children: [
                        Text(l10n.labelGenerationTime),
                        Text('${_generationTime}ms', style: _valueStyle),
                      ],
                    ),
                    tableSpace,
                    if (md != null) ...[
                      TableRow(
                        children: [
                          Text(l10n.labelDuration),
                          Text(md.duration.toString(), style: _valueStyle),
                        ],
                      ),
                      tableSpace,
                      TableRow(
                        children: [
                          Text(l10n.labelSize),
                          Text(_formatBytes(md.fileSize), style: _valueStyle),
                        ],
                      ),
                      tableSpace,
                      TableRow(
                        children: [
                          Text(l10n.labelResolution),
                          Text(
                            '${md.resolution.width.toInt()}x'
                            '${md.resolution.height.toInt()}',
                            style: _valueStyle,
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
