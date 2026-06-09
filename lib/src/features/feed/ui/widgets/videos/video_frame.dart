import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';

const double _fullScreenVideoMinAspectRatio = 0.5;
const double _fullScreenVideoMaxAspectRatio = 0.7;

BoxFit feedVideoFitForAspectRatio(double? aspectRatio) {
  final shouldFillScreen =
      aspectRatio != null &&
      aspectRatio > _fullScreenVideoMinAspectRatio &&
      aspectRatio < _fullScreenVideoMaxAspectRatio;
  return shouldFillScreen ? BoxFit.cover : BoxFit.contain;
}

BoxFit feedVideoThumbnailFitForAspectRatio(double? aspectRatio) {
  return aspectRatio == null ? BoxFit.contain : BoxFit.cover;
}

double? feedVideoAspectRatioFromSize(Size? size) {
  if (size == null || size.width <= 0 || size.height <= 0) return null;
  return size.width / size.height;
}

Size? feedVideoFrameSize({Size? videoSize, double? aspectRatio}) {
  if (videoSize != null && videoSize.width > 0 && videoSize.height > 0) {
    return videoSize;
  }
  if (aspectRatio == null || aspectRatio <= 0) return null;
  return Size(aspectRatio, 1);
}

class FeedVideoFrame extends StatelessWidget {
  const FeedVideoFrame({
    required this.fit,
    required this.frameSize,
    required this.child,
    super.key,
  });

  final BoxFit fit;
  final Size? frameSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = frameSize;
    if (size == null) return child;

    return FittedBox(
      fit: fit,
      child: SizedBox(width: size.width, height: size.height, child: child),
    );
  }
}

class FeedVideoThumbnailFrame extends StatefulWidget {
  const FeedVideoThumbnailFrame({
    required this.thumbnail,
    super.key,
    this.videoAspectRatio,
  });

  final String thumbnail;
  final double? videoAspectRatio;

  @override
  State<FeedVideoThumbnailFrame> createState() =>
      _FeedVideoThumbnailFrameState();
}

class _FeedVideoThumbnailFrameState extends State<FeedVideoThumbnailFrame> {
  double? _thumbnailImageAspectRatio;
  ImageStream? _thumbnailImageStream;
  ImageStreamListener? _thumbnailImageListener;
  String? _thumbnailImageAspectRatioUrl;
  int _thumbnailImageRequestId = 0;

  double? get _metadataVideoAspectRatio =>
      widget.videoAspectRatio != null && widget.videoAspectRatio! > 0
      ? widget.videoAspectRatio
      : null;

  double? get _aspectRatio =>
      _metadataVideoAspectRatio ?? _thumbnailImageAspectRatio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveThumbnailImageAspectRatio();
  }

  @override
  void didUpdateWidget(FeedVideoThumbnailFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.thumbnail != widget.thumbnail ||
        oldWidget.videoAspectRatio != widget.videoAspectRatio) {
      _resetThumbnailImageAspectRatio();
      _resolveThumbnailImageAspectRatio();
    }
  }

  @override
  void dispose() {
    _cancelThumbnailImageRequest();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = _aspectRatio;
    final frameSize = feedVideoFrameSize(aspectRatio: aspectRatio);
    final thumbnail = widget.thumbnail.isNotEmpty
        ? Image.network(
            widget.thumbnail,
            fit: feedVideoThumbnailFitForAspectRatio(aspectRatio),
            width: double.infinity,
            height: double.infinity,
          )
        : const DecoratedBox(decoration: BoxDecoration(color: AppColors.black));

    return FeedVideoFrame(
      fit: feedVideoFitForAspectRatio(aspectRatio),
      frameSize: frameSize,
      child: thumbnail,
    );
  }

  void _resetThumbnailImageAspectRatio() {
    _cancelThumbnailImageRequest();
    _thumbnailImageAspectRatio = null;
    _thumbnailImageAspectRatioUrl = null;
  }

  void _cancelThumbnailImageRequest() {
    _thumbnailImageRequestId++;
    _removeCurrentThumbnailImageListener();
  }

  void _removeCurrentThumbnailImageListener() {
    final stream = _thumbnailImageStream;
    final listener = _thumbnailImageListener;
    if (stream != null && listener != null) {
      stream.removeListener(listener);
    }
    _thumbnailImageStream = null;
    _thumbnailImageListener = null;
  }

  void _removeThumbnailImageListener(
    ImageStream stream,
    ImageStreamListener listener,
  ) {
    stream.removeListener(listener);
    if (identical(_thumbnailImageStream, stream) &&
        identical(_thumbnailImageListener, listener)) {
      _thumbnailImageStream = null;
      _thumbnailImageListener = null;
    }
  }

  void _resolveThumbnailImageAspectRatio() {
    if (_metadataVideoAspectRatio != null || widget.thumbnail.isEmpty) {
      _cancelThumbnailImageRequest();
      return;
    }
    if (_thumbnailImageAspectRatioUrl == widget.thumbnail &&
        (_thumbnailImageAspectRatio != null || _thumbnailImageStream != null)) {
      return;
    }

    _cancelThumbnailImageRequest();
    _thumbnailImageAspectRatio = null;
    _thumbnailImageAspectRatioUrl = widget.thumbnail;
    final requestId = _thumbnailImageRequestId;
    final requestUrl = widget.thumbnail;

    final image = NetworkImage(widget.thumbnail);
    final stream = image.resolve(createLocalImageConfiguration(context));
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (imageInfo, synchronousCall) {
        final width = imageInfo.image.width;
        final height = imageInfo.image.height;
        if (width <= 0 || height <= 0) return;

        final aspectRatio = width / height;
        _removeThumbnailImageListener(stream, listener);
        if (!mounted ||
            _thumbnailImageRequestId != requestId ||
            _thumbnailImageAspectRatioUrl != requestUrl ||
            widget.thumbnail != requestUrl) {
          return;
        }

        if (synchronousCall) {
          _thumbnailImageAspectRatio = aspectRatio;
        } else {
          setState(() {
            _thumbnailImageAspectRatio = aspectRatio;
          });
        }
      },
      onError: (_, _) {
        _removeThumbnailImageListener(stream, listener);
      },
    );
    _thumbnailImageStream = stream;
    _thumbnailImageListener = listener;
    stream.addListener(listener);
  }
}
