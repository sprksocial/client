import 'package:flutter/services.dart';

/// Text formatter that converts input text to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  /// Creates an UpperCaseTextFormatter.
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
