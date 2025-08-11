import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/ui/foundation/colors.dart';

class ProfileDescription extends StatefulWidget {
  const ProfileDescription({
    required this.text,
    super.key,
    this.style,
    this.maxLines = 2,
    this.onExpandToggle,
    this.onMentionTap,
  });
  final String text;
  final TextStyle? style;
  final int maxLines;
  final Function(bool isExpanded)? onExpandToggle;
  final Function(String username)? onMentionTap;

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
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.03), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 1.03, end: 1), weight: 70),
    ]).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }

      if (widget.onExpandToggle != null) {
        widget.onExpandToggle!(_isExpanded);
      }
    });
  }

  List<Match> _findUsernameMatches(String text) {
    final usernameRegex = RegExp(r'\B@([a-zA-Z0-9_.-]+\.[a-zA-Z]{2,}|[a-zA-Z0-9_]+)', caseSensitive: false);
    return usernameRegex.allMatches(text).toList();
  }

  List<InlineSpan> _buildTextSpans(String text, List<Match> usernameMatches, TextStyle defaultStyle) {
    final spans = <InlineSpan>[];
    var lastEnd = 0;

    usernameMatches.sort((a, b) => a.start.compareTo(b.start));

    for (final match in usernameMatches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start))); // Default style is applied by RichText
      }

      final username = match.group(0)!;
      spans.add(
        TextSpan(
          text: username,
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
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
      spans.add(TextSpan(text: text.substring(lastEnd))); // Default style is applied by RichText
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usernameMatches = _findUsernameMatches(widget.text);
    final defaultStyle =
        widget.style ?? TextStyle(color: theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface, fontSize: 14);

    final textSpan = TextSpan(
      children: _buildTextSpans(widget.text, usernameMatches, defaultStyle),
      style: defaultStyle, // Apply default style to the parent TextSpan
    );

    return GestureDetector(
      onTap: _toggleExpanded,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, alignment: Alignment.topLeft, child: child);
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
