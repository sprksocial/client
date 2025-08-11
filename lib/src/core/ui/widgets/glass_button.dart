import 'package:flutter/material.dart';

class GlassButton extends StatelessWidget {
  const GlassButton({super.key, this.onPressed, this.text});

  final VoidCallback? onPressed;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text ?? 'Glass Button'),
    );
  }
}
