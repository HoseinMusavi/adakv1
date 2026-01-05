import 'session.dart';
import '../value_objects/ids.dart';

class SessionModeSegment {
  const SessionModeSegment({
    required this.id,
    required this.sessionId,
    required this.mode,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
  });

  final SessionModeSegmentId id;
  final SessionId sessionId;
  final SessionMode mode;

  final DateTime startTime;
  final DateTime? endTime;

  /// Duration in minutes for this segment.
  ///
  /// Time tracking rule:
  /// - A segment is "open" while `endTime == null`.
  /// - When pausing, switching modes, or ending a session, the current open
  ///   segment is closed by setting `endTime` and calculating `durationMinutes`.
  /// - When resuming or switching modes, a NEW segment is created.
  final int durationMinutes;

  bool get isOpen => endTime == null;
}
