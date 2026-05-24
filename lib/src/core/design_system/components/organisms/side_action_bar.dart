import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/pro_video_editor/ui/widgets/audio/sound_artwork.dart';

class SparkSideActionBar extends StatefulWidget {
  const SparkSideActionBar({
    super.key,
    this.onLike,
    this.onComment,
    this.onRepost,
    this.onShare,
    this.onShareLongPress,
    this.onSoundTap,
    this.onOptions,
    this.likeCount,
    this.commentCount,
    this.repostCount,
    this.shareCount,
    this.isLiked = false,
    this.isReposted = false,
    this.soundCover,
  });

  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onShare;
  final VoidCallback? onShareLongPress;
  final VoidCallback? onSoundTap;
  final VoidCallback? onOptions;

  final String? likeCount;
  final String? commentCount;
  final String? repostCount;
  final String? shareCount;

  final bool isLiked;
  final bool isReposted;
  final String? soundCover;

  @override
  State<SparkSideActionBar> createState() => _SparkSideActionBarState();
}

class _SparkSideActionBarState extends State<SparkSideActionBar> {
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      _ActionItem(
        isActive: widget.isLiked,
        label: widget.likeCount,
        icon: widget.isLiked
            ? AppIcons.likeFilled(
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              )
            : AppIcons.like(size: 32),
        onTap: widget.onLike,
      ),
      const SizedBox(height: 13),
      _ActionItem(
        icon: AppIcons.comment(size: 32),
        label: widget.commentCount,
        onTap: widget.onComment,
      ),
      const SizedBox(height: 13),
      _ActionItem(
        isActive: widget.isReposted,
        icon: AppIcons.repost(
          size: 32,
          color: widget.isReposted ? AppColors.green : null,
        ),
        label: widget.repostCount,
        onTap: widget.onRepost,
      ),
    ];

    children.addAll([
      const SizedBox(height: 13),
      _ActionItem(
        icon: AppIcons.share(size: 32),
        onTap: widget.onShare,
        onLongPress: widget.onShareLongPress,
      ),
    ]);

    if (widget.onOptions != null) {
      children.addAll([
        const SizedBox(height: 6),
        _ActionItem(
          icon: AppIcons.moreHoriz(size: 32, color: Colors.white),
          onTap: widget.onOptions,
        ),
      ]);
    }

    if (widget.onSoundTap != null) {
      children.addAll([
        const SizedBox(height: 13),
        _SoundItem(cover: widget.soundCover, onTap: widget.onSoundTap),
      ]);
    }

    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }
}

class _ActionItem extends StatefulWidget {
  const _ActionItem({
    required this.icon,
    this.label,
    this.onTap,
    this.onLongPress,
    this.isActive = false,
  });

  final Widget icon;
  final String? label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isActive;

  @override
  State<_ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<_ActionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1, end: 1.3), weight: 40),
          TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 30),
        ]).animate(
          CurvedAnimation(parent: _bounceController, curve: Curves.easeOut),
        );
  }

  @override
  void didUpdateWidget(_ActionItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _bounceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceController.isAnimating
                    ? _bounceAnimation.value
                    : (widget.isActive ? 1.05 : 1.0),
                child: child,
              );
            },
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(child: widget.icon),
            ),
          ),
          if (widget.label != null && widget.label!.isNotEmpty)
            Text(
              widget.label!,
              style: const TextStyle(
                fontSize: 12,
                height: 1.1,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _SoundItem extends StatelessWidget {
  const _SoundItem({this.cover, this.onTap});

  final String? cover;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const albumSize = 35.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipOval(
        child: SoundArtwork(
          imageUrl: cover,
          size: albumSize,
          borderRadius: albumSize / 2,
          backgroundColor: Colors.grey.shade800,
        ),
      ),
    );
  }
}
