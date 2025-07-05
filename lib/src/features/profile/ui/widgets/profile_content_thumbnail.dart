import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';

class ProfileContentThumbnail extends StatelessWidget {
  const ProfileContentThumbnail({
    required this.index,
    required this.backgroundColor,
    required this.icon,
    required this.viewCount,
    super.key,
    this.duration,
  });
  final int index;
  final Color backgroundColor;
  final IconData icon;
  final String viewCount;
  final String? duration;

  @override
  Widget build(BuildContext context) {
    final logger = GetIt.instance<LogService>().getLogger('ProfileContentThumbnail');

    return GestureDetector(
      onTap: () {
        logger.d('Content clicked at index $index');
      },
      child: ColoredBox(
        color: backgroundColor,
        child: Stack(
          children: [
            Center(child: Icon(icon, color: AppColors.white.withAlpha(204), size: 24)),
            Positioned(
              bottom: 5,
              left: 5,
              child: Row(
                children: [
                  const Icon(FluentIcons.eye_24_regular, color: AppColors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(viewCount, style: const TextStyle(color: AppColors.white, fontSize: 12)),
                ],
              ),
            ),
            if (duration != null)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.black.withAlpha(128), borderRadius: BorderRadius.circular(4)),
                  child: Text(duration!, style: const TextStyle(color: AppColors.white, fontSize: 10)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
