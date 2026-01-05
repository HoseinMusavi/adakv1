import '../entities/session.dart';
import '../exceptions/session_exceptions.dart';
import '../repositories/sessions_repository.dart';
import '../value_objects/ids.dart';

class ResumeSessionUseCase {
  ResumeSessionUseCase(this._sessionsRepository);

  final SessionsRepository _sessionsRepository;

  Future<Session> call(SessionId sessionId, {required DateTime resumedAt}) async {
    final session = await _sessionsRepository.getById(sessionId);

    if (session.isEnded) {
      throw InvalidSessionStateException('Cannot resume an ended session.');
    }
    if (session.isActive) {
      throw InvalidSessionStateException('Session is already active.');
    }

    return _sessionsRepository.resumeSession(sessionId, resumedAt: resumedAt);
  }
}
