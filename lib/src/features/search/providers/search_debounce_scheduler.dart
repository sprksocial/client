import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef SearchDebounceScheduler =
    void Function() Function(Duration delay, Future<void> Function() action);

final searchDebounceSchedulerProvider = Provider<SearchDebounceScheduler>((
  ref,
) {
  return (delay, action) {
    final timer = Timer(delay, () => unawaited(action()));
    return timer.cancel;
  };
});
