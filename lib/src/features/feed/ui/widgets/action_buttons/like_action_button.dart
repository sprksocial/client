import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/widgets/action_button.dart';

class LikeActionButton extends StatefulWidget {
  const LikeActionButton({required this.count, super.key, this.isLiked = false, this.onPressed});
  final String count;
  final bool isLiked;
  final VoidCallback? onPressed;

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
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1), weight: 50),
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final scale = _isLiked && _animationController.isAnimating ? _scaleAnimation.value : 1.0;

        return ActionButton(
          key: ValueKey('like_button_${widget.count}'),
          icon: _isLiked ? FluentIcons.heart_24_filled : FluentIcons.heart_24_regular,
          color: _isLiked ? AppColors.red : null,
          label: widget.count,
          onPressed: _handleTap,
          scale: scale,
        );
      },
    );
  }
}
