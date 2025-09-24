import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/toggles/follow_button.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/toggles/glass_follow_button.dart';
import 'package:sparksocial/src/core/design_system/components/atoms/toggles/toggle.dart';

@UseCase(name: 'follow_states', type: FollowButton)
Widget buildFollowButtonFollowStatesUseCase(BuildContext context) {
  final isFollowing = context.knobs.boolean(
    label: 'is_following',
    initialValue: false,
  );
  return Center(
    child: FollowButton(
      isFollowing: isFollowing,
      onFollow: () => print('Follow pressed'),
      onUnfollow: () => print('Unfollow pressed'),
      followText: context.knobs.string(
        label: 'follow_text',
        initialValue: 'Follow',
      ),
      unfollowText: context.knobs.string(
        label: 'unfollow_text',
        initialValue: 'Unfollow',
      ),
    ),
  );
}

@UseCase(name: 'glass_follow_states', type: GlassFollowButton)
Widget buildGlassFollowButtonGlassFollowStatesUseCase(BuildContext context) {
  final isFollowing = context.knobs.boolean(
    label: 'is_following',
    initialValue: false,
  );
  return Center(
    child: GlassFollowButton(
      isFollowing: isFollowing,
      onFollow: () => print('Follow pressed'),
      onUnfollow: () => print('Unfollow pressed'),
      followText: context.knobs.string(
        label: 'follow_text',
        initialValue: 'Follow',
      ),
      unfollowText: context.knobs.string(
        label: 'unfollow_text',
        initialValue: 'Unfollow',
      ),
    ),
  );
}

@UseCase(name: 'interactive', type: Toggle)
Widget buildToggleInteractiveUseCase(BuildContext context) {
  final initialValue = context.knobs.boolean(
    label: 'initial_value',
    initialValue: true,
  );
  return _ToggleDemo(initialValue: initialValue);
}

class _ToggleDemo extends StatefulWidget {
  const _ToggleDemo({required this.initialValue});
  final bool initialValue;
  @override
  State<_ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<_ToggleDemo> {
  late bool value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Toggle(
          value: value,
          onChanged: (v) {
            setState(() => value = v);
            print('Toggle changed: $v');
          },
        ),
        const SizedBox(height: 12),
        Text('Value: $value'),
      ],
    );
  }
}
