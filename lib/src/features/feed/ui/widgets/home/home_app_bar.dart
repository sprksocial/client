import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/feed/feed_type_selector.dart';

class HomeAppBar extends ConsumerWidget {
  final VoidCallback onSettingsTap;

  const HomeAppBar({super.key, required this.onSettingsTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: topPadding + 10, left: 16.0, right: 16.0, bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 30),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20)),
                child: const FeedTypeSelector(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(FluentIcons.options_24_regular),
            color: AppColors.lightLavender,
            iconSize: 30,
            onPressed: onSettingsTap,
          ),
        ],
      ),
    );
  }
}
