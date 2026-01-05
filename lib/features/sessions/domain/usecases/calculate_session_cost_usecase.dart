import '../entities/session.dart';
import '../entities/session_mode_segment.dart';
import '../value_objects/session_cost_breakdown.dart';

class CalculateSessionCostUseCase {
  const CalculateSessionCostUseCase();

  /// Calculates minutes and costs from a list of segments.
  ///
  /// Time tracking & segment rules:
  /// - The session time is split into mode segments. Each segment has a mode
  ///   (online/offline), a start time, and an end time.
  /// - Only CLOSED segments (`endTime != null`) are billed. The current open
  ///   segment is only billed when it gets closed (pause/switch/end) or when
  ///   you explicitly "recalculate" at a given [now] by providing it.
  ///
  /// Rounding policy:
  /// - For billing we currently round UP to full minutes.
  /// - Example: 61 seconds => 2 minutes.
  /// - TODO: Make this configurable (per-minute, per-15-min blocks, etc.).
  ///
  /// Rate units:
  /// - The business rule provided is `minutes × rate`.
  /// - Therefore [onlineRatePerMinute] and [offlineRatePerMinute] are expected
  ///   to be rates per minute.
  SessionCostBreakdown call({
    required List<SessionModeSegment> segments,
    required double onlineRatePerMinute,
    required double offlineRatePerMinute,
    DateTime? now,
  }) {
    var onlineMinutes = 0;
    var offlineMinutes = 0;

    for (final segment in segments) {
      final end = segment.endTime ?? now;
      if (end == null) {
        continue;
      }

      final durationMinutes = _roundUpToMinutes(end.difference(segment.startTime));

      if (segment.mode == SessionMode.online) {
        onlineMinutes += durationMinutes;
      } else {
        offlineMinutes += durationMinutes;
      }
    }

    final onlineCost = onlineMinutes * onlineRatePerMinute;
    final offlineCost = offlineMinutes * offlineRatePerMinute;

    return SessionCostBreakdown(
      onlineMinutes: onlineMinutes,
      offlineMinutes: offlineMinutes,
      onlineCost: onlineCost,
      offlineCost: offlineCost,
      totalCost: onlineCost + offlineCost,
    );
  }

  int _roundUpToMinutes(Duration duration) {
    final seconds = duration.inSeconds;
    if (seconds <= 0) {
      return 0;
    }
    return (seconds + 59) ~/ 60;
  }
}
