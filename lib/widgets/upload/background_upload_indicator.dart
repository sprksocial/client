import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/upload_service.dart';
import 'upload_progress_indicator.dart';

class BackgroundUploadIndicator extends StatelessWidget {
  const BackgroundUploadIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UploadService>(
      builder: (context, uploadService, _) {
        if (!uploadService.isAnyTaskActive && !uploadService.isAnyTaskCompleted) {
          return const SizedBox.shrink();
        }

        return UploadProgressIndicator(
          isUploading: uploadService.isAnyTaskActive,
          isCompleted: uploadService.isAnyTaskCompleted && !uploadService.isAnyTaskActive,
          onDismiss: () {
            uploadService.clearCompletedTasks();
          },
        );
      },
    );
  }
}
