import 'dart:math' as math;

import 'package:adak/core/database/app_database.dart';
import 'package:adak/core/database/enums.dart' as db;
import 'package:adak/features/sessions/domain/entities/session.dart' as domain;
import 'package:adak/features/sessions/domain/entities/session_mode_segment.dart'
    as domain;
import 'package:adak/features/sessions/domain/exceptions/session_exceptions.dart';
import 'package:adak/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:adak/features/sessions/domain/value_objects/ids.dart';
import 'package:drift/drift.dart';

class DriftSessionsRepository implements SessionsRepository {
  DriftSessionsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<domain.Session> startSession(StartSessionCommand command) async {
    return _db.transaction(() async {
      final existing = await _getOngoingSessionRowForDevice(command.deviceId);
      if (existing != null) {
        throw ActiveSessionExistsException(command.deviceId);
      }

      await _db.into(_db.sessions).insert(
            SessionsCompanion.insert(
              id: command.sessionId.value,
              userId: command.userId.value,
              deviceId: command.deviceId.value,
              mode: Value(_toDbMode(command.initialMode)),
              startTime: command.startedAt,
              endTime: const Value.absent(),
              totalDuration: const Value(0),
              onlineMinutes: const Value(0),
              offlineMinutes: const Value(0),
              calculatedCost: const Value(0.0),
              freeTimeUsed: const Value(0),
              status: const Value(db.SessionStatus.active),
            ),
          );

      await _db.into(_db.sessionModeSegments).insert(
            SessionModeSegmentsCompanion.insert(
              id: _newId(),
              sessionId: command.sessionId.value,
              mode: _toDbMode(command.initialMode),
              startTime: command.startedAt,
              endTime: const Value.absent(),
              durationMinutes: const Value(0),
            ),
          );

      await (_db.update(_db.devices)
            ..where((t) => t.id.equals(command.deviceId.value)))
          .write(const DevicesCompanion(status: Value(db.DeviceStatus.active)));

      final row = await _getSessionRowOrThrow(command.sessionId);
      return _mapSession(row);
    });
  }

  @override
  Future<domain.Session?> getActiveSessionForDevice(DeviceId deviceId) async {
    final row = await _getOngoingSessionRowForDevice(deviceId);
    if (row == null) {
      return null;
    }
    return _mapSession(row);
  }

  @override
  Stream<domain.Session?> watchActiveSessionForDevice(DeviceId deviceId) {
    final query = _db.select(_db.sessions)
      ..where(
        (t) =>
            t.deviceId.equals(deviceId.value) &
            (t.status.equals(db.SessionStatus.active.name) |
                t.status.equals(db.SessionStatus.paused.name)),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
      ..limit(1);

    return query.watchSingleOrNull().map((row) {
      if (row == null) {
        return null;
      }
      return _mapSession(row);
    });
  }

  @override
  Future<domain.Session> getById(SessionId sessionId) async {
    final row = await _getSessionRowOrThrow(sessionId);
    return _mapSession(row);
  }

  @override
  Future<List<domain.SessionModeSegment>> getSegments(SessionId sessionId) async {
    final rows = await (_db.select(_db.sessionModeSegments)
          ..where((t) => t.sessionId.equals(sessionId.value))
          ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .get();

    return rows.map(_mapSegment).toList(growable: false);
  }

  @override
  Future<domain.Session> pauseSession(
    SessionId sessionId, {
    required DateTime pausedAt,
  }) async {
    return _db.transaction(() async {
      final session = await _getSessionRowOrThrow(sessionId);
      if (session.status == db.SessionStatus.ended) {
        throw InvalidSessionStateException('Cannot pause an ended session.');
      }
      if (session.status == db.SessionStatus.paused) {
        throw InvalidSessionStateException('Session is already paused.');
      }

      final open = await _getOpenSegmentRowOrThrow(sessionId);
      await _closeSegment(open, endTime: pausedAt);

      await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId.value)))
          .write(
        const SessionsCompanion(status: Value(db.SessionStatus.paused)),
      );

      await (_db.update(_db.devices)
            ..where((t) => t.id.equals(session.deviceId)))
          .write(const DevicesCompanion(status: Value(db.DeviceStatus.paused)));

      await _recalculateUsingStoredRates(sessionId, now: pausedAt);

      final updated = await _getSessionRowOrThrow(sessionId);
      return _mapSession(updated);
    });
  }

  @override
  Future<domain.Session> resumeSession(
    SessionId sessionId, {
    required DateTime resumedAt,
  }) async {
    return _db.transaction(() async {
      final session = await _getSessionRowOrThrow(sessionId);
      if (session.status == db.SessionStatus.ended) {
        throw InvalidSessionStateException('Cannot resume an ended session.');
      }
      if (session.status == db.SessionStatus.active) {
        throw InvalidSessionStateException('Session is already active.');
      }

      final open = await _getOpenSegmentRow(sessionId);
      if (open != null) {
        throw InvalidSessionStateException('Cannot resume: found open segment.');
      }

      await _db.into(_db.sessionModeSegments).insert(
            SessionModeSegmentsCompanion.insert(
              id: _newId(),
              sessionId: sessionId.value,
              mode: session.mode,
              startTime: resumedAt,
              endTime: const Value.absent(),
              durationMinutes: const Value(0),
            ),
          );

      await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId.value)))
          .write(const SessionsCompanion(status: Value(db.SessionStatus.active)));

      await (_db.update(_db.devices)
            ..where((t) => t.id.equals(session.deviceId)))
          .write(const DevicesCompanion(status: Value(db.DeviceStatus.active)));

      final updated = await _getSessionRowOrThrow(sessionId);
      return _mapSession(updated);
    });
  }

  @override
  Future<domain.Session> switchMode(
    SessionId sessionId, {
    required domain.SessionMode newMode,
    required DateTime switchedAt,
  }) async {
    return _db.transaction(() async {
      final session = await _getSessionRowOrThrow(sessionId);

      if (session.status == db.SessionStatus.ended) {
        throw InvalidSessionStateException('Cannot switch mode on ended session.');
      }
      if (session.status == db.SessionStatus.paused) {
        throw InvalidSessionStateException('Cannot switch mode while paused.');
      }

      final open = await _getOpenSegmentRowOrThrow(sessionId);
      await _closeSegment(open, endTime: switchedAt);

      final dbNewMode = _toDbMode(newMode);
      await _db.into(_db.sessionModeSegments).insert(
            SessionModeSegmentsCompanion.insert(
              id: _newId(),
              sessionId: sessionId.value,
              mode: dbNewMode,
              startTime: switchedAt,
              endTime: const Value.absent(),
              durationMinutes: const Value(0),
            ),
          );

      await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId.value)))
          .write(SessionsCompanion(mode: Value(dbNewMode)));

      await _recalculateUsingStoredRates(sessionId, now: switchedAt);

      final updated = await _getSessionRowOrThrow(sessionId);
      return _mapSession(updated);
    });
  }

  @override
  Future<domain.Session> recalculateAggregates(
    SessionId sessionId, {
    required double onlineRatePerMinute,
    required double offlineRatePerMinute,
    required int freeTimeRemainingMinutes,
    required DateTime now,
  }) async {
    return _db.transaction(() async {
      final sessionRow = await _getSessionRowOrThrow(sessionId);
      final segments = await (_db.select(_db.sessionModeSegments)
            ..where((t) => t.sessionId.equals(sessionId.value))
            ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
          .get();

      final aggregates = _computeAggregates(
        segments,
        now: now,
        onlineRatePerMinute: onlineRatePerMinute,
        offlineRatePerMinute: offlineRatePerMinute,
        freeTimeRemainingMinutes: freeTimeRemainingMinutes,
      );

      await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId.value)))
          .write(
        SessionsCompanion(
          totalDuration: Value(aggregates.totalMinutes),
          onlineMinutes: Value(aggregates.totalOnlineMinutes),
          offlineMinutes: Value(aggregates.totalOfflineMinutes),
          calculatedCost: Value(aggregates.cost),
          freeTimeUsed: Value(aggregates.freeTimeUsedMinutes),
        ),
      );

      return _mapSession(sessionRow.copyWith(
        totalDuration: aggregates.totalMinutes,
        onlineMinutes: aggregates.totalOnlineMinutes,
        offlineMinutes: aggregates.totalOfflineMinutes,
        calculatedCost: aggregates.cost,
        freeTimeUsed: aggregates.freeTimeUsedMinutes,
      ));
    });
  }

  @override
  Future<domain.Session> endSessionWithSettlement(
    EndSessionSettlementCommand command,
  ) async {
    return _db.transaction(() async {
      final session = await _getSessionRowOrThrow(command.sessionId);

      if (session.status == db.SessionStatus.ended) {
        throw InvalidSessionStateException('Session is already ended.');
      }
      if (session.status == db.SessionStatus.paused) {
        throw InvalidSessionStateException('Cannot end session while paused.');
      }

      final open = await _getOpenSegmentRowOrThrow(command.sessionId);
      await _closeSegment(open, endTime: command.endedAt);

      await _db.into(_db.sessionSettlements).insert(
            SessionSettlementsCompanion.insert(
              id: _newId(),
              sessionId: command.sessionId.value,
              paidAmount: Value(command.paidAmount),
            ),
          );

      await (_db.update(_db.sessions)
            ..where((t) => t.id.equals(command.sessionId.value)))
          .write(
        SessionsCompanion(
          status: const Value(db.SessionStatus.ended),
          endTime: Value(command.endedAt),
        ),
      );

      await (_db.update(_db.devices)..where((t) => t.id.equals(session.deviceId)))
          .write(const DevicesCompanion(status: Value(db.DeviceStatus.idle)));

      final aggregates = await _recalculateUsingStoredRates(
        command.sessionId,
        now: command.endedAt,
      );

      await _applySessionTotalsToUser(
        userId: session.userId,
        playedMinutes: aggregates.totalMinutes,
        freeTimeUsedMinutes: aggregates.freeTimeUsedMinutes,
        paidAmount: command.paidAmount,
        now: command.endedAt,
      );

      final updated = await _getSessionRowOrThrow(command.sessionId);
      return _mapSession(updated);
    });
  }

  Future<Session?> _getOngoingSessionRowForDevice(DeviceId deviceId) {
    final query = _db.select(_db.sessions)
      ..where(
        (t) =>
            t.deviceId.equals(deviceId.value) &
            (t.status.equals(db.SessionStatus.active.name) |
                t.status.equals(db.SessionStatus.paused.name)),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
      ..limit(1);

    return query.getSingleOrNull();
  }

  Future<Session> _getSessionRowOrThrow(SessionId sessionId) async {
    final row = await (_db.select(_db.sessions)
          ..where((t) => t.id.equals(sessionId.value))
          ..limit(1))
        .getSingleOrNull();

    if (row == null) {
      throw SessionNotFoundException(sessionId);
    }

    return row;
  }

  Future<SessionModeSegment?> _getOpenSegmentRow(SessionId sessionId) {
    final query = _db.select(_db.sessionModeSegments)
      ..where(
        (t) => t.sessionId.equals(sessionId.value) & t.endTime.isNull(),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
      ..limit(1);

    return query.getSingleOrNull();
  }

  Future<SessionModeSegment> _getOpenSegmentRowOrThrow(
    SessionId sessionId,
  ) async {
    final row = await _getOpenSegmentRow(sessionId);
    if (row == null) {
      throw InvalidSessionStateException('No open mode segment found.');
    }
    return row;
  }

  Future<void> _closeSegment(
    SessionModeSegment open, {
    required DateTime endTime,
  }) async {
    if (endTime.isBefore(open.startTime)) {
      throw InvalidSessionStateException('Segment end time is before start time.');
    }

    final durationMinutes = _roundUpToMinutes(endTime.difference(open.startTime));

    await (_db.update(_db.sessionModeSegments)..where((t) => t.id.equals(open.id)))
        .write(
      SessionModeSegmentsCompanion(
        endTime: Value(endTime),
        durationMinutes: Value(durationMinutes),
      ),
    );
  }

  Future<_Aggregates> _recalculateUsingStoredRates(
    SessionId sessionId, {
    required DateTime now,
  }) async {
    final sessionRow = await _getSessionRowOrThrow(sessionId);

    final deviceRow = await (_db.select(_db.devices)
          ..where((t) => t.id.equals(sessionRow.deviceId))
          ..limit(1))
        .getSingleOrNull();

    if (deviceRow == null) {
      throw InvalidSessionStateException('Device not found for session.');
    }

    final userRow = await (_db.select(_db.users)
          ..where((t) => t.id.equals(sessionRow.userId))
          ..limit(1))
        .getSingleOrNull();

    if (userRow == null) {
      throw InvalidSessionStateException('User not found for session.');
    }

    final effectiveFreeRemaining = _effectiveFreeTimeRemaining(userRow, now: now);

    final segments = await (_db.select(_db.sessionModeSegments)
          ..where((t) => t.sessionId.equals(sessionId.value))
          ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .get();

    final aggregates = _computeAggregates(
      segments,
      now: now,
      onlineRatePerMinute: deviceRow.onlineRate,
      offlineRatePerMinute: deviceRow.offlineRate,
      freeTimeRemainingMinutes: effectiveFreeRemaining,
    );

    await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId.value)))
        .write(
      SessionsCompanion(
        totalDuration: Value(aggregates.totalMinutes),
        onlineMinutes: Value(aggregates.totalOnlineMinutes),
        offlineMinutes: Value(aggregates.totalOfflineMinutes),
        calculatedCost: Value(aggregates.cost),
        freeTimeUsed: Value(aggregates.freeTimeUsedMinutes),
      ),
    );

    return aggregates;
  }

  Future<void> _applySessionTotalsToUser({
    required String userId,
    required int playedMinutes,
    required int freeTimeUsedMinutes,
    required double paidAmount,
    required DateTime now,
  }) async {
    final userRow = await (_db.select(_db.users)
          ..where((t) => t.id.equals(userId))
          ..limit(1))
        .getSingleOrNull();

    if (userRow == null) {
      throw InvalidSessionStateException('User not found.');
    }

    final effectiveFreeRemaining = _effectiveFreeTimeRemaining(userRow, now: now);
    final newFreeRemaining = math.max(0, effectiveFreeRemaining - freeTimeUsedMinutes);

    await (_db.update(_db.users)..where((t) => t.id.equals(userId))).write(
      UsersCompanion(
        totalPlayedMinutes: Value(userRow.totalPlayedMinutes + playedMinutes),
        totalPaidAmount: Value(userRow.totalPaidAmount + paidAmount),
        freeTimeRemaining: Value(newFreeRemaining),
      ),
    );
  }

  int _effectiveFreeTimeRemaining(User user, {required DateTime now}) {
    final expiry = user.freeTimeExpiry;
    if (expiry == null) {
      return 0;
    }
    if (!expiry.isAfter(now)) {
      return 0;
    }
    return user.freeTimeRemaining;
  }

  _Aggregates _computeAggregates(
    List<SessionModeSegment> segments, {
    required DateTime now,
    required double onlineRatePerMinute,
    required double offlineRatePerMinute,
    required int freeTimeRemainingMinutes,
  }) {
    var totalOnline = 0;
    var totalOffline = 0;

    var payableOnline = 0;
    var payableOffline = 0;

    var remainingFree = freeTimeRemainingMinutes;
    var freeUsed = 0;

    for (final seg in segments) {
      final end = seg.endTime ?? now;
      final duration = _roundUpToMinutes(end.difference(seg.startTime));

      if (seg.mode == db.SessionMode.online) {
        totalOnline += duration;
      } else {
        totalOffline += duration;
      }

      final freeForThis = math.min(duration, remainingFree);
      remainingFree -= freeForThis;
      freeUsed += freeForThis;

      final payable = duration - freeForThis;
      if (seg.mode == db.SessionMode.online) {
        payableOnline += payable;
      } else {
        payableOffline += payable;
      }
    }

    final cost = (payableOnline * onlineRatePerMinute) +
        (payableOffline * offlineRatePerMinute);

    return _Aggregates(
      totalMinutes: totalOnline + totalOffline,
      totalOnlineMinutes: totalOnline,
      totalOfflineMinutes: totalOffline,
      freeTimeUsedMinutes: freeUsed,
      cost: cost,
    );
  }

  int _roundUpToMinutes(Duration duration) {
    final seconds = duration.inSeconds;
    if (seconds <= 0) {
      return 0;
    }
    return (seconds + 59) ~/ 60;
  }

  domain.Session _mapSession(Session row) {
    return domain.Session(
      id: SessionId(row.id),
      userId: UserId(row.userId),
      deviceId: DeviceId(row.deviceId),
      mode: _toDomainMode(row.mode),
      startTime: row.startTime,
      endTime: row.endTime,
      totalDurationMinutes: row.totalDuration,
      onlineMinutes: row.onlineMinutes,
      offlineMinutes: row.offlineMinutes,
      calculatedCost: row.calculatedCost,
      freeTimeUsedMinutes: row.freeTimeUsed,
      status: _toDomainStatus(row.status),
    );
  }

  domain.SessionModeSegment _mapSegment(SessionModeSegment row) {
    return domain.SessionModeSegment(
      id: SessionModeSegmentId(row.id),
      sessionId: SessionId(row.sessionId),
      mode: _toDomainMode(row.mode),
      startTime: row.startTime,
      endTime: row.endTime,
      durationMinutes: row.durationMinutes,
    );
  }

  db.SessionMode _toDbMode(domain.SessionMode mode) {
    return switch (mode) {
      domain.SessionMode.online => db.SessionMode.online,
      domain.SessionMode.offline => db.SessionMode.offline,
    };
  }

  domain.SessionMode _toDomainMode(db.SessionMode mode) {
    return switch (mode) {
      db.SessionMode.online => domain.SessionMode.online,
      db.SessionMode.offline => domain.SessionMode.offline,
    };
  }

  domain.SessionStatus _toDomainStatus(db.SessionStatus status) {
    return switch (status) {
      db.SessionStatus.active => domain.SessionStatus.active,
      db.SessionStatus.paused => domain.SessionStatus.paused,
      db.SessionStatus.ended => domain.SessionStatus.ended,
    };
  }

  String _newId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final rand = math.Random().nextInt(1 << 32);
    return '${now.toRadixString(16)}-${rand.toRadixString(16)}';
  }
}

class _Aggregates {
  const _Aggregates({
    required this.totalMinutes,
    required this.totalOnlineMinutes,
    required this.totalOfflineMinutes,
    required this.freeTimeUsedMinutes,
    required this.cost,
  });

  final int totalMinutes;
  final int totalOnlineMinutes;
  final int totalOfflineMinutes;
  final int freeTimeUsedMinutes;
  final double cost;
}
