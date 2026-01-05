import 'package:adak/features/sessions/domain/entities/session.dart';

class ActiveSessionState {
  const ActiveSessionState({
    required this.activeSession,
    required this.now,
  });

  final Session? activeSession;

  /// Current wall clock time.
  ///
  /// Architecture rule:
  /// - `DateTime.now()` must not be used outside the ticker.
  /// - UI reads this value to render timers/cost, without calculating time.
  final DateTime now;

  ActiveSessionState copyWith({
    Session? activeSession,
    DateTime? now,
  }) {
    return ActiveSessionState(
      activeSession: activeSession ?? this.activeSession,
      now: now ?? this.now,
    );
  }
}
