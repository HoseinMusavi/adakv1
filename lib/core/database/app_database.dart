import 'package:drift/drift.dart';

import 'connection.dart';
import 'enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Devices,
    Sessions,
    SessionModeSegments,
    MenuItems,
    Orders,
    OrderItems,
    RewardRules,
    SessionSettlements,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}
