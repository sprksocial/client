import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/interactive_pressable.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';

class TappableText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const TappableText({
    required this.text,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InteractivePressable(
      onTap: onTap,
      child: SizedBox(
        width: 41,
        height: 14,
        child: Center(
          child: Text(text, style: AppTypography.textExtraSmallThin),
        ),
      ),
    );
  }
}
