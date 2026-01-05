import 'package:drift/drift.dart';

import 'enums.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  IntColumn get totalPlayedMinutes => integer().withDefault(const Constant(0))();
  RealColumn get totalPaidAmount => real().withDefault(const Constant(0.0))();
  IntColumn get freeTimeRemaining => integer().withDefault(const Constant(0))();
  DateTimeColumn get freeTimeExpiry => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => textEnum<DeviceType>()();
  TextColumn get status => textEnum<DeviceStatus>()
      .withDefault(const Constant('idle'))();
  RealColumn get onlineRate => real().withDefault(const Constant(0.0))();
  RealColumn get offlineRate => real().withDefault(const Constant(0.0))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get deviceId => text().references(Devices, #id)();

  /// Current mode. History is tracked in [SessionModeSegments].
  TextColumn get mode => textEnum<SessionMode>()
      .withDefault(const Constant('online'))();

  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();

  /// Total duration in minutes.
  IntColumn get totalDuration => integer().withDefault(const Constant(0))();

  /// Cached minutes by mode, derived from [SessionModeSegments].
  IntColumn get onlineMinutes => integer().withDefault(const Constant(0))();
  IntColumn get offlineMinutes => integer().withDefault(const Constant(0))();

  RealColumn get calculatedCost => real().withDefault(const Constant(0.0))();
  IntColumn get freeTimeUsed => integer().withDefault(const Constant(0))();

  TextColumn get status => textEnum<SessionStatus>()
      .withDefault(const Constant('active'))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class SessionModeSegments extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();

  TextColumn get mode => textEnum<SessionMode>()();

  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();

  /// Duration in minutes for this segment. Kept for fast aggregation.
  IntColumn get durationMinutes => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class MenuItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => textEnum<MenuCategory>()();
  RealColumn get price => real()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  RealColumn get totalPrice => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class OrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get menuItemId => text().references(MenuItems, #id)();

  IntColumn get quantity => integer().withDefault(const Constant(1))();

  /// Snapshot of menu item price at order creation time.
  RealColumn get unitPrice => real()();

  /// Stored line total for audit/reporting consistency.
  RealColumn get lineTotal => real()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class RewardRules extends Table {
  TextColumn get id => text()();

  /// e.g. 360 minutes (6 hours)
  IntColumn get playedMinutesThreshold => integer()();

  /// e.g. 60 minutes (1 hour)
  IntColumn get freeMinutesReward => integer()();

  /// Free time expiry in days from grant date.
  IntColumn get expiryDays => integer()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class SessionSettlements extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();

  /// Amount paid for the session time component.
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}
