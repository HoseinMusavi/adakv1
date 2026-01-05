import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionTickerIntervalProvider = Provider<Duration>((ref) {
  return const Duration(seconds: 1);
});

final sessionTickerProvider =
    NotifierProvider.autoDispose<SessionTicker, DateTime>(SessionTicker.new);

class SessionTicker extends AutoDisposeNotifier<DateTime> {
  Timer? _timer;

  @override
  DateTime build() {
    final interval = ref.watch(sessionTickerIntervalProvider);

    _timer?.cancel();

    _timer = Timer.periodic(interval, (_) {
      state = DateTime.now();
    });

    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });

    return DateTime.now();
  }
}
