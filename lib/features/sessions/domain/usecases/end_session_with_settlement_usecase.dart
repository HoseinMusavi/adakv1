import '../entities/session.dart';
import '../exceptions/session_exceptions.dart';
import '../repositories/sessions_repository.dart';

class EndSessionWithSettlementUseCase {
  EndSessionWithSettlementUseCase(this._sessionsRepository);

  final SessionsRepository _sessionsRepository;

  Future<Session> call(EndSessionSettlementCommand command) async {
    final session = await _sessionsRepository.getById(command.sessionId);

    if (session.isEnded) {
      throw InvalidSessionStateException('Session is already ended.');
    }

    if (command.paidAmount.isNaN || command.paidAmount.isInfinite) {
      throw InvalidSessionStateException('Invalid paid amount.');
    }

    if (command.paidAmount < 0) {
      throw InvalidSessionStateException('Paid amount cannot be negative.');
    }

    if (session.isPaused) {
      throw InvalidSessionStateException(
        'Cannot end session while paused. Resume, then settle and end.',
      );
    }

    // Settlement is required by business rules.
    // The data layer enforces this by inserting the settlement record in the
    // same transaction that ends the session.
    return _sessionsRepository.endSessionWithSettlement(command);
  }
}
