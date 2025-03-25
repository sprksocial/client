import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';

class FeedOption {
  final String label;
  final int value;

  const FeedOption({required this.label, required this.value});
}

class FeedSelector extends StatelessWidget {
  final List<FeedOption> options;
  final int selectedValue;
  final ValueChanged<int> onOptionSelected;
  final double height;
  final EdgeInsets? padding;
  
  const FeedSelector({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onOptionSelected,
    this.height = 38,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          options.length,
          (index) {
            final option = options[index];
            final isSelected = option.value == selectedValue;
            
            return Expanded(
              child: GestureDetector(
                onTap: () => onOptionSelected(option.value),
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.white.withAlpha(100)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    option.label,
                    style: TextStyle(
                      color: isSelected 
                          ? AppColors.white 
                          : AppColors.lightLavender,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 