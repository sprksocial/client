import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/ui/foundation/colors.dart';

class EmojiPicker extends StatelessWidget {
  const EmojiPicker({required this.onEmojiSelected, required this.isDarkMode, super.key});
  final Function(String) onEmojiSelected;
  final bool isDarkMode;
  static const List<String> _emojis = ['❤️', '😂', '👍', '🔥', '😍', '🙌', '👏', '🎉', '😮', '🤔', '👀', '💯', '🤣', '😊', '🙏'];

  // Common emojis list
  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? AppColors.deepPurple.withAlpha(128) : AppColors.lightLavender.withAlpha(77);
    final borderColor = isDarkMode ? AppColors.darkPurple : AppColors.lightLavender;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _emojis.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          return _EmojiItem(onEmojiSelected: onEmojiSelected, emoji: _emojis[index]);
        },
      ),
    );
  }
}

class _EmojiItem extends StatelessWidget {
  const _EmojiItem({
    required this.emoji,
    required this.onEmojiSelected,
  });

  final String emoji;
  final Function(String) onEmojiSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onEmojiSelected(emoji),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
        ),
      ),
    );
  }
}
