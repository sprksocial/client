import 'dart:ui';

import 'package:flutter/material.dart';

class DevelopmentOverlay extends StatelessWidget {
  const DevelopmentOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withAlpha(100),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(color: Colors.black.withAlpha(100), borderRadius: BorderRadius.circular(12)),
              child: const Text(
                'coming soon :)',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
