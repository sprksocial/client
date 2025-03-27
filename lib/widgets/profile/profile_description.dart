import 'package:flutter/material.dart';
import '../../utils/formatters/text_formatter.dart';

class ProfileDescription extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final Function(bool isExpanded)? onExpandToggle;
  final Function(String username)? onMentionTap;

  const ProfileDescription({
    super.key, 
    required this.text, 
    this.style, 
    this.maxLines = 2,
    this.onExpandToggle,
    this.onMentionTap,
  });

  @override
  State<ProfileDescription> createState() => _ProfileDescriptionState();
}

class _ProfileDescriptionState extends State<ProfileDescription> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.03), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 1.03, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      _animationController.forward(from: 0);
      
      if (widget.onExpandToggle != null) {
        widget.onExpandToggle!(_isExpanded);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            alignment: Alignment.topLeft,
            child: child,
          );
        },
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: TextFormatter.buildRichTextWithMentions(
            context, 
            widget.text, 
            _isExpanded, 
            widget.onMentionTap ?? (username) {},
          ),
        ),
      ),
    );
  }
} 