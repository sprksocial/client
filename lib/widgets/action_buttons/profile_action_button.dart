import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';

class ProfileActionButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ProfileActionButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        children: [
          ClipOval(
            child: Container(
              width: 44,
              height: 44,
              color: CupertinoColors.systemGrey,
              child: const Center(
                child: Icon(Ionicons.person_outline, color: CupertinoColors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: CupertinoColors.systemPink,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.add,
                color: CupertinoColors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 