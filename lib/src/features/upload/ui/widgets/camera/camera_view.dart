import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';

import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';

class CameraView extends StatefulWidget {
  final CameraController? cameraController;
  final bool isInitialized;

  const CameraView({
    super.key, 
    required this.cameraController, 
    required this.isInitialized,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final _logger = GetIt.instance<LogService>().getLogger('CameraView');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (!widget.isInitialized || 
        widget.cameraController == null || 
        !widget.cameraController!.value.isInitialized) {
      return Container(
        color: AppColors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Initializing camera...', 
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    try {
      final aspectRatio = widget.cameraController!.value.aspectRatio;

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: aspectRatio, 
          child: CameraPreview(widget.cameraController!),
        ),
      );
    } catch (e) {
      _logger.e('Error building camera view', error: e);
      return Container(
        color: AppColors.black,
        child: Center(
          child: Text(
            'Camera preview unavailable', 
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.red,
            ),
          ),
        ),
      );
    }
  }
} 