import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/ui/foundation/colors.dart';

/// A customized text field widget for profile editing
class ProfileTextField extends StatefulWidget {
  /// Creates a profile text field
  const ProfileTextField({
    required this.initialValue,
    required this.hintText,
    required this.onChanged,
    required this.bgColor,
    super.key,
    this.maxLines = 1,
  });

  /// Initial value of the text field
  final String initialValue;

  /// Hint text to display when the field is empty
  final String hintText;

  /// Function to call when the text changes
  final Function(String) onChanged;

  /// Background color for the field
  final Color bgColor;

  /// Number of lines for the text field
  final int maxLines;

  @override
  State<ProfileTextField> createState() => _ProfileTextFieldState();
}

class _ProfileTextFieldState extends State<ProfileTextField> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProfileTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && widget.initialValue != _textController.text) {
      _textController.text = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _textController,
      onChanged: widget.onChanged,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: widget.bgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
