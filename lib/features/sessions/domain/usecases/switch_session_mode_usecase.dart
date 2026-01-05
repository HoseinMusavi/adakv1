import '../entities/session.dart';
import '../exceptions/session_exceptions.dart';
import '../repositories/sessions_repository.dart';
import '../value_objects/ids.dart';

class SwitchSessionModeUseCase {
  SwitchSessionModeUseCase(this._sessionsRepository);

  final SessionsRepository _sessionsRepository;

  Future<Session> call(
    SessionId sessionId, {
    required SessionMode newMode,
    required DateTime switchedAt,
  }) async {
    final session = await _sessionsRepository.getById(sessionId);

    if (session.isEnded) {
      throw InvalidSessionStateException('Cannot switch mode on ended session.');
    }
    if (session.isPaused) {
      throw InvalidSessionStateException(
        'Cannot switch mode while paused. Resume first.',
      );
    }
    if (session.mode == newMode) {
      return session;
    }

    return _sessionsRepository.switchMode(
      sessionId,
      newMode: newMode,
      switchedAt: switchedAt,
    );
  }
}
