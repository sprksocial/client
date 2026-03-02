import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:spark/src/core/utils/logging/logging.dart';
import 'package:spark/src/features/posting/ui/models/media_selection.dart';

Future<MediaLibrarySelection?> showMediaLibraryPickerSheet(
  BuildContext context, {
  bool showMultiPhotoButton = true,
  int maxMultiPhotoSelection = 12,
}) {
  return showModalBottomSheet<MediaLibrarySelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.9,
        child: MediaLibraryPickerPage(
          showMultiPhotoButton: showMultiPhotoButton,
          maxMultiPhotoSelection: maxMultiPhotoSelection,
        ),
      );
    },
  );
}

class MediaLibraryPickerPage extends StatefulWidget {
  const MediaLibraryPickerPage({
    this.showMultiPhotoButton = true,
    this.maxMultiPhotoSelection = 12,
    super.key,
  });

  final bool showMultiPhotoButton;
  final int maxMultiPhotoSelection;

  @override
  State<MediaLibraryPickerPage> createState() => _MediaLibraryPickerPageState();
}

class _MediaLibraryPickerPageState extends State<MediaLibraryPickerPage> {
  static const int _pageSize = 80;

  final ScrollController _scrollController = ScrollController();
  final List<AssetEntity> _assets = <AssetEntity>[];
  final List<AssetEntity> _selectedPhotoAssets = <AssetEntity>[];
  late final SparkLogger _logger;

  AssetPathEntity? _assetPath;
  bool _isLoading = true;
  bool _hasPermission = false;
  bool _isLimitedPermission = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isMultiPhotoSelection = false;
  int _currentPage = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _logger = GetIt.instance<LogService>().getLogger('MediaLibraryPickerPage');
    _scrollController.addListener(_onScroll);
    _requestPermissionAndLoadAssets();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final triggerOffset = position.maxScrollExtent - 600;
    if (position.pixels >= triggerOffset) {
      _loadNextPage();
    }
  }

  Future<void> _requestPermissionAndLoadAssets() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _assets.clear();
        _selectedPhotoAssets.clear();
        _assetPath = null;
        _currentPage = 0;
        _hasMore = true;
      });

      final permissionState = await PhotoManager.requestPermissionExtend();
      if (!mounted) return;

      if (!permissionState.isAuth && !permissionState.hasAccess) {
        setState(() {
          _hasPermission = false;
          _isLimitedPermission = false;
          _isLoading = false;
        });
        return;
      }

      final paths = await PhotoManager.getAssetPathList();
      if (!mounted) return;

      _hasPermission = true;
      _isLimitedPermission = permissionState == PermissionState.limited;

      if (paths.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
        return;
      }

      _assetPath = paths.first;
      await _loadNextPage();

      if (!mounted) return;
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to load media library',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load your photo library.';
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (_assetPath == null || _isLoadingMore || !_hasMore) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final pageAssets = await _assetPath!.getAssetListPaged(
        page: _currentPage,
        size: _pageSize,
      );

      if (!mounted) return;
      setState(() {
        _assets.addAll(pageAssets);
        _currentPage += 1;
        _hasMore = pageAssets.length == _pageSize;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to load next media page',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load more items.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _handleAssetTap(AssetEntity asset) async {
    if (_isMultiPhotoSelection) {
      _toggleMultiPhotoSelection(asset);
      return;
    }

    final file = await _assetToXFile(asset, showErrorMessage: true);
    if (file == null || !mounted) return;

    if (asset.type == AssetType.video) {
      Navigator.of(context).pop(SingleVideoSelection(file));
      return;
    }

    Navigator.of(context).pop(SinglePhotoSelection(file));
  }

  void _toggleMultiPhotoSelection(AssetEntity asset) {
    if (asset.type != AssetType.image) {
      _showSnackBar('You can only select photos in multi-select mode.');
      return;
    }

    final selectedIndex = _selectedPhotoAssets.indexWhere(
      (element) => element.id == asset.id,
    );

    if (selectedIndex >= 0) {
      setState(() {
        _selectedPhotoAssets.removeAt(selectedIndex);
      });
      return;
    }

    if (_selectedPhotoAssets.length >= widget.maxMultiPhotoSelection) {
      _showSnackBar('You can select up to ${widget.maxMultiPhotoSelection}.');
      return;
    }

    setState(() {
      _selectedPhotoAssets.add(asset);
    });
  }

  Future<void> _submitMultiPhotoSelection() async {
    if (_selectedPhotoAssets.isEmpty) return;

    final files = <XFile>[];
    for (final asset in _selectedPhotoAssets) {
      final file = await _assetToXFile(asset, showErrorMessage: false);
      if (file != null) {
        files.add(file);
      }
    }

    if (files.isEmpty) {
      _showSnackBar('Unable to access the selected photos.');
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(MultiPhotoSelection(files));
  }

  Future<XFile?> _assetToXFile(
    AssetEntity asset, {
    required bool showErrorMessage,
  }) async {
    try {
      final file = await asset.file ?? await asset.originFile;
      if (file == null) {
        if (showErrorMessage) {
          _showSnackBar('Unable to access this media item.');
        }
        return null;
      }

      return XFile(file.path);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed converting asset to file',
        error: e,
        stackTrace: stackTrace,
      );
      if (showErrorMessage) {
        _showSnackBar('Unable to access this media item.');
      }
      return null;
    }
  }

  void _toggleMultiSelectionMode() {
    setState(() {
      if (_isMultiPhotoSelection) {
        _selectedPhotoAssets.clear();
      }
      _isMultiPhotoSelection = !_isMultiPhotoSelection;
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<AssetEntity> get _mediaAssets {
    return _assets
        .where(
          (asset) =>
              asset.type == AssetType.image || asset.type == AssetType.video,
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final multiSelectLabel = _isMultiPhotoSelection
        ? 'Single Select'
        : 'Select multiple';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Material(
        color: colorScheme.surface,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withAlpha(60),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close),
                  ),
                  const Expanded(
                    child: Text(
                      'Library',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            if (widget.showMultiPhotoButton)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _toggleMultiSelectionMode,
                        icon: Icon(
                          _isMultiPhotoSelection
                              ? Icons.filter_1
                              : Icons.collections_outlined,
                        ),
                        label: Text(multiSelectLabel),
                      ),
                    ),
                    if (_isMultiPhotoSelection) ...[
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _selectedPhotoAssets.isEmpty
                            ? null
                            : _submitMultiPhotoSelection,
                        child: Text(
                          'Done (${_selectedPhotoAssets.length}/${widget.maxMultiPhotoSelection})',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            if (_isLimitedPermission)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Limited library access is enabled. '
                  'You can change this in settings.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            const Divider(height: 1),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasPermission) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_library_outlined, size: 40),
              const SizedBox(height: 12),
              const Text(
                'Allow photo library access to pick photos and videos.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _requestPermissionAndLoadAssets,
                child: const Text('Allow Access'),
              ),
              const SizedBox(height: 8),
              const TextButton(
                onPressed: PhotoManager.openSetting,
                child: Text('Open Settings'),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null && _mediaAssets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_mediaAssets.isEmpty) {
      return const Center(
        child: Text('No photos or videos found in your library.'),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _mediaAssets.length,
      itemBuilder: (context, index) {
        final asset = _mediaAssets[index];
        final isVideo = asset.type == AssetType.video;
        final isDisabled = _isMultiPhotoSelection && isVideo;
        final selectedIndex = _selectedPhotoAssets.indexWhere(
          (element) => element.id == asset.id,
        );
        final isSelected = selectedIndex >= 0;

        return GestureDetector(
          onTap: () => _handleAssetTap(asset),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _AssetThumbnail(asset: asset),
              if (isVideo)
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDuration(Duration(seconds: asset.duration)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (_isMultiPhotoSelection)
                Positioned(
                  top: 6,
                  right: 6,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black.withAlpha(110),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isSelected ? '${selectedIndex + 1}' : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (isDisabled)
                Container(
                  color: Colors.black.withAlpha(140),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.block,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}

class _AssetThumbnail extends StatefulWidget {
  const _AssetThumbnail({required this.asset});

  final AssetEntity asset;

  @override
  State<_AssetThumbnail> createState() => _AssetThumbnailState();
}

class _AssetThumbnailState extends State<_AssetThumbnail> {
  late final Future<Uint8List?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _thumbnailFuture = widget.asset.thumbnailDataWithSize(
      const ThumbnailSize.square(300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _thumbnailFuture,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const SizedBox.expand(),
          );
        }

        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      },
    );
  }
}
