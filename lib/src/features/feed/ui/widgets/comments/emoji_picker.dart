import 'package:flutter/material.dart';

class EmojiPicker extends StatefulWidget {
  final Function(String) onEmojiSelected;

  const EmojiPicker({super.key, required this.onEmojiSelected});

  @override
  State<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<EmojiPicker> {
  // Common emojis list
  static const List<String> _emojis = ['❤️', '😂', '👍', '🔥', '😍', '🙌', '👏', '🎉', '😮', '🤔', '👀', '💯', '🤣', '😊', '🙏'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = colorScheme.surface;
    final borderColor = colorScheme.outline;

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
          return _EmojiItem(emoji: _emojis[index], onTap: () => widget.onEmojiSelected(_emojis[index]));
        },
      ),
    );
  }
}

class _EmojiItem extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;

  const _EmojiItem({required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
