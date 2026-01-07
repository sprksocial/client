import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';
import 'package:sparksocial/src/core/ui/foundation/colors.dart';

/// Curate popover item data
class CurateDestination {
  final String label;
  final VoidCallback? onSelected;
  const CurateDestination(this.label, {this.onSelected});
}

class SparkSideActionBar extends StatefulWidget {
  const SparkSideActionBar({
    super.key,
    this.onLike,
    this.onComment,
    this.onRepost,
    this.onCurate,
    this.onShare,
    this.onSoundTap,
    this.onOptions,
    this.likeCount,
    this.commentCount,
    this.repostCount,
    this.curateCount,
    this.shareCount,
    this.isLiked = false,
    this.isReposted = false,
    this.isCurated = false,
    this.soundCover,
    this.curateDestinations = const <CurateDestination>[
      CurateDestination('Feed 1'),
      CurateDestination('Feed 2'),
      CurateDestination('Feed 3'),
    ],
  });

  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onCurate; // called after a feed selection (or when opening?)
  final VoidCallback? onShare;
  final VoidCallback? onSoundTap;
  final VoidCallback? onOptions;

  final String? likeCount;
  final String? commentCount;
  final String? repostCount;
  final String? curateCount;
  final String? shareCount;

  final bool isLiked;
  final bool isReposted;
  final bool isCurated;
  final String? soundCover;
  final List<CurateDestination> curateDestinations;

  @override
  State<SparkSideActionBar> createState() => _SparkSideActionBarState();
}

class _SparkSideActionBarState extends State<SparkSideActionBar> {
  final GlobalKey _curateKey = GlobalKey();
  OverlayEntry? _overlay;
  OverlayEntry? _overlayIcon; // icon overlay above popover
  bool _showingPopover = false;

  @override
  void dispose() {
    _removePopover();
    super.dispose();
  }

  void _togglePopover() {
    if (_showingPopover) {
      _removePopover();
    } else {
      _showPopover();
    }
  }

  void _showPopover() {
    if (!mounted) return;
    final renderBox = _curateKey.currentContext?.findRenderObject() as RenderBox?;
    final overlayBox = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (renderBox == null || overlayBox == null) return;

    final target = renderBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final size = renderBox.size;
    final iconCenter = Offset(target.dx + size.width / 2, target.dy + size.height / 2);

    _overlay = OverlayEntry(
      builder: (ctx) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _removePopover,
          child: Stack(
            children: [
              Positioned(
                // Place so the connector circle (shiftX=30) centers behind icon; fine-tune offsets empirically.
                top: iconCenter.dy - 48,
                right: MediaQuery.of(context).size.width - target.dx + 16 - 30,
                child: _CuratePopover(
                  destinations: widget.curateDestinations,
                  onSelected: (d) {
                    d.onSelected?.call();
                    widget.onCurate?.call();
                    _removePopover();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    // Add icon overlay above popover for correct z-order (bar bg -> popover -> actual icon)
    _overlayIcon = OverlayEntry(
      builder: (ctx) => Positioned(
        left: target.dx,
        top: target.dy,
        width: size.width,
        height: size.height,
        child: IgnorePointer(
          child: Center(child: AppIcons.sideCurate(size: 32)),
        ),
      ),
    );

    final overlayState = Overlay.of(context);
    overlayState.insert(_overlay!); // background popover
    overlayState.insert(_overlayIcon!); // icon on top
    setState(() => _showingPopover = true);
  }

  void _removePopover() {
    _overlay?.remove();
    _overlayIcon?.remove();
    _overlay = null;
    _overlayIcon = null;
    _showingPopover = false;
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      _ActionItem(
        isActive: widget.isLiked,
        label: widget.likeCount,
        icon: widget.isLiked ? AppIcons.likeFilled(size: 32) : AppIcons.like(size: 32),
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
        icon: AppIcons.repostLarge(size: 32, color: widget.isReposted ? AppColors.green : null),
        label: widget.repostCount,
        onTap: widget.onRepost,
      ),
    ];

    if (widget.onCurate != null) {
      children.addAll([
        const SizedBox(height: 13),
        _ActionItem(
          key: _curateKey,
          isActive: widget.isCurated || _showingPopover,
          icon: AppIcons.sideCurate(size: 32),
          label: widget.curateCount,
          onTap: _togglePopover,
        ),
      ]);
    }

    children.addAll([
      const SizedBox(height: 13),
      _ActionItem(
        icon: AppIcons.share(size: 32),
        onTap: widget.onShare,
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

    if (widget.soundCover != null) {
      children.addAll([
        const SizedBox(height: 13),
        _SoundItem(
          cover: widget.soundCover!,
          onTap: widget.onSoundTap,
        ),
      ]);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _ActionItem extends StatefulWidget {
  const _ActionItem({
    required this.icon,
    this.label,
    this.onTap,
    this.isActive = false,
    super.key,
  });

  final Widget icon;
  final String? label;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  State<_ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<_ActionItem> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 30),
    ]).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeOut));
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
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceController.isAnimating ? _bounceAnimation.value : (widget.isActive ? 1.05 : 1.0),
                child: child,
              );
            },
            child: SizedBox(width: 40, height: 40, child: Center(child: widget.icon)),
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
  const _SoundItem({
    required this.cover,
    this.onTap,
  });

  final String cover;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const albumSize = 35.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: albumSize,
        height: albumSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(cover),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _CuratePopover extends StatelessWidget {
  const _CuratePopover({required this.destinations, required this.onSelected});
  final List<CurateDestination> destinations;
  final ValueChanged<CurateDestination> onSelected;

  @override
  Widget build(BuildContext context) {
    return _ConnectorPopover(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < destinations.length; i++) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(destinations[i]),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  destinations[i].label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (i < destinations.length - 1)
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.25),
              ),
          ],
        ],
      ),
    );
  }
}

/// Popover shape: rounded rectangle with a circular connector bubble
/// protruding from the top-right that visually aligns with the curate icon.
class _ConnectorPopover extends StatelessWidget {
  const _ConnectorPopover({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: _ConnectorShape(
        child: ClipPath(
          clipper: _ConnectorPopoverClipper(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              // Increased vertical padding + larger right padding to account for bigger connector circle
              padding: const EdgeInsets.fromLTRB(20, 18, 60, 18),
              decoration: const BoxDecoration(),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectorShape extends StatelessWidget {
  const _ConnectorShape({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _ConnectorPopoverBorderPainter(),
      painter: _ConnectorPopoverBackgroundPainter(),
      child: child,
    );
  }
}

class _ConnectorPopoverClipper extends CustomClipper<Path> {
  static const double radius = 22; // slightly larger pill
  static const double connectorRadius = 24; // bigger circle to wrap icon
  static const double overlap = 10; // how much circle cuts into main rect
  static const double connectorShiftX = 16; // pushes circle further right
  static const double connectorShiftDown = 24; // pushes circle downward

  @override
  Path getClip(Size size) {
    // Main body excludes connector width minus overlap
    final bodyWidth = size.width - (connectorRadius - connectorShiftX) + overlap;
    final bodyRect = RRect.fromLTRBR(0, 0, bodyWidth, size.height, const Radius.circular(radius));
    final rectPath = Path()..addRRect(bodyRect);
    final circleCenter = Offset(
      bodyWidth - overlap + connectorShiftX,
      connectorRadius + connectorShiftDown,
    ); // shifted circle
    final circlePath = Path()..addOval(Rect.fromCircle(center: circleCenter, radius: connectorRadius));
    return Path.combine(PathOperation.union, rectPath, circlePath);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ConnectorPopoverBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final clipper = _ConnectorPopoverClipper();
    final path = clipper.getClip(size);
    final paintFill = Paint()..color = Colors.white.withValues(alpha: 0.20);
    canvas.drawPath(path, paintFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConnectorPopoverBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final clipper = _ConnectorPopoverClipper();
    final path = clipper.getClip(size);
    final border = Paint()
      ..color = Colors.white.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
