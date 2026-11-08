import 'package:flutter/widgets.dart';
import 'package:spark/src/core/utils/startup/startup_timings.dart';

/// Records a content frame only after the startup splash has been released.
/// This marks framework presentation, not image decoding or GPU presentation.
class StartupTimingMarker extends StatefulWidget {
  const StartupTimingMarker({
    required this.timings,
    required this.milestone,
    required this.active,
    required this.child,
    super.key,
  });

  final StartupTimings timings;
  final StartupMilestone milestone;
  final bool active;
  final Widget child;

  @override
  State<StartupTimingMarker> createState() => _StartupTimingMarkerState();
}

class _StartupTimingMarkerState extends State<StartupTimingMarker> {
  bool _pending = false;

  @override
  Widget build(BuildContext context) {
    if (!_pending && widget.active && widget.timings.needs(widget.milestone)) {
      _pending = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await WidgetsBinding.instance.waitUntilFirstFrameRasterized;
        _pending = false;
        if (!mounted || !widget.active) return;
        if (ModalRoute.of(this.context)?.isCurrent == false) return;
        widget.timings.mark(widget.milestone);
      });
    }
    return widget.child;
  }
}
