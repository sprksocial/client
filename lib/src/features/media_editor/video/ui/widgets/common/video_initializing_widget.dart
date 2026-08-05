import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';

/// A widget that displays an initializing screen while the video editor starts.
class VideoInitializingWidget extends StatelessWidget {
  const VideoInitializingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.grey700,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary500.withAlpha(140),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.video_settings_outlined,
                        size: 34,
                        color: AppColors.primary500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Initializing editor…',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyWhite,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary500),
                    backgroundColor: AppColors.grey700,
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
