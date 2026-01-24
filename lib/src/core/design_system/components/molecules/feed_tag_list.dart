import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spark/src/core/design_system/components/atoms/tags/feed_tag.dart';

/// Data class representing a feed tag with additional metadata for operations
class FeedTagData {
  const FeedTagData({
    required this.id,
    required this.text,
    this.isTimeline = false,
    this.isLiked = false,
    this.canDelete = true,
  });

  final String id;
  final String text;
  final bool isTimeline;
  final bool isLiked;
  final bool canDelete;
}

class FeedTagList extends StatefulWidget {
  const FeedTagList({
    required this.tags,
    super.key,
    this.selectedTagId,
    this.onTagTap,
    this.onReorder,
    this.onLongPress,
    this.enableReordering = false,
  });

  final List<FeedTagData> tags;
  final String? selectedTagId;
  final Function(String tagId)? onTagTap;
  final Function(int oldIndex, int newIndex)? onReorder;
  final Function(FeedTagData tag)? onLongPress;
  final bool enableReordering;

  @override
  State<FeedTagList> createState() => _FeedTagListState();
}

class _FeedTagListState extends State<FeedTagList> {
  String? _selectedTagId;
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    _selectedTagId = widget.selectedTagId;
  }

  @override
  void didUpdateWidget(FeedTagList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTagId != oldWidget.selectedTagId) {
      setState(() {
        _selectedTagId = widget.selectedTagId;
      });
    }
  }

  void _handleTagTap(String tagId) {
    if (_isReordering) return;
    setState(() {
      _selectedTagId = tagId;
    });
    widget.onTagTap?.call(tagId);
  }

  void _handleLongPress(FeedTagData tag) {
    HapticFeedback.mediumImpact();
    widget.onLongPress?.call(tag);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enableReordering && widget.onReorder != null) {
      return SizedBox(
        height: 30,
        child: ReorderableListView.builder(
          scrollDirection: Axis.horizontal,
          buildDefaultDragHandles: false,
          onReorderStart: (index) {
            HapticFeedback.mediumImpact();
            setState(() {
              _isReordering = true;
            });
          },
          onReorderEnd: (index) {
            setState(() {
              _isReordering = false;
            });
          },
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex -= 1;
            widget.onReorder?.call(oldIndex, newIndex);
          },
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final animValue = Curves.easeInOutCubic.transform(
                  animation.value,
                );
                final scale = lerpDouble(1, 1.1, animValue)!;

                return Transform.scale(
                  scale: scale,
                  child: Material(
                    color: Colors.transparent,
                    child: child,
                  ),
                );
              },
              child: child,
            );
          },
          itemCount: widget.tags.length,
          itemBuilder: (context, index) {
            final tag = widget.tags[index];
            return Padding(
              key: ValueKey(tag.id),
              padding: EdgeInsets.only(
                right: index < widget.tags.length - 1 ? 30 : 0,
              ),
              child: ReorderableDelayedDragStartListener(
                index: index,
                child: GestureDetector(
                  onLongPress: widget.onLongPress != null
                      ? () => _handleLongPress(tag)
                      : null,
                  child: FeedTag(
                    id: tag.id,
                    text: tag.text,
                    selected: _selectedTagId == tag.id,
                    onTap: () => _handleTagTap(tag.id),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Non-reorderable version with long press support
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 30),
        itemCount: widget.tags.length,
        itemBuilder: (context, index) {
          final tag = widget.tags[index];
          return GestureDetector(
            onLongPress: widget.onLongPress != null
                ? () => _handleLongPress(tag)
                : null,
            child: FeedTag(
              id: tag.id,
              text: tag.text,
              selected: _selectedTagId == tag.id,
              onTap: () => _handleTagTap(tag.id),
            ),
          );
        },
      ),
    );
  }
}
