import 'package:flutter/cupertino.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'action_button.dart';
import '../../utils/app_colors.dart';

// Test widget to demonstrate the BookmarkActionButton works correctly
class TestBookmarkWidget extends StatefulWidget {
  const TestBookmarkWidget({super.key});

  @override
  State<TestBookmarkWidget> createState() => _TestBookmarkWidgetState();
}

class _TestBookmarkWidgetState extends State<TestBookmarkWidget> {
  bool _isBookmarked = false;

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
      debugPrint('Bookmark state changed to: $_isBookmarked');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BookmarkActionButton(
        count: '42',
        isBookmarked: _isBookmarked,
        onPressed: _toggleBookmark,
      ),
    );
  }
}

class BookmarkActionButton extends StatefulWidget {
  final String count;
  final bool isBookmarked;
  final VoidCallback? onPressed;

  const BookmarkActionButton({
    super.key,
    required this.count,
    this.isBookmarked = false,
    this.onPressed,
  });

  @override
  State<BookmarkActionButton> createState() => _BookmarkActionButtonState();
}

class _BookmarkActionButtonState extends State<BookmarkActionButton> with SingleTickerProviderStateMixin {
  late bool _isBookmarked;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.isBookmarked;
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Simple scale animation
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void didUpdateWidget(BookmarkActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isBookmarked != widget.isBookmarked) {
      setState(() {
        _isBookmarked = widget.isBookmarked;
      });
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
        _isBookmarked = !_isBookmarked;
      });
      
      _animationController.reset();
      _animationController.forward();
      
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug print to verify the color is changing based on isBookmarked
    debugPrint('Building BookmarkActionButton, isBookmarked: $_isBookmarked');
    
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
                  scale: _animationController.isAnimating ? _scaleAnimation.value : 1.0,
                  child: Icon(
                    _isBookmarked ? FluentIcons.bookmark_24_filled : FluentIcons.bookmark_24_regular,
                    color: _isBookmarked ? AppColors.blue : CupertinoColors.white,
                    size: 30,
                  ),
                );
              },
            ),
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