import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/ui/widgets/action_button.dart';

class ShareActionButton extends StatelessWidget {
  const ShareActionButton({required this.count, super.key, this.onPressed});
  final String count;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionButton(icon: FluentIcons.share_24_regular, label: count, onPressed: onPressed, showLabel: false);
  }
}
