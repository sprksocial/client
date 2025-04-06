import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class EmojiPicker extends StatefulWidget {
  final Function(String) onEmojiSelected;
  final bool isDarkMode;

  const EmojiPicker({super.key, required this.onEmojiSelected, required this.isDarkMode});

  @override
  State<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<EmojiPicker> {
  // Common emojis list
  static const List<String> _emojis = ['❤️', '😂', '👍', '🔥', '😍', '🙌', '👏', '🎉', '😮', '🤔', '👀', '💯', '🤣', '😊', '🙏'];

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isDarkMode ? AppColors.deepPurple.withAlpha(128) : AppColors.lightLavender.withAlpha(77);
    final borderColor = widget.isDarkMode ? AppColors.darkPurple : AppColors.lightLavender;

    return Container(
      height: 50,
      decoration: BoxDecoration(color: backgroundColor, border: Border(bottom: BorderSide(color: borderColor, width: 0.5))),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _emojis.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          return _buildEmojiItem(_emojis[index]);
        },
      ),
    );
  }

  Widget _buildEmojiItem(String emoji) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onEmojiSelected(emoji),
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
