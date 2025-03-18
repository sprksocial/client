import 'package:flutter/material.dart';

class UsernameLabel extends StatelessWidget {
  final String username;
  final TextStyle? style;

  const UsernameLabel({super.key, required this.username, this.style});

  @override
  Widget build(BuildContext context) {
    return Text('@$username', style: style ?? const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14));
  }
}
