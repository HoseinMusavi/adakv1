class UserId {
  const UserId(this.value);
  final String value;

  @override
  bool operator ==(Object other) => other is UserId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class DeviceId {
  const DeviceId(this.value);
  final String value;

  @override
  bool operator ==(Object other) => other is DeviceId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class SessionId {
  const SessionId(this.value);
  final String value;

  @override
  bool operator ==(Object other) => other is SessionId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class SessionModeSegmentId {
  const SessionModeSegmentId(this.value);
  final String value;

  @override
  bool operator ==(Object other) =>
      other is SessionModeSegmentId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
