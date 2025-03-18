import 'package:flutter/material.dart';

class VideoProgressBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final bool isDragging;
  final double dragPosition;
  final Function(double) onDragStart;
  final Function(double) onDragUpdate;
  final VoidCallback onDragEnd;

  const VideoProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.isDragging,
    required this.dragPosition,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> with SingleTickerProviderStateMixin {
  bool _knobEnlarged = false;

  late AnimationController _timestampAnimationController;
  late Animation<Offset> _timestampAnimation;

  @override
  void initState() {
    super.initState();

    _timestampAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

    _timestampAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -1.0),
    ).animate(CurvedAnimation(parent: _timestampAnimationController, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(VideoProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isDragging != oldWidget.isDragging) {
      setState(() {
        _knobEnlarged = widget.isDragging;
      });

      if (widget.isDragging) {
        _timestampAnimationController.forward();
      } else {
        _timestampAnimationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _timestampAnimationController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final progressBarWidthPercentage = 0.7; // 70% of screen width
    final progressBarWidth = screenWidth * progressBarWidthPercentage;
    final progressBarHeight = 4.0;
    final knobSizeNormal = 14.0;
    final knobSizeEnlarged = 20.0;

    return Container(
      width: progressBarWidth,
      height: 40, // Taller touch area
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final actualWidth = constraints.maxWidth;

          return GestureDetector(
            onHorizontalDragStart: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset localPos = box.globalToLocal(details.globalPosition);
              final progressBarLeft = (screenWidth - progressBarWidth) / 2;
              final relativeX = localPos.dx - progressBarLeft;
              final normalizedPosition = (relativeX / progressBarWidth).clamp(0.0, 1.0);
              widget.onDragStart(normalizedPosition);
            },
            onHorizontalDragUpdate: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset localPos = box.globalToLocal(details.globalPosition);
              final progressBarLeft = (screenWidth - progressBarWidth) / 2;
              final relativeX = localPos.dx - progressBarLeft;
              final normalizedPosition = (relativeX / progressBarWidth).clamp(0.0, 1.0);
              widget.onDragUpdate(normalizedPosition);
            },
            onHorizontalDragEnd: (_) => widget.onDragEnd(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: progressBarHeight,
                  width: double.infinity, // Full width of the parent container
                  color: Colors.grey.withAlpha(128),
                ),

                FractionallySizedBox(
                  widthFactor:
                      widget.isDragging
                          ? widget.dragPosition.clamp(0.0, 1.0)
                          : (widget.position.inMilliseconds / widget.duration.inMilliseconds).clamp(0.0, 1.0),
                  child: Container(height: progressBarHeight, color: Colors.white),
                ),

                Positioned(
                  left:
                      widget.isDragging
                          ? (widget.dragPosition * actualWidth).clamp(0.0, actualWidth)
                          : ((widget.position.inMilliseconds / widget.duration.inMilliseconds) * actualWidth).clamp(
                            0.0,
                            actualWidth,
                          ),
                  top: -5,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragStart: (details) {
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      final Offset localPos = box.globalToLocal(details.globalPosition);
                      final progressBarLeft = (screenWidth - progressBarWidth) / 2;
                      final relativeX = localPos.dx - progressBarLeft;
                      final normalizedPosition = (relativeX / progressBarWidth).clamp(0.0, 1.0);
                      widget.onDragStart(normalizedPosition);
                    },
                    onHorizontalDragUpdate: (details) {
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      final Offset localPos = box.globalToLocal(details.globalPosition);
                      final progressBarLeft = (screenWidth - progressBarWidth) / 2;
                      final relativeX = localPos.dx - progressBarLeft;
                      final normalizedPosition = (relativeX / progressBarWidth).clamp(0.0, 1.0);
                      widget.onDragUpdate(normalizedPosition);
                    },
                    onHorizontalDragEnd: (_) => widget.onDragEnd(),
                    child: Container(
                      width: _knobEnlarged ? knobSizeEnlarged : knobSizeNormal,
                      height: _knobEnlarged ? knobSizeEnlarged : knobSizeNormal,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(77), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                    ),
                  ),
                ),

                if (widget.isDragging)
                  Positioned(
                    left: (widget.dragPosition * actualWidth - 25).clamp(0.0, actualWidth - 50),
                    bottom: 15,
                    child: SlideTransition(
                      position: _timestampAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withAlpha(179), borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          _formatDuration(widget.duration * widget.dragPosition),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
