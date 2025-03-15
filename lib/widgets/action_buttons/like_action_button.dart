import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'action_button.dart';
import '../../utils/app_colors.dart';

class LikeActionButton extends StatefulWidget {
  final String count;
  final bool isLiked;
  final VoidCallback? onPressed;

  const LikeActionButton({
    super.key,
    required this.count,
    this.isLiked = false,
    this.onPressed,
  });

  @override
  State<LikeActionButton> createState() => _LikeActionButtonState();
}

class _LikeActionButtonState extends State<LikeActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isLiked = false;
  bool _showSparkles = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    
    // Set up animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Create a curved animation for the pulse effect
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0),
        weight: 60,
      ),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    // Animation for sparkle opacity
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 80,
      ),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showSparkles = false;
        });
      }
    });
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
      // Start the animation only when transitioning to liked state
      if (!_isLiked) {
        setState(() {
          _showSparkles = true;
        });
        _animationController.forward(from: 0.0);
      }
      
      setState(() {
        _isLiked = !_isLiked;
      });
      
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Heart icon with pulse animation
              GestureDetector(
                onTap: _handleTap,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isLiked ? _scaleAnimation.value : 1.0,
                      child: Icon(
                        _isLiked ? FluentIcons.heart_24_filled : FluentIcons.heart_24_regular,
                        color: _isLiked ? AppColors.red : CupertinoColors.white,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
              
              // Sparkle effects
              if (_showSparkles)
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: List.generate(6, (index) {
                          final angle = (index * (math.pi / 3));
                          final distance = 22.0 * _scaleAnimation.value;
                          
                          return Positioned(
                            left: 20 + (math.cos(angle) * distance),
                            top: 20 + (math.sin(angle) * distance),
                            child: Transform.rotate(
                              angle: angle,
                              child: Icon(
                                FluentIcons.sparkle_24_filled,
                                color: AppColors.primary,
                                size: 10 * _opacityAnimation.value,
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.count,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
} 