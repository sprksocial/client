import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

const _kAutoScrollEdge = 28.0;
const _kAutoScrollMaxSpeed = 240.0;
const _kAutoScrollInterval = Duration(milliseconds: 16);

class LayerReorderResult {
  const LayerReorderResult({
    required this.layer,
    required this.startIndex,
    required this.targetIndex,
  });

  final Layer layer;
  final int startIndex;
  final int targetIndex;
}

typedef LayerReorderCommitCallback =
    void Function(
      LayerReorderResult result,
      double start,
      double end,
      bool rangeChanged,
    );

class LayerReorderInteraction {
  const LayerReorderInteraction._(this._controller, this._layer);

  final LayerReorderController _controller;
  final Layer _layer;

  void start() => _controller._start(_layer);

  void update(double verticalOffset) =>
      _controller._update(_layer, verticalOffset);

  void finish(double start, double end, bool rangeChanged) =>
      _controller._finish(_layer, start, end, rangeChanged);

  void cancel() => _controller._cancel(_layer);
}

class LayerReorderController extends ChangeNotifier {
  LayerReorderController(
    this._scrollController,
    this._layers,
    this._rowExtent,
    this._rowHeight,
    this._viewportHeight,
    this._leadingRowCount,
    this._onCommit,
  );

  final ScrollController _scrollController;
  final List<Layer> Function() _layers;
  final double Function() _rowExtent;
  final double Function() _rowHeight;
  final double Function() _viewportHeight;
  final int Function() _leadingRowCount;
  final LayerReorderCommitCallback _onCommit;

  String? _layerId;
  int? _startIndex;
  int? _targetIndex;
  List<Layer>? _previewLayers;
  double _startScrollOffset = 0;
  double _lastOffsetY = 0;
  double _autoScrollSpeed = 0;
  Timer? _autoScrollTimer;

  List<Layer> get displayLayers => _previewLayers ?? _layers();

  LayerReorderInteraction? interactionFor(Layer layer) =>
      _layers().length < 2 ? null : LayerReorderInteraction._(this, layer);

  void _start(Layer layer) {
    final layers = _layers();
    if (layers.length < 2) return;
    final index = layers.indexWhere((item) => item.id == layer.id);
    if (index < 0) return;
    _layerId = layer.id;
    _startIndex = index;
    _targetIndex = index;
    _previewLayers = List<Layer>.of(layers);
    _startScrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0;
    _lastOffsetY = 0;
  }

  void _update(Layer layer, double offsetY) {
    if (_layerId != layer.id) return;
    _lastOffsetY = offsetY;
    _updateTarget(layer);
    _updateAutoScroll(offsetY);
  }

  void _finish(Layer layer, double start, double end, bool rangeChanged) {
    final result = _finishReorder(layer);
    if (result != null) _onCommit(result, start, end, rangeChanged);
  }

  LayerReorderResult? _finishReorder(Layer layer) {
    if (_layerId != layer.id) return null;
    final startIndex = _startIndex;
    final targetIndex = _targetIndex;
    final reorderedLayer = _previewLayers?.firstWhere(
      (item) => item.id == layer.id,
      orElse: () => layer,
    );
    _clear();
    if (startIndex == null || targetIndex == null || reorderedLayer == null) {
      return null;
    }
    return LayerReorderResult(
      layer: reorderedLayer,
      startIndex: startIndex,
      targetIndex: targetIndex,
    );
  }

  void _cancel(Layer layer) {
    if (_layerId == layer.id) _clear();
  }

  void synchronizeLayers() {
    final layerId = _layerId;
    if (layerId != null && !_layers().any((layer) => layer.id == layerId)) {
      _clear();
    }
  }

  void _updateTarget(Layer layer) {
    final startIndex = _startIndex;
    final layers = _layers();
    if (startIndex == null || layers.isEmpty) return;
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : _startScrollOffset;
    final scrollDelta = scrollOffset - _startScrollOffset;
    final targetIndex =
        (startIndex + (_lastOffsetY + scrollDelta) / _rowExtent())
            .round()
            .clamp(0, layers.length - 1);
    if (targetIndex == _targetIndex) return;
    final previewLayers = _previewLayers;
    if (previewLayers == null) return;
    final oldIndex = previewLayers.indexWhere((item) => item.id == layer.id);
    if (oldIndex < 0) return;
    final movedLayer = previewLayers.removeAt(oldIndex);
    previewLayers.insert(targetIndex, movedLayer);
    _targetIndex = targetIndex;
    notifyListeners();
  }

  void _updateAutoScroll(double offsetY) {
    if (!_scrollController.hasClients ||
        _scrollController.position.maxScrollExtent <= 0) {
      _setAutoScrollSpeed(0);
      return;
    }
    final startIndex = _startIndex;
    if (startIndex == null) return;
    final rowExtent = _rowExtent();
    final startCenter =
        (startIndex + _leadingRowCount()) * rowExtent +
        (_rowHeight() / 2) -
        _startScrollOffset;
    final pointerY = startCenter + offsetY;
    final viewportHeight = _viewportHeight();
    double speed = 0;
    if (pointerY < _kAutoScrollEdge) {
      final strength = ((_kAutoScrollEdge - pointerY) / _kAutoScrollEdge).clamp(
        0.0,
        1.0,
      );
      speed = -_kAutoScrollMaxSpeed * strength;
    } else if (pointerY > viewportHeight - _kAutoScrollEdge) {
      final strength =
          ((pointerY - (viewportHeight - _kAutoScrollEdge)) / _kAutoScrollEdge)
              .clamp(0.0, 1.0);
      speed = _kAutoScrollMaxSpeed * strength;
    }
    _setAutoScrollSpeed(speed);
  }

  void _setAutoScrollSpeed(double speed) {
    _autoScrollSpeed = speed;
    if (speed == 0) {
      _autoScrollTimer?.cancel();
      _autoScrollTimer = null;
      return;
    }
    _autoScrollTimer ??= Timer.periodic(
      _kAutoScrollInterval,
      (_) => _tickAutoScroll(),
    );
  }

  void _tickAutoScroll() {
    final layerId = _layerId;
    if (!_scrollController.hasClients || layerId == null) {
      _setAutoScrollSpeed(0);
      return;
    }
    final position = _scrollController.position;
    final nextOffset =
        (position.pixels +
                _autoScrollSpeed *
                    _kAutoScrollInterval.inMicroseconds /
                    Duration.microsecondsPerSecond)
            .clamp(position.minScrollExtent, position.maxScrollExtent)
            .toDouble();
    if (nextOffset == position.pixels) {
      _setAutoScrollSpeed(0);
      return;
    }
    _scrollController.jumpTo(nextOffset);
    final layers = _layers();
    final layerIndex = layers.indexWhere((item) => item.id == layerId);
    if (layerIndex >= 0) _updateTarget(layers[layerIndex]);
  }

  void _clear() {
    _setAutoScrollSpeed(0);
    _previewLayers = null;
    _layerId = null;
    _startIndex = null;
    _targetIndex = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }
}
