import 'package:flutter/material.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';

class NoMorePosts extends StatelessWidget {
  const NoMorePosts({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.black),
      child: const Center(child: Text('No more posts in this feed.', style: TextStyle(color: AppColors.white))),
    );
  }
}
