import 'package:atproto_core/atproto_core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/features/profile/ui/widgets/profile_grid_widget.dart';

@RoutePage()
class ProfileVideosPage extends ConsumerWidget {
  final String did;

  const ProfileVideosPage({@PathParam('did') required this.did, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileGridWidget(
      profileUri: AtUri.parse('at://$did'),
      videosOnly: true,
    );
  }
} 