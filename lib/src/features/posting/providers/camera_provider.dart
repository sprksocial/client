import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spark/src/core/utils/logging/logging.dart';
import 'package:spark/src/features/posting/providers/camera_state.dart';

part 'camera_provider.g.dart';

@riverpod
class Camera extends _$Camera {
  late final SparkLogger _logger;

  @override
  FutureOr<CameraState> build() async {
    _logger = GetIt.instance<LogService>().getLogger('Camera');

    ref.onDispose(_disposeCamera);

    _logger.i('Initializing camera provider');

    // Yield so the loading UI can paint before blocking on camera init
    await Future<void>.delayed(Duration.zero);
    if (!ref.mounted) return const CameraState(error: 'Disposed during init');

    try {
      return await _initializeCamera();
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize camera on build',
        error: e,
        stackTrace: stackTrace,
      );
      return CameraState(error: e.toString());
    }
  }

  Future<CameraState> _initializeCamera() async {
    _logger.d('Starting camera initialization');

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _logger.w('No cameras found on device');
        throw Exception('No cameras found');
      }

      _logger.i('Found ${cameras.length} cameras');

      final controller = await _createCameraController(cameras.first);

      return CameraState(
        controller: controller,
        cameras: cameras,
        isInitialized: true,
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Camera initialization failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<CameraController> _createCameraController(
    CameraDescription camera,
  ) async {
    _logger.d('Creating camera controller for: ${camera.name}');

    final controller = CameraController(
      camera,
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller.initialize();

    if (controller.value.isInitialized) {
      // Pre-initialize audio session on iOS to eliminate recording start lag
      await controller.prepareForVideoRecording();
      _logger.i('Camera controller successfully initialized');
      return controller;
    } else {
      _logger.e('Camera controller initialization incomplete');
      throw Exception('Camera controller initialized but camera not ready');
    }
  }

  Future<void> reinitializeCamera() async {
    _logger.i('Reinitializing camera');

    await _disposeCamera();
    if (!ref.mounted) return;

    state = const AsyncValue.loading();

    try {
      final newState = await _initializeCamera();
      state = AsyncValue.data(newState);
      _logger.i('Camera reinitialized successfully');
    } catch (e, stackTrace) {
      _logger.e(
        'Camera reinitialization failed',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> flipCamera() async {
    final currentState = state.value;
    if (currentState == null) {
      _logger.w('Cannot flip camera - no current state');
      return;
    }

    if (currentState.cameras.length <= 1) {
      _logger.w('Cannot flip camera - only one camera available');
      return;
    }

    _logger.d('Flipping camera');

    final newIndex =
        (currentState.selectedCameraIndex + 1) % currentState.cameras.length;
    final newCamera = currentState.cameras[newIndex];
    final oldController = currentState.controller;

    // Detach preview first, then dispose old controller.
    state = AsyncValue.data(
      currentState.copyWith(
        controller: null,
        isInitialized: false,
        isFlipping: true,
        error: null,
      ),
    );

    await _waitForPreviewDetach();
    if (!ref.mounted) return;

    try {
      _logger.d('Switching to camera: ${newCamera.name}');

      await oldController?.dispose();
      if (!ref.mounted) return;

      final newController = await _createCameraController(newCamera);
      if (!ref.mounted) {
        await newController.dispose();
        return;
      }

      state = AsyncValue.data(
        currentState.copyWith(
          controller: newController,
          selectedCameraIndex: newIndex,
          isInitialized: true,
          isFlipping: false,
          error: null,
        ),
      );

      _logger.i('Camera flipped successfully to ${newCamera.name}');
    } catch (e, stackTrace) {
      _logger.e('Error flipping camera', error: e, stackTrace: stackTrace);
      if (ref.mounted) {
        state = AsyncValue.data(
          currentState.copyWith(
            controller: null,
            isInitialized: false,
            isFlipping: false,
            error: e.toString(),
          ),
        );
      }
    }
  }

  Future<XFile?> takePhoto() async {
    final currentState = state.value;
    if (currentState == null) {
      _logger.w('Cannot take photo - no current state');
      return null;
    }

    if (currentState.controller == null || !currentState.isInitialized) {
      _logger.w('Cannot take photo - camera not initialized');
      return null;
    }

    _logger.d('Taking photo');

    try {
      final file = await currentState.controller!.takePicture();
      _logger.i('Photo taken successfully: ${file.path}');
      return file;
    } catch (e, stackTrace) {
      _logger.e('Error taking photo', error: e, stackTrace: stackTrace);
      state = AsyncValue.data(currentState.copyWith(error: e.toString()));
      return null;
    }
  }

  Future<bool> startVideoRecording() async {
    final currentState = state.value;
    if (currentState == null) {
      _logger.w('Cannot start recording - no current state');
      return false;
    }

    if (currentState.controller == null ||
        !currentState.isInitialized ||
        currentState.isRecording) {
      _logger.w(
        'Cannot start recording - camera not ready or already recording',
      );
      return false;
    }

    _logger.d('Starting video recording');

    // Update state optimistically BEFORE native call so UI responds immediately
    state = AsyncValue.data(currentState.copyWith(isRecording: true));

    try {
      await currentState.controller!.startVideoRecording();
      _logger.i('Video recording started successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'Error starting video recording',
        error: e,
        stackTrace: stackTrace,
      );
      // Revert optimistic update on failure
      state = AsyncValue.data(
        currentState.copyWith(isRecording: false, error: e.toString()),
      );
      return false;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final currentState = state.value;
    if (currentState == null) {
      _logger.w('Cannot stop recording - no current state');
      return null;
    }

    if (currentState.controller == null ||
        !currentState.isInitialized ||
        !currentState.isRecording) {
      _logger.w('Cannot stop recording - not currently recording');
      return null;
    }

    _logger.d('Stopping video recording');

    // Update state optimistically BEFORE native call so UI responds immediately
    state = AsyncValue.data(currentState.copyWith(isRecording: false));

    try {
      final file = await currentState.controller!.stopVideoRecording();
      _logger.i('Video recording stopped successfully: ${file.path}');
      return file;
    } catch (e, stackTrace) {
      _logger.e(
        'Error stopping video recording',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.data(currentState.copyWith(error: e.toString()));
      return null;
    }
  }

  Future<void> _disposeCamera() async {
    _logger.d('Disposing camera');

    try {
      final currentState = state.value;
      final controller = currentState?.controller;
      final wasRecording = currentState?.isRecording ?? false;

      state = AsyncValue.data(
        currentState?.copyWith(
              controller: null,
              isInitialized: false,
              isRecording: false,
              isFlipping: false,
            ) ??
            const CameraState(),
      );

      if (controller != null) {
        await _waitForPreviewDetach();

        if (wasRecording) {
          _logger.d('Stopping recording before disposal');
          try {
            if (controller.value.isRecordingVideo) {
              await controller.stopVideoRecording();
            }
          } catch (e, stackTrace) {
            _logger.e(
              'Error stopping recording during disposal',
              error: e,
              stackTrace: stackTrace,
            );
          }
        }

        await controller.dispose();
        _logger.i('Camera controller disposed successfully');
      }
    } catch (e, stackTrace) {
      _logger.e('Error disposing camera', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _waitForPreviewDetach() async {
    if (!ref.mounted) return;

    final completer = Completer<void>();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    SchedulerBinding.instance.scheduleFrame();
    await completer.future;
  }

  void clearError() {
    final currentState = state.value;
    if (currentState != null && currentState.error != null) {
      _logger.d('Clearing camera error');
      state = AsyncValue.data(currentState.copyWith(error: null));
    }
  }

  Future<void> disposeCamera() async {
    await _disposeCamera();
  }
}
