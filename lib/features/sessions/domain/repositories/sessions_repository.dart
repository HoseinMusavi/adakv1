import '../entities/session.dart';
import '../entities/session_mode_segment.dart';
import '../value_objects/ids.dart';

class StartSessionCommand {
  const StartSessionCommand({
    required this.sessionId,
    required this.userId,
    required this.deviceId,
    required this.initialMode,
    required this.startedAt,
  });

  final SessionId sessionId;
  final UserId userId;
  final DeviceId deviceId;
  final SessionMode initialMode;
  final DateTime startedAt;
}

class EndSessionSettlementCommand {
  const EndSessionSettlementCommand({
    required this.sessionId,
    required this.endedAt,
    required this.paidAmount,
  });

  final SessionId sessionId;
  final DateTime endedAt;

  /// Paid amount for the session's time component (orders may be handled
  /// separately).
  final double paidAmount;
}

abstract class SessionsRepository {
  /// Starts a new session AND creates the initial mode segment.
  Future<Session> startSession(StartSessionCommand command);

  /// Returns the active session for a device, if any.
  Future<Session?> getActiveSessionForDevice(DeviceId deviceId);

  Stream<Session?> watchActiveSessionForDevice(DeviceId deviceId);

  Future<Session> getById(SessionId sessionId);

  Future<List<SessionModeSegment>> getSegments(SessionId sessionId);

  /// Closes the currently open segment (if present) and marks the session paused.
  Future<Session> pauseSession(SessionId sessionId, {required DateTime pausedAt});

  /// Creates a new open segment (using the session's current mode) and marks the
  /// session active.
  Future<Session> resumeSession(SessionId sessionId, {required DateTime resumedAt});

  /// Closes the currently open segment and creates a new segment for [newMode].
  ///
  /// This is the key operation that allows accurate tracking of Online/Offline
  /// time within a single session.
  Future<Session> switchMode(
    SessionId sessionId, {
    required SessionMode newMode,
    required DateTime switchedAt,
  });

  /// Recalculates cached totals (minutes by mode + cost) from segments.
  ///
  /// This should be done in a transaction in the data layer to keep session and
  /// segment aggregates consistent.
  Future<Session> recalculateAggregates(
    SessionId sessionId, {
    required double onlineRatePerMinute,
    required double offlineRatePerMinute,
    required int freeTimeRemainingMinutes,
    required DateTime now,
  });

  /// Ends the session in a transaction.
  ///
  /// Business rule: a session cannot be ended without settlement.
  Future<Session> endSessionWithSettlement(EndSessionSettlementCommand command);
}
