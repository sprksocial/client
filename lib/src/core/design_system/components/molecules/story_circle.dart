import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/icons.dart';
import 'package:sparksocial/src/core/design_system/tokens/gradients.dart';
import 'package:sparksocial/src/core/design_system/tokens/typography.dart';

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
  static const double _liveGap = 10;
  static const double _gap = 5;

  @override
  Widget build(BuildContext context) {
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
                  gradient: _getBorderGradient(),
                  // border: Border.all(width: 2, color: AppColors.primary500),
                  // borderRadius: BorderRadius.circular(_imageContainerSize / 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
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

  LinearGradient? _getBorderGradient() {
    switch (type) {
      case StoryType.story:
      case StoryType.live:
        return AppGradients.accent;
      case StoryType.cf:
        return AppGradients.green;
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
    return Positioned(
      right: 4,
      bottom: 4,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppGradients.accent,
          border: Border.all(width: 2, color: Theme.of(context).colorScheme.surface),
        ),
        child: AppIcons.add(size: 16, color: Colors.white),
      ),
    );
  }
}
