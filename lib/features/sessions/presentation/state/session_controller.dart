import 'package:adak/core/database/providers.dart';
import 'package:adak/features/sessions/data/repositories/drift_sessions_repository.dart';
import 'package:adak/features/sessions/domain/entities/session.dart';
import 'package:adak/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:adak/features/sessions/domain/value_objects/ids.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'active_session_state.dart';
import 'session_ticker.dart';

final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftSessionsRepository(db);
});

final activeSessionForDeviceProvider =
    StreamProvider.autoDispose.family<Session?, DeviceId>((ref, deviceId) {
  final repo = ref.watch(sessionsRepositoryProvider);
  return repo.watchActiveSessionForDevice(deviceId);
});

final activeSessionControllerProvider = NotifierProvider.autoDispose
    .family<ActiveSessionController, ActiveSessionState, DeviceId>(
  ActiveSessionController.new,
);

class ActiveSessionController extends AutoDisposeFamilyNotifier<
    ActiveSessionState, DeviceId> {
  @override
  ActiveSessionState build(DeviceId deviceId) {
    final now = ref.watch(sessionTickerProvider);
    final sessionAsync = ref.watch(activeSessionForDeviceProvider(deviceId));

    return ActiveSessionState(
      activeSession: sessionAsync.valueOrNull,
      now: now,
    );
  }
}
