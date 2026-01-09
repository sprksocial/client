import 'package:flutter/material.dart';

/// A custom styled text field with optional undo functionality.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.controller,
    required this.hintText,
    super.key,
    this.fillColor,
    this.maxLines = 1,
    this.onUndo,
    this.validator,
  });
  final TextEditingController controller;
  final String hintText;
  final Color? fillColor;
  final int maxLines;
  final VoidCallback? onUndo;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: fillColor ?? colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        suffixIcon: onUndo != null
            ? IconButton(
                icon: const Icon(Icons.undo, size: 20),
                onPressed: onUndo,
                tooltip: 'Revert',
              )
            : null,
      ),
    );
  }
}
