import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/app_colors.dart';

class ProfileActionButton extends StatelessWidget {
  final String? profileImageUrl;
  final VoidCallback? onPressed;
  final double size;
  final BoxBorder? border;

  const ProfileActionButton({
    super.key,
    this.profileImageUrl,
    this.onPressed,
    this.size = 50.0,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: border ?? Border.all(color: AppColors.white, width: 2),
        ),
        child: ClipOval(
          child: profileImageUrl != null && profileImageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: profileImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.deepPurple,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.deepPurple,
                    child: Center(
                      child: Icon(
                        Icons.person,
                        color: AppColors.white,
                        size: size * 0.5,
                      ),
                    ),
                  ),
                )
              : Container(
                  color: AppColors.deepPurple,
                  child: Center(
                    child: Icon(
                      Icons.person,
                      color: AppColors.white,
                      size: size * 0.5,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
