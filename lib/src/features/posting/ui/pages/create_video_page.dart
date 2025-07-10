import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sparksocial/src/core/routing/app_router.dart';
import 'package:sparksocial/src/features/posting/providers/camera_provider.dart';
import 'package:sparksocial/src/features/posting/ui/widgets/camera_controls.dart';
import 'package:sparksocial/src/features/posting/ui/widgets/camera_view.dart';
import 'package:sparksocial/src/features/posting/ui/widgets/mode_selector.dart';
import 'package:sparksocial/src/features/posting/ui/widgets/permission_requrest.dart';
import 'package:sparksocial/src/features/posting/ui/widgets/recording_bar.dart';

@RoutePage()
class CreateVideoPage extends ConsumerStatefulWidget {
  const CreateVideoPage({super.key, this.isStoryMode = false});
  final bool isStoryMode; // TODO: remove this and use imgly for stories

  @override
  ConsumerState<CreateVideoPage> createState() => _CreateVideoPageState();
}

class _CreateVideoPageState extends ConsumerState<CreateVideoPage> with WidgetsBindingObserver {
  bool _isVideoMode = true;
  final ImagePicker _picker = ImagePicker();
  final bool _cameraPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        ref.read(cameraProvider.notifier);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    var cameraState = ref.watch(cameraProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      body: Stack(
        children: [
          if (_cameraPermissionDenied)
            Positioned.fill(child: CameraPermissionRequest(onRequestPermission: () => cameraState = ref.watch(cameraProvider)))
          else
            CameraView(cameraController: cameraState.value?.controller, isInitialized: cameraState.value?.isInitialized ?? false),

          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => context.router.maybePop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black.withAlpha(100), shape: BoxShape.circle),
                      child: const Icon(FluentIcons.dismiss_24_regular, color: Colors.white, size: 24),
                    ),
                  ),
                ),

                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ModeSelector(
                      isVideoMode: _isVideoMode,
                      onModeSelected: (isVideoMode) => setState(() => _isVideoMode = isVideoMode),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
