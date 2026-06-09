import 'package:sprk_poptart/so/sprk/feed/defs.dart' as sprk_feed_defs;
import 'package:sprk_poptart/so/sprk/media/defs/aspect_ratio.dart'
    as sprk_media_defs;

import 'package:spark/src/core/network/atproto/data/models/feed_models.dart';
import 'package:spark/src/core/network/atproto/data/models/record_models.dart'
    as local;

extension PostVideoAspectRatio on PostView {
  double? get videoAspectRatio {
    final mediaAspectRatio = switch (displayMedia) {
      sprk_feed_defs.UPostViewMediaMediaVideoView(:final data) =>
        _aspectRatioDataValue(data.aspectRatio),
      sprk_feed_defs.UPostViewMediaUnknown(:final data)
          when data[r'$type'] == 'so.sprk.media.video#view' =>
        _aspectRatioFromJson(data['aspectRatio']),
      _ => null,
    };

    return mediaAspectRatio ?? _recordVideoAspectRatio;
  }

  double? get _recordVideoAspectRatio {
    return switch (localRecord?.media) {
      local.MediaVideo(:final aspectRatio) => aspectRatio?.value,
      _ => null,
    };
  }
}

double? _aspectRatioDataValue(sprk_media_defs.AspectRatio? aspectRatio) {
  if (aspectRatio == null) return null;
  return _aspectRatioValue(aspectRatio.width, aspectRatio.height);
}

double? _aspectRatioFromJson(Object? value) {
  return switch (value) {
    {'width': final Object? width, 'height': final Object? height} =>
      _aspectRatioValue(width, height),
    _ => null,
  };
}

double? _aspectRatioValue(Object? width, Object? height) {
  final widthValue = switch (width) {
    final num value => value.toDouble(),
    _ => null,
  };
  final heightValue = switch (height) {
    final num value => value.toDouble(),
    _ => null,
  };

  if (widthValue == null ||
      heightValue == null ||
      widthValue <= 0 ||
      heightValue <= 0) {
    return null;
  }

  return widthValue / heightValue;
}
