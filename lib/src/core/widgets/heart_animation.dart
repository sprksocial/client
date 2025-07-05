import 'package:flutter/material.dart';

class HeartAnimation extends StatefulWidget {
  const HeartAnimation({
    required this.isAnimating,
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 1000),
    this.onEnd,
  });
  final bool isAnimating;
  final Duration duration;
  final VoidCallback? onEnd;
  final Widget child;

  @override
  State<HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<HeartAnimation> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(begin: 0, end: 1.4).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(begin: 0.8, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onEnd?.call();
      }
    });
  }

  @override
  void didUpdateWidget(HeartAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _controller.reset();
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isAnimating)
          Positioned.fill(
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 100,
                        shadows: [Shadow(blurRadius: 10, color: Colors.red)],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
