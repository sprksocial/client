import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';

class DemoBuildStickers extends StatefulWidget {
  const DemoBuildStickers({
    required this.setLayer,
    required this.scrollController,
    super.key,
  });

  final void Function(WidgetLayer layer) setLayer;
  final ScrollController scrollController;

  @override
  State<DemoBuildStickers> createState() => _DemoBuildStickersState();
}

class _DemoBuildStickersState extends State<DemoBuildStickers> {
  static const _titles = <String>[
    'Recent',
    'Favorites',
    'Shapes',
    'Funny',
    'Boring',
    'Frog',
    'Snow',
    'More',
  ];

  int _selectedCategoryIndex = 0;
  bool _isSwitchingCategory = false;
  int? _pendingCategoryIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _DragHandle(),
          _SheetHeader(
            title: 'Stickers',
            onClose: () => Navigator.of(context).pop(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _CategoryChips(
              titles: _titles,
              selectedIndex: _selectedCategoryIndex,
              onSelected: _onSelectCategory,
            ),
          ),
          Flexible(
            child: AnimatedSlide(
              offset: _isSwitchingCategory
                  ? const Offset(0, 0.03)
                  : Offset.zero,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _isSwitchingCategory ? 0 : 1,
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                child: _StickerGrid(
                  categoryIndex: _selectedCategoryIndex,
                  scrollController: widget.scrollController,
                  onPickSticker: _onPickSticker,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSelectCategory(int index) {
    if (index == _selectedCategoryIndex) return;
    if (_isSwitchingCategory) {
      _pendingCategoryIndex = index;
      return;
    }
    unawaited(_switchCategory(index));
  }

  Future<void> _onPickSticker(String url) async {
    final stickerWidget = _StickerContent(url: url);

    LoadingDialog.instance.show(
      context,
      configs: const ProImageEditorConfigs(),
      theme: Theme.of(context),
    );

    try {
      await precacheImage(NetworkImage(url), context);
    } finally {
      LoadingDialog.instance.hide();
    }

    if (!mounted) return;
    widget.setLayer(WidgetLayer(widget: stickerWidget));
  }

  Future<void> _switchCategory(int index) async {
    setState(() => _isSwitchingCategory = true);
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    setState(() {
      _selectedCategoryIndex = index;
      _isSwitchingCategory = false;
    });

    final pending = _pendingCategoryIndex;
    if (pending == null || pending == _selectedCategoryIndex) return;

    _pendingCategoryIndex = null;
    if (!mounted) return;
    await _switchCategory(pending);
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.grey600,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.title,
    required this.onClose,
  });

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.titles,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> titles;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: titles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return _CategoryChip(
            title: titles[index],
            selected: selected,
            onTap: () => onSelected(index),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected ? AppColors.grey700 : AppColors.grey800;
    final border = selected ? AppColors.greyWhite : AppColors.grey700;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border.withValues(alpha: 0.35)),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _StickerGrid extends StatelessWidget {
  const _StickerGrid({
    required this.categoryIndex,
    required this.scrollController,
    required this.onPickSticker,
  });

  final int categoryIndex;
  final ScrollController scrollController;
  final Future<void> Function(String url) onPickSticker;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: GridView.builder(
        controller: scrollController,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 88,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: _itemCount(categoryIndex),
        itemBuilder: (context, index) {
          final url = _stickerUrl(categoryIndex: categoryIndex, index: index);
          return _StickerTile(
            url: url,
            onTap: () => onPickSticker(url),
          );
        },
      ),
    );
  }

  int _itemCount(int categoryIndex) {
    final offset = categoryIndex * 20;
    return max(12, 12 + offset % 12);
  }

  String _stickerUrl({
    required int categoryIndex,
    required int index,
  }) {
    final offset = categoryIndex * 20;
    final id = offset + (index + 3) * 3;
    return 'https://picsum.photos/id/$id/800';
  }
}

class _StickerTile extends StatelessWidget {
  const _StickerTile({
    required this.url,
    required this.onTap,
  });

  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: AppColors.grey800,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _StickerContent(url: url),
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.greyWhite.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickerContent extends StatelessWidget {
  const _StickerContent({
    required this.url,
  });

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          final expected = loadingProgress.expectedTotalBytes;
          final progress = expected == null
              ? null
              : loadingProgress.cumulativeBytesLoaded / expected;
          return ColoredBox(
            color: AppColors.grey700,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const ColoredBox(
            color: AppColors.grey700,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.white70,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}
