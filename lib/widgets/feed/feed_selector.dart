import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class FeedOption {
  final String label;
  final int value;

  const FeedOption({required this.label, required this.value});
}

class FeedSelector extends StatefulWidget {
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
  State<FeedSelector> createState() => _FeedSelectorState();
}

class _FeedSelectorState extends State<FeedSelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.options.length, (index) {
          final option = widget.options[index];
          final isSelected = option.value == widget.selectedValue;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                widget.onOptionSelected(option.value);
                setState(() {}); // Force a rebuild when tapped
              },
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.pink.withOpacity(0.2) : Colors.transparent,
                  border: isSelected ? Border.all(color: AppColors.pink, width: 1.5) : null,
                  borderRadius: BorderRadius.circular(50),
                ),
                alignment: Alignment.center,
                child: Text(
                  option.label,
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
