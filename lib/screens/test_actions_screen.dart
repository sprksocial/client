import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../widgets/action_buttons/bookmark_action_button.dart';
import '../widgets/action_buttons/like_action_button.dart';

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
    return Scaffold(
      backgroundColor: AppColors.deepPurple,
      appBar: AppBar(title: const Text('Test Actions'), backgroundColor: AppColors.deepPurple, elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Heart Animation Test', style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 20),
            LikeActionButton(count: '1.2K', isLiked: _isLiked, onPressed: _toggleLike),
            const SizedBox(height: 40),
            const Text('Bookmark Color Test', style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 20),
            BookmarkActionButton(count: '425', isBookmarked: _isBookmarked, onPressed: _toggleBookmark),
          ],
        ),
      ),
    );
  }
}
