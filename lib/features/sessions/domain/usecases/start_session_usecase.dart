import '../exceptions/session_exceptions.dart';
import '../repositories/sessions_repository.dart';

class StartSessionUseCase {
  StartSessionUseCase(this._sessionsRepository);

  final SessionsRepository _sessionsRepository;

  Future<void> call(StartSessionCommand command) async {
    final existing =
        await _sessionsRepository.getActiveSessionForDevice(command.deviceId);

    if (existing != null) {
      throw ActiveSessionExistsException(command.deviceId);
    }

    await _sessionsRepository.startSession(command);
  }
}
