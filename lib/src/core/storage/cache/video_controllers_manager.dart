import 'package:get_it/get_it.dart';
import 'package:pool/pool.dart';
import 'package:sparksocial/src/core/storage/cache/cache_manager_interface.dart';
import 'package:video_player/video_player.dart';

const int _maxVideoControllers = 3;

class VideoControllersManager {
  final Pool _pool;
  late final CacheManagerInterface _cacheManager;
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, PoolResource> _resources = {};

  VideoControllersManager() : _pool = Pool(_maxVideoControllers) {
    _cacheManager = GetIt.instance<CacheManagerInterface>();
  }

  /// Use parsed atUri to get cached videos, use direct url to get network videos.
  Future<VideoPlayerController> newController(String uri) async {
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
    _controllers[uri] = controller;
    _resources[uri] = resource;
    await controller.initialize();
    controller
        ..setLooping(true)
      ..pause();
    return controller;
  }

  Future<void> releaseVideoController(String uri) async {
    if (_controllers.containsKey(uri)) {
      final controller = _controllers.remove(uri);
      final resource = _resources.remove(uri);
      await controller!.pause();
      await controller.dispose();
      resource?.release();
    }
  }
}
