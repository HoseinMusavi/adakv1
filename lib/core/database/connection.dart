import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final appSupportDir = await getApplicationSupportDirectory();
    final dbFile = File(p.join(appSupportDir.path, 'geekment_adac.sqlite'));

    return NativeDatabase.createInBackground(dbFile);
  });
}
