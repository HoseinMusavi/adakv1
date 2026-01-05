import '../entities/session.dart';
import '../exceptions/session_exceptions.dart';
import '../repositories/sessions_repository.dart';
import '../value_objects/ids.dart';

class PauseSessionUseCase {
  PauseSessionUseCase(this._sessionsRepository);

  final SessionsRepository _sessionsRepository;

  Future<Session> call(SessionId sessionId, {required DateTime pausedAt}) async {
    final session = await _sessionsRepository.getById(sessionId);

    if (session.isEnded) {
      throw InvalidSessionStateException('Cannot pause an ended session.');
    }
    if (session.isPaused) {
      throw InvalidSessionStateException('Session is already paused.');
    }

    return _sessionsRepository.pauseSession(sessionId, pausedAt: pausedAt);
  }
}
