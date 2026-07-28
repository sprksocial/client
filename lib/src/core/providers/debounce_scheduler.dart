import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef DebounceScheduler =
    void Function() Function(Duration delay, Future<void> Function() action);

final debounceSchedulerProvider = Provider<DebounceScheduler>((ref) {
  return (delay, action) {
    final timer = Timer(delay, () => unawaited(action()));
    return timer.cancel;
  };
});
