import 'package:flutter/foundation.dart';

enum TimelineSelectionKind { none, primary, audio, layer }

@immutable
class TimelineSelection {
  const TimelineSelection._(this.kind, [this.layerId]);

  const TimelineSelection.layer(String layerId)
    : this._(TimelineSelectionKind.layer, layerId);

  static const none = TimelineSelection._(TimelineSelectionKind.none);
  static const primary = TimelineSelection._(TimelineSelectionKind.primary);
  static const audio = TimelineSelection._(TimelineSelectionKind.audio);

  final TimelineSelectionKind kind;
  final String? layerId;

  @override
  bool operator ==(Object other) {
    return other is TimelineSelection &&
        other.kind == kind &&
        other.layerId == layerId;
  }

  @override
  int get hashCode => Object.hash(kind, layerId);
}
