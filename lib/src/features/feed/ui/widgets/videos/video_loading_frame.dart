import 'package:material_ui/material_ui.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/features/feed/ui/widgets/videos/video_frame.dart';

class FeedVideoLoadingFrame extends StatelessWidget {
  const FeedVideoLoadingFrame({
    required this.thumbnail,
    required this.videoAspectRatio,
    required this.isActive,
    required this.hasError,
    required this.onRetry,
    super.key,
  });

  final String thumbnail;
  final double? videoAspectRatio;
  final bool isActive;
  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.black),
        FeedVideoThumbnailFrame(
          thumbnail: thumbnail,
          videoAspectRatio: videoAspectRatio,
        ),
        if (isActive)
          ColoredBox(
            color: AppColors.black.withValues(alpha: 0.55),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 56,
                  vertical: 24,
                ),
                child: Semantics(
                  liveRegion: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!hasError) ...[
                        const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      Text(
                        hasError
                            ? l10n.videoPlaybackFailed
                            : l10n.videoPreparing,
                        textAlign: TextAlign.center,
                        style: AppTypography.textLargeBold.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hasError
                            ? l10n.videoPlaybackFailedDescription
                            : l10n.videoPreparingDescription,
                        textAlign: TextAlign.center,
                        style: AppTypography.textMediumMedium.copyWith(
                          color: AppColors.grey300,
                        ),
                      ),
                      if (hasError) ...[
                        const SizedBox(height: 20),
                        AppButton(label: l10n.buttonRetry, onPressed: onRetry),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
