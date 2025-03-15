import 'package:flutter/cupertino.dart';
import '../widgets/action_buttons/like_action_button.dart';
import '../widgets/action_buttons/bookmark_action_button.dart';
import '../utils/app_colors.dart';

class TestActionsScreen extends StatefulWidget {
  const TestActionsScreen({super.key});

  @override
  State<TestActionsScreen> createState() => _TestActionsScreenState();
}

class _TestActionsScreenState extends State<TestActionsScreen> {
  bool _isLiked = false;
  bool _isBookmarked = false;

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      debugPrint('Like state changed to: $_isLiked');
    });
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
      debugPrint('Bookmark state changed to: $_isBookmarked');
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.deepPurple,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Test Actions'),
        backgroundColor: AppColors.deepPurple,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Heart Animation Test',
              style: TextStyle(color: CupertinoColors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            LikeActionButton(
              count: '1.2K',
              isLiked: _isLiked,
              onPressed: _toggleLike,
            ),
            const SizedBox(height: 40),
            const Text(
              'Bookmark Color Test',
              style: TextStyle(color: CupertinoColors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            BookmarkActionButton(
              count: '425',
              isBookmarked: _isBookmarked,
              onPressed: _toggleBookmark,
            ),
          ],
        ),
      ),
    );
  }
} 