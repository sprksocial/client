import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/features/upload/providers/upload_provider.dart';
import 'package:sparksocial/src/features/upload/ui/widgets/upload_progress_indicator.dart';

class BackgroundUploadIndicator extends ConsumerWidget {
  const BackgroundUploadIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadNotifier = ref.watch(uploadNotifierProvider.notifier);
    final isAnyTaskActive = uploadNotifier.isAnyTaskActive;
    final isAnyTaskCompleted = uploadNotifier.isAnyTaskCompleted;

    if (!isAnyTaskActive && !isAnyTaskCompleted) {
      return const SizedBox.shrink();
    }

    return UploadProgressIndicator(
      isUploading: isAnyTaskActive,
      isCompleted: isAnyTaskCompleted && !isAnyTaskActive,
      onDismiss: () {
        uploadNotifier.clearCompletedTasks();
      },
    );
  }
} 