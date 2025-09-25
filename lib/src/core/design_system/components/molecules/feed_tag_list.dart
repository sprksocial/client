import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/tags/feed_tag.dart';

class FeedTagList extends StatefulWidget {
  const FeedTagList({
    required this.tags,
    super.key,
    this.selectedTagId,
    this.onTagTap,
  });

  final List<({String id, String text})> tags;
  final String? selectedTagId;
  final Function(String tagId)? onTagTap;

  @override
  State<FeedTagList> createState() => _FeedTagListState();
}

class _FeedTagListState extends State<FeedTagList> {
  String? _selectedTagId;

  @override
  void initState() {
    super.initState();
    _selectedTagId = widget.selectedTagId;
  }

  void _handleTagTap(String tagId) {
    setState(() {
      _selectedTagId = tagId;
    });
    widget.onTagTap?.call(tagId);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 30),
        itemCount: widget.tags.length,
        itemBuilder: (context, index) {
          final tag = widget.tags[index];
          return FeedTag(
            id: tag.id,
            text: tag.text,
            selected: _selectedTagId == tag.id,
            onTap: () => _handleTagTap(tag.id),
          );
        },
      ),
    );
  }
}
