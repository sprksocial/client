import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/network/atproto/data/models/feed_models.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

/// A widget that allows selecting between different feed types.
class FeedSelector extends StatelessWidget {
  /// The currently selected feed type value
  final FeedType selectedFeedType;
  
  /// Callback when a feed option is selected
  final ValueChanged<FeedType> onFeedTypeSelected;
  
  /// Height of the selector
  final double height;
  
  /// Optional padding for the selector
  final EdgeInsets? padding;

  const FeedSelector({
    super.key,
    required this.selectedFeedType,
    required this.onFeedTypeSelected,
    this.height = 38,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Get all available feed types
    final options = FeedType.values;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent, 
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(options.length, (index) {
          final option = options[index];
          final isSelected = option == selectedFeedType;

          return Expanded(
            child: GestureDetector(
              onTap: () => onFeedTypeSelected(option),
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.pink.withAlpha(51) : Colors.transparent,
                  border: isSelected ? Border.all(color: AppColors.pink, width: 1.5) : null,
                  borderRadius: BorderRadius.circular(50),
                ),
                alignment: Alignment.center,
                child: Text(
                  option.name,
                  style: TextStyle(
                    color: AppColors.lightLavender,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
} 