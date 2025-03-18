import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../utils/app_colors.dart';

class LikeActionButton extends StatefulWidget {
  final String count;
  final bool isLiked;
  final VoidCallback? onPressed;

  const LikeActionButton({super.key, required this.count, this.isLiked = false, this.onPressed});

  @override
  State<LikeActionButton> createState() => _LikeActionButtonState();
}

class _LikeActionButtonState extends State<LikeActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;

    _animationController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(LikeActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked) {
      _isLiked = widget.isLiked;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      setState(() {
        _isLiked = !_isLiked;
      });

      if (_isLiked) {
        _animationController.reset();
        _animationController.forward();
      }

      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          width: 40,
          child: GestureDetector(
            onTap: _handleTap,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isLiked ? (_animationController.isAnimating ? _scaleAnimation.value : 1.0) : 1.0,
                  child: Icon(
                    _isLiked ? FluentIcons.heart_24_filled : FluentIcons.heart_24_regular,
                    color: _isLiked ? AppColors.red : Colors.white,
                    size: 30,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(widget.count, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
