import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';
import 'package:spark/src/core/network/atproto/data/models/story_embed_models.dart';
import 'package:spark/src/core/ui/widgets/story_mention_chip.dart';

const _kStoryMentionLayerTypeKey = 'storyMentionType';
const _kStoryMentionLayerTypeValue = 'mention';
const _kStoryMentionDidKey = 'did';
const _kStoryMentionHandleKey = 'handle';
const _kStoryMentionDisplayNameKey = 'displayName';

WidgetLayer createStoryMentionLayer(ProfileViewBasic actor) {
  final primaryText = '@${actor.handle}';
  final initialSize = measureStoryMentionChipSize(
    primaryText: primaryText,
    height: kStoryMentionInitialHeight,
  );

  return WidgetLayer(
    width: initialSize.width,
    widget: StoryMentionChip(
      primaryText: primaryText,
      fixedHeight: kStoryMentionInitialHeight,
    ),
    meta: {
      _kStoryMentionLayerTypeKey: _kStoryMentionLayerTypeValue,
      _kStoryMentionDidKey: actor.did,
      _kStoryMentionHandleKey: actor.handle,
      if (actor.displayName != null && actor.displayName!.isNotEmpty)
        _kStoryMentionDisplayNameKey: actor.displayName,
    },
  );
}

bool isStoryMentionLayer(Layer layer) {
  final meta = layer.meta;
  return layer is WidgetLayer &&
      meta != null &&
      meta[_kStoryMentionLayerTypeKey] == _kStoryMentionLayerTypeValue;
}

List<StoryEmbed> extractStoryMentionEmbeds(
  Iterable<Layer> layers, {
  required Size canvasSize,
}) {
  if (canvasSize.width <= 0 || canvasSize.height <= 0) {
    return const [];
  }

  final halfCanvasWidth = canvasSize.width / 2;
  final halfCanvasHeight = canvasSize.height / 2;
  final canvasRect = Offset.zero & canvasSize;
  final embeds = <StoryEmbed>[];

  for (final indexedLayer in layers.indexed) {
    final index = indexedLayer.$1;
    final layer = indexedLayer.$2;
    if (!isStoryMentionLayer(layer)) {
      continue;
    }

    final widgetLayer = layer as WidgetLayer;
    final did = widgetLayer.meta?[_kStoryMentionDidKey] as String?;
    if (did == null || did.isEmpty) {
      continue;
    }

    final frameSize = _resolvedLayerSize(widgetLayer);
    if (frameSize.isEmpty) {
      continue;
    }

    final left = layer.offset.dx + halfCanvasWidth - (frameSize.width / 2);
    final top = layer.offset.dy + halfCanvasHeight - (frameSize.height / 2);
    final visibleRect = Rect.fromLTWH(
      left,
      top,
      frameSize.width,
      frameSize.height,
    ).intersect(canvasRect);
    if (visibleRect.width <= 0 || visibleRect.height <= 0) {
      continue;
    }

    embeds.add(
      StoryEmbed.mention(
        placement: StoryEmbedPlacement(
          frame: StoryEmbedFrame(
            x: _normalize(visibleRect.left, canvasSize.width, clampMin: 0),
            y: _normalize(visibleRect.top, canvasSize.height, clampMin: 0),
            w: _normalize(visibleRect.width, canvasSize.width, clampMin: 1),
            h: _normalize(visibleRect.height, canvasSize.height, clampMin: 1),
          ),
          zIndex: index,
          rotation: _rotationDegrees(layer.rotation),
        ),
        did: did,
      ),
    );
  }

  return embeds;
}

Size _resolvedLayerSize(WidgetLayer layer) {
  final renderObject = layer.keyInternalSize.currentContext?.findRenderObject();
  final renderBox = renderObject is RenderBox ? renderObject : null;
  if (renderBox != null && renderBox.hasSize && !renderBox.size.isEmpty) {
    return renderBox.size;
  }

  final handle = layer.meta?[_kStoryMentionHandleKey] as String?;
  final baseSize = measureStoryMentionChipSize(
    primaryText: '@${handle ?? 'mention'}',
    height: kStoryMentionInitialHeight,
  );
  final width = (layer.width ?? baseSize.width) * layer.scale;
  if (!width.isFinite || width <= 0) {
    return Size.zero;
  }

  final aspectRatio = baseSize.width <= 0
      ? 1
      : baseSize.height / baseSize.width;
  return Size(width, width * aspectRatio);
}

int _normalize(double value, double max, {required int clampMin}) {
  if (!value.isFinite || max <= 0 || !max.isFinite) {
    return clampMin;
  }

  return ((value / max) * 10000).round().clamp(clampMin, 10000);
}

int _rotationDegrees(double radians) {
  final degrees = radians * 180 / math.pi;
  final normalized = degrees % 360;
  return normalized.round().clamp(0, 359);
}
