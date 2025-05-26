import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/providers/feed_option_provider.dart';

/// A widget that allows selecting between different feed types.
class FeedOption extends ConsumerWidget {
  const FeedOption({
    required this.feed,
    super.key,
  });

  final Feed feed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(feedOptionProvider(feed));
     GestureDetector(
              onTap: () => , // TODO: navigate to feed route
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.pink.withAlpha(51) : Colors.transparent,
                  border: isSelected ? Border.all(color: AppColors.pink, width: 1.5) : null,
                  borderRadius: BorderRadius.circular(50),
                ),
                alignment: Alignment.center,
                child: Text(
                  feed.name,
                  style: TextStyle(
                    color: AppColors.lightLavender,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
      ),
    );
  }
}
