import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/tokens/gradients.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/ui/foundation/colors.dart';

enum StoryType { story, live, cf, create }

class StoryCircle extends StatelessWidget {
  final StoryType type;
  final String userName;
  final String imageUrl;
  final String live;

  const StoryCircle._({
    required this.type,
    required this.userName,
    required this.imageUrl,
    required this.live,
  });

  /// Constructor variant for an unread story with a gradient border.
  factory StoryCircle.story({
    required String userName,
    required String imageUrl,
  }) {
    return StoryCircle._(
      type: StoryType.story,
      userName: userName,
      imageUrl: imageUrl,
      live: '',
    );
  }

  /// Constructor variant for a live story with a "LIVE" badge.
  factory StoryCircle.live({
    required String userName,
    required String imageUrl,
    required String live,
  }) {
    return StoryCircle._(
      type: StoryType.live,
      userName: userName,
      imageUrl: imageUrl,
      live: live,
    );
  }

  /// Constructor variant for a "Close Friends" story with a green border.
  factory StoryCircle.cf({
    required String userName,
    required String imageUrl,
  }) {
    return StoryCircle._(
      type: StoryType.cf,
      userName: userName,
      imageUrl: imageUrl,
      live: '',
    );
  }

  /// Constructor variant for the user to create their own story.
  /// Displays a "+" icon overlay.
  factory StoryCircle.create({
    required String userName,
    required String imageUrl,
  }) {
    return StoryCircle._(
      type: StoryType.create,
      userName: userName,
      imageUrl: imageUrl,
      live: '',
    );
  }

  static const double _widgetWidth = 74;
  static const double _widgetHeight = 102;
  static const double _imageContainerSize = 74;
  static const double _imageSize = 64;
  static const double _ringWidth = 2;
  static const double _ringGap = 3;
  static const double _liveGap = 10;
  static const double _gap = 5;

  @override
  Widget build(BuildContext context) {
    final hasStoryRing = type != StoryType.create;
    final ringColor = _getRingColor();

    return SizedBox(
      width: _widgetWidth,
      height: _widgetHeight,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: _imageContainerSize,
                height: _imageContainerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasStoryRing ? ringColor : Colors.transparent,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(_ringWidth),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(_ringGap),
                      child: ClipOval(
                        child: imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: _imageSize,
                                height: _imageSize,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  width: _imageSize,
                                  height: _imageSize,
                                  color: const Color(0xFFD9D9D9),
                                  child: const Icon(
                                    Icons.person,
                                    size: _imageSize * 0.5,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Container(
                                width: _imageSize,
                                height: _imageSize,
                                color: const Color(0xFFD9D9D9),
                                child: const Icon(
                                  Icons.person,
                                  size: _imageSize * 0.5,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              if (type == StoryType.live) _LiveBadge(live: live),
              if (type == StoryType.create) _CreateButton(),
            ],
          ),
          SizedBox(height: type == StoryType.live ? _liveGap : _gap),
          SizedBox(
            width: _widgetWidth,
            child: Text(
              userName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textExtraSmallThin,
            ),
          ),
        ],
      ),
    );
  }

  Color? _getRingColor() {
    switch (type) {
      case StoryType.story:
      case StoryType.live:
      case StoryType.cf:
        return AppColors.primary;
      case StoryType.create:
        return null;
    }
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({
    required this.live,
  });

  final String live;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          gradient: AppGradients.accent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 2),
        ),
        child: Text(live, style: AppTypography.textExtraSmallMedium),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          border: Border.all(
            width: 2,
            color: isDarkMode ? AppColors.deepPurple : AppColors.white,
          ),
        ),
        child: const Center(
          child: Icon(
            FluentIcons.add_24_filled,
            size: 14,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
