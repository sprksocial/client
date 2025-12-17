import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base interface for profile tab widgets that build slivers
abstract class ProfileTabBase extends ConsumerWidget {
  const ProfileTabBase({super.key});

  /// Builds the slivers for this tab
  List<Widget> buildSlivers(BuildContext context, WidgetRef ref);
}
