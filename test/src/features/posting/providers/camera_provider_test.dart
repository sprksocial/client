import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/utils/logging/logging.dart';
import 'package:spark/src/features/posting/providers/camera_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CameraPlatform originalCameraPlatform;
  late _FakeCameraPlatform cameraPlatform;

  setUpAll(() {
    originalCameraPlatform = CameraPlatform.instance;
  });

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<LogService>(LogService());
    cameraPlatform = _FakeCameraPlatform();
    CameraPlatform.instance = cameraPlatform;
  });

  tearDown(() async {
    CameraPlatform.instance = originalCameraPlatform;
    await GetIt.I.reset();
  });

  test('auto-dispose releases the initialized camera', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final provider = cameraProvider(ResolutionPreset.low);
    final subscription = container.listen(provider, (previous, next) {});

    await container.read(provider.future);
    expect(container.read(provider.notifier).controller, isNotNull);

    subscription.close();
    await container.pump();
    await cameraPlatform.disposed;

    expect(cameraPlatform.disposedCameraIds, [_FakeCameraPlatform.cameraId]);
  });
}

class _FakeCameraPlatform extends CameraPlatform {
  static const cameraId = 13;
  static const camera = CameraDescription(
    name: 'back',
    lensDirection: CameraLensDirection.back,
    sensorOrientation: 90,
  );

  final Completer<void> _disposed = Completer<void>();
  final List<int> disposedCameraIds = [];

  Future<void> get disposed => _disposed.future;

  @override
  Future<List<CameraDescription>> availableCameras() async => [camera];

  @override
  Future<int> createCameraWithSettings(
    CameraDescription cameraDescription,
    MediaSettings mediaSettings,
  ) async => cameraId;

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {}

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return Stream.value(
      CameraInitializedEvent(
        cameraId,
        1080,
        1920,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      ),
    );
  }

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) {
    return Stream.value(CameraErrorEvent(cameraId, 'test error'));
  }

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    return Stream.value(
      const DeviceOrientationChangedEvent(DeviceOrientation.portraitUp),
    );
  }

  @override
  Future<void> dispose(int cameraId) async {
    disposedCameraIds.add(cameraId);
    if (!_disposed.isCompleted) {
      _disposed.complete();
    }
  }
}
