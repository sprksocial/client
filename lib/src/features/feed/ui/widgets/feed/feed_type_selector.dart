import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/features/feed/providers/feed_type_provider.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/feed/feed_selector.dart';

/// A widget that allows the user to select between different feed types
/// and automatically connects to the FeedTypeProvider.
class FeedTypeSelector extends ConsumerWidget {
  /// Height of the selector
  final double height;
  
  /// Optional padding
  final EdgeInsets? padding;
  
  /// Callback triggered when the feed type changes
  final Function(FeedType)? onFeedTypeChanged;

  const FeedTypeSelector({
    super.key,
    this.height = 38,
    this.padding,
    this.onFeedTypeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current feed type from the provider
    final selectedFeedType = ref.watch(feedTypeNotifierProvider);
    
    return FeedSelector(
      selectedFeedType: selectedFeedType,
      onFeedTypeSelected: (feedType) {
        // Update the provider state
        ref.read(feedTypeNotifierProvider.notifier).setFeedType(feedType);
        
        // Call the optional callback if provided
        if (onFeedTypeChanged != null) {
          onFeedTypeChanged!(feedType);
        }
      },
      height: height,
      padding: padding,
    );
  }
} 