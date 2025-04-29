import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'action_button.dart';

class ShareActionButton extends StatelessWidget {
  final String count;
  final VoidCallback? onPressed;

  const ShareActionButton({
    super.key, 
    required this.count, 
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return ActionButton(icon: FluentIcons.share_24_regular, label: count, onPressed: onPressed, showLabel: false);
  }
}
