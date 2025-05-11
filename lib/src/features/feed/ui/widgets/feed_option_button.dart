import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

/// A button used in feed selection components to navigate between different 
/// feed options.
class FeedOptionButton extends StatelessWidget {
  /// The text displayed on the button
  final String label;
  
  /// Whether this option is currently selected
  final bool isSelected;
  
  /// Callback when the button is tapped
  final VoidCallback onTap;
  
  /// Optional width of the button
  final double? width;
  
  /// Height of the button
  final double height;
  
  /// Optional padding for the button content
  final EdgeInsets? padding;

  const FeedOptionButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.width,
    this.height = 38,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.black : theme.textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
} 