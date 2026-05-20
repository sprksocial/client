import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DefaultProfileAvatar extends StatelessWidget {
  const DefaultProfileAvatar({required this.size, super.key});

  static const assetName = 'images/profile.svg';
  static const assetPackage = 'assets';

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SvgPicture.asset(
        assetName,
        package: assetPackage,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
