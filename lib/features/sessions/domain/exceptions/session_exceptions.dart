import '../value_objects/ids.dart';

class ActiveSessionExistsException implements Exception {
  ActiveSessionExistsException(this.deviceId);
  final DeviceId deviceId;

  @override
  String toString() => 'Active session already exists for deviceId=$deviceId';
}

class SessionNotFoundException implements Exception {
  SessionNotFoundException(this.sessionId);
  final SessionId sessionId;

  @override
  String toString() => 'Session not found: sessionId=$sessionId';
}

class InvalidSessionStateException implements Exception {
  InvalidSessionStateException(this.message);
  final String message;

  @override
  String toString() => 'Invalid session state: $message';
}

class SettlementRequiredException implements Exception {
  SettlementRequiredException(this.sessionId);
  final SessionId sessionId;

  @override
  String toString() => 'Settlement required before ending sessionId=$sessionId';
}
