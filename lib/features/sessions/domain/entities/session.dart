import '../value_objects/ids.dart';

enum SessionMode {
  online,
  offline,
}

enum SessionStatus {
  active,
  paused,
  ended,
}

class Session {
  const Session({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.mode,
    required this.startTime,
    required this.endTime,
    required this.totalDurationMinutes,
    required this.onlineMinutes,
    required this.offlineMinutes,
    required this.calculatedCost,
    required this.freeTimeUsedMinutes,
    required this.status,
  });

  final SessionId id;
  final UserId userId;
  final DeviceId deviceId;

  /// Current mode for the session.
  ///
  /// Important:
  /// - Switching Online/Offline does NOT overwrite history.
  /// - History is tracked by `SessionModeSegments` in the data layer.
  final SessionMode mode;

  final DateTime startTime;
  final DateTime? endTime;

  /// Total billed/aggregated duration in minutes across all segments.
  final int totalDurationMinutes;

  /// Aggregated minutes spent while `mode == online`.
  final int onlineMinutes;

  /// Aggregated minutes spent while `mode == offline`.
  final int offlineMinutes;

  /// Cached total cost for session time.
  ///
  /// Note: This is a stored value for fast UI updates and reporting.
  /// The source of truth is the segment list + applicable rates.
  final double calculatedCost;

  /// How many minutes of user free time were consumed in this session.
  final int freeTimeUsedMinutes;

  final SessionStatus status;

  bool get isActive => status == SessionStatus.active;
  bool get isPaused => status == SessionStatus.paused;
  bool get isEnded => status == SessionStatus.ended;
}
