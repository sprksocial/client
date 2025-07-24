import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

class CustomControlsWidget extends StatefulWidget {
  final BetterPlayerController? controller;
  final Function(bool visbility)? onControlsVisibilityChanged;

  const CustomControlsWidget({
    super.key,
    this.controller,
    this.onControlsVisibilityChanged,
  });

  @override
  State<CustomControlsWidget> createState() => _CustomControlsWidgetState();
}

class _CustomControlsWidgetState extends State<CustomControlsWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(204),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
