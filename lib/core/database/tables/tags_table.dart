
import 'package:drift/drift.dart';

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique().withLength(min: 1, max: 40)();
  TextColumn get colorHex => text().withDefault(const Constant('#64748B'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}