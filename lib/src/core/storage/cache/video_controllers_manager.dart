import 'package:get_it/get_it.dart';
import 'package:pool/pool.dart';
import 'package:sparksocial/src/core/storage/cache/cache_manager_interface.dart';
import 'package:video_player/video_player.dart';

const int _maxVideoControllers = 3;

class ManagedVideoController {
  final String uri;
  VideoPlayerController? controller;
  late final VideoControllersManager _videoControllersManager;
  ManagedVideoController({required this.uri, this.controller});

  bool get isValid => controller != null;

  Future<void> dispose() async {
    _videoControllersManager = GetIt.instance<VideoControllersManager>();
    await _videoControllersManager.releaseVideoController(uri);
  }
}

class VideoControllersManager {
  final Pool _pool;
  late final CacheManagerInterface _cacheManager;
  final Map<String, ManagedVideoController> _controllers = {};
  final Map<String, PoolResource> _resources = {};

  VideoControllersManager() : _pool = Pool(_maxVideoControllers) {
    _cacheManager = GetIt.instance<CacheManagerInterface>();
  }

  /// Use parsed atUri to get cached videos, use direct url to get network videos.
  Future<ManagedVideoController> newController(String uri) async {
    if (_controllers.containsKey(uri)) {
      return _controllers[uri]!;
    }
    final VideoPlayerController controller;
    final resource = await _pool.request();
    final file = await _cacheManager.getCachedFile(uri);
    if (file == null) {
      controller = VideoPlayerController.networkUrl(Uri.parse(uri));
    } else {
      controller = VideoPlayerController.file(file);
    }
    _controllers[uri] = ManagedVideoController(uri: uri, controller: controller);
    _resources[uri] = resource;
    await controller.initialize();
    controller
      ..setLooping(true)
      ..pause();
    return ManagedVideoController(uri: uri, controller: controller);
  }

  Future<void> releaseVideoController(String uri) async {
    if (_controllers.containsKey(uri)) {
      final managedController = _controllers.remove(uri);
      final resource = _resources.remove(uri);
      if (managedController != null) {
        final controller = managedController.controller;
        if (controller != null) {
          await controller.pause();
          await controller.dispose();
          managedController.controller = null;
        }
      }
      resource?.release();
    }
  }
}
