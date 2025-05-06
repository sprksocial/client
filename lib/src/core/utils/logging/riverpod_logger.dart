import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'logging.dart';

/// A ProviderObserver that logs provider changes
class SparkRiverpodLogger extends ProviderObserver {
  final LogService _logService;
  late final SparkLogger _logger;
  
  /// Constructor
  SparkRiverpodLogger({
    LogService? logService,
  }) : _logService = logService ?? GetIt.instance<LogService>() {
    _logger = _logService.getLogger('Riverpod');
  }
  
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    _logger.d('Provider ${provider.name ?? provider.runtimeType} was added with value: ${_truncateIfNeeded(value.toString())}');
  }
  
  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    _logger.d('Provider ${provider.name ?? provider.runtimeType} was disposed');
  }
  
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Skip logging if previous and new values are identical
    if (previousValue == newValue) return;
    
    // Also skip if they have the same string representation
    if (previousValue.toString() == newValue.toString()) return;
    
    _logger.d(
      'Provider ${provider.name ?? provider.runtimeType} was updated\n'
      'Previous: ${_truncateIfNeeded(previousValue.toString())}\n'
      'New: ${_truncateIfNeeded(newValue.toString())}',
    );
  }
  
  /// Truncates long strings to avoid excessive logging
  String _truncateIfNeeded(String text, {int maxLength = 300}) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}... (${text.length - maxLength} more characters)';
  }
} 