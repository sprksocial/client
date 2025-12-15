import 'package:flutter/material.dart';

class _BackgroundWrapper extends StatelessWidget {
  final Widget? child;
  final Widget background;

  const _BackgroundWrapper({this.child, required this.background});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: background),
          Align(alignment: Alignment.center, child: child),
        ],
      ),
    );
  }
}

Widget imageBackground({required BuildContext context, required Widget child}) {
  return _BackgroundWrapper(
    background: Image.network(
      'https://picsum.photos/800/600?random=${DateTime.now().second % 10}',
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.red.shade100,
          alignment: Alignment.center,
          child: const Text('Failed to load image'),
        );
      },
    ),
    child: Center(child: child),
  );
}

Widget gradientBackground({
  required BuildContext context,
  required Widget child,
  required Color startColor,
  required Color endColor,
}) {
  return _BackgroundWrapper(
    background: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
    child: Center(child: child),
  );
}

Widget solidColorBackground({
  required BuildContext context,
  required Widget child,
  required Color color,
}) {
  return _BackgroundWrapper(
    background: Container(color: color),
    child: Center(child: child),
  );
}
