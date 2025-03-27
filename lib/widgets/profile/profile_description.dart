import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../utils/formatters/text_formatter.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';

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

  List<Match> _findUsernameMatches(String text) {
    // Match handles that begin with @ and may include domain format
    // Match @username or @username.domain but not email@domain.com
    // The key is to ensure the @ is the beginning of a word boundary
    final RegExp usernameRegex = RegExp(r'\B@([a-zA-Z0-9_.-]+\.[a-zA-Z]{2,}|[a-zA-Z0-9_]+)', caseSensitive: false);
    
    return usernameRegex.allMatches(text).toList();
  }

  List<InlineSpan> _buildTextSpans(String text, List<Match> usernameMatches) {
    final List<InlineSpan> spans = [];
    int lastEnd = 0;

    usernameMatches.sort((a, b) => a.start.compareTo(b.start));

    for (final match in usernameMatches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: widget.style,
        ));
      }

      final username = match.group(0)!;
      spans.add(
        TextSpan(
          text: username,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (widget.onMentionTap != null) {
                widget.onMentionTap!(username);
              }
            },
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: widget.style,
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final usernameMatches = _findUsernameMatches(widget.text);
    final defaultStyle = widget.style ?? TextStyle(color: AppTheme.getTextColor(context), fontSize: 14);
    
    final textSpan = TextSpan(
      children: _buildTextSpans(widget.text, usernameMatches),
      style: defaultStyle,
    );

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
          child: RichText(
            text: textSpan,
            maxLines: _isExpanded ? null : widget.maxLines,
            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
} 