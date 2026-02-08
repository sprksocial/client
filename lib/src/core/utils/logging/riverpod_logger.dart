import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A ProviderObserver that logs provider changes
///
/// Logging is currently disabled to reduce console noise.
/// Re-enable by uncommenting the logging logic in didUpdateProvider.
final class SparkRiverpodLogger extends ProviderObserver {
  /// Constructor
  SparkRiverpodLogger();

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    // Provider lifecycle logging disabled to reduce noise
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    // Provider lifecycle logging disabled to reduce noise
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    // Provider update logging disabled to reduce noise
  }
}
