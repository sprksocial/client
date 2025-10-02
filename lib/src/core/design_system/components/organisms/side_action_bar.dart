import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';
import 'package:sparksocial/src/core/design_system/tokens/colors.dart';
import 'package:sparksocial/src/core/design_system/tokens/constants.dart';

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
    this.onCurate,
    this.onShare,
    this.likeCount,
    this.commentCount,
    this.curateCount,
    this.shareCount,
    this.isLiked = false,
    this.isCurated = false,
    this.curateDestinations = const <CurateDestination>[
      CurateDestination('Feed 1'),
      CurateDestination('Feed 2'),
      CurateDestination('Feed 3'),
    ],
  });

  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onCurate; // called after a feed selection (or when opening?)
  final VoidCallback? onShare;

  final String? likeCount;
  final String? commentCount;
  final String? curateCount;
  final String? shareCount;

  final bool isLiked;
  final bool isCurated;
  final List<CurateDestination> curateDestinations;

  @override
  State<SparkSideActionBar> createState() => _SparkSideActionBarState();
}

class _SparkSideActionBarState extends State<SparkSideActionBar> {
  final GlobalKey _curateKey = GlobalKey();
  OverlayEntry? _overlay;
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

    _overlay = OverlayEntry(
      builder: (ctx) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _removePopover,
          child: Stack(
            children: [
              Positioned(
                top: target.dy - 8,
                right: MediaQuery.of(context).size.width - target.dx - size.width / 2 - 6,
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

    Overlay.of(context).insert(_overlay!);
    setState(() => _showingPopover = true);
  }

  void _removePopover() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _showingPopover = false);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppConstants.blurBottomBar.toDouble(),
          sigmaY: AppConstants.blurBottomBar.toDouble(),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionItem(
                isActive: widget.isLiked,
                label: widget.likeCount,
                icon: widget.isLiked ? AppIcons.like(color: AppColors.primary500) : AppIcons.like(color: Colors.white),
                onTap: widget.onLike,
              ),
              const SizedBox(height: 20),
              _ActionItem(
                icon: AppIcons.comment(size: 32),
                label: widget.commentCount,
                onTap: widget.onComment,
              ),
              const SizedBox(height: 20),
              _ActionItem(
                key: _curateKey,
                // Active if externally marked as curated OR while the popover is visible.
                isActive: widget.isCurated || _showingPopover,
                icon: AppIcons.sideCurate(size: 32),
                label: widget.curateCount,
                onTap: _togglePopover,
              ),
              const SizedBox(height: 20),
              _ActionItem(
                icon: AppIcons.sideShare(size: 80),
                label: widget.shareCount,
                onTap: widget.onShare,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          AnimatedScale(
            scale: isActive ? 1.05 : 1.0,
            duration: AppConstants.animationFast,
            child: SizedBox(width: 40, height: 40, child: Center(child: icon)),
          ),
          if (label != null && label!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label!,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.1,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
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
    // Shape with notch on right side where action button sits.
    return Material(
      type: MaterialType.transparency,
      child: ClipPath(
        clipper: _PopoverClipper(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(140),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withAlpha(39)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final d in destinations)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelected(d),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        d.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PopoverClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const notchSize = 24.0; // width of the right side notch
    const radius = 18.0;
    final path = Path();
    // Start top-left
    path.moveTo(radius, 0);
    path.quadraticBezierTo(0, 0, 0, radius);
    path.lineTo(0, size.height - radius);
    path.quadraticBezierTo(0, size.height, radius, size.height);
    // Bottom to right (before notch)
    path.lineTo(size.width - radius, size.height);
    path.quadraticBezierTo(size.width, size.height, size.width, size.height - radius);
    // Up to notch start
    path.lineTo(size.width, notchSize + radius);
    // Notch inward (to align with action button circle)
    path.quadraticBezierTo(size.width, notchSize, size.width - radius, notchSize);
    // Continue up with corner
    path.lineTo(radius + 4, notchSize);
    path.quadraticBezierTo(0, notchSize, 0, notchSize - radius);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
