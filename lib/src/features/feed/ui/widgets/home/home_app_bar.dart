import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';
import 'package:sparksocial/src/core/theme/data/models/colors.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/feed/feed_type_selector.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback onSettingsTap;
  final Function(FeedType) onFeedTypeSelectorTap;

  const HomeAppBar({super.key, required this.onSettingsTap, required this.onFeedTypeSelectorTap});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);


  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 30),
        Expanded(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20)),
              child: FeedTypeSelector(onFeedTypeChanged: onFeedTypeSelectorTap),
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
    );
  }
}
