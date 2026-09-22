import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/media/media_gallery_service.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

class ReviewMediaSaveAction extends StatefulWidget {
  const ReviewMediaSaveAction({
    required this.save,
    required this.canSave,
    required this.builder,
    super.key,
  });

  final Future<void> Function(MediaGalleryService gallery) save;
  final bool canSave;
  final Widget Function(
    BuildContext context,
    VoidCallback onSave,
    bool isSaving,
  )
  builder;

  @override
  State<ReviewMediaSaveAction> createState() => _ReviewMediaSaveActionState();
}

class _ReviewMediaSaveActionState extends State<ReviewMediaSaveAction> {
  late final SparkLogger _logger = GetIt.I<LogService>().getLogger(
    'ReviewMediaSaveAction',
  );
  bool _isSaving = false;

  Future<void> _save() async {
    if (_isSaving || !widget.canSave) return;
    setState(() => _isSaving = true);

    try {
      await widget.save(GetIt.I<MediaGalleryService>());
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context).messageSavedToPhotos);
    } on MediaGalleryPermissionDeniedException catch (error, stackTrace) {
      _logger.w(
        'Photo library permission denied while saving reviewed media',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      _showMessage(
        AppLocalizations.of(context).errorPhotoLibrarySavePermission,
      );
    } catch (error, stackTrace) {
      _logger.e(
        'Failed to save reviewed media to the photo library',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context).errorUnableToSaveToPhotos);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _save, _isSaving);
}
