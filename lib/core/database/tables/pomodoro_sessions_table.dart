import 'package:drift/drift.dart';
import 'package:focus_flow/core/database/tables/task_table.dart';

class PomodoroSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().nullable().references(Tasks, #id, onDelete: KeyAction.setNull)();
  TextColumn get sessionType => text()(); // 'focus', 'shortBreak', 'longBreak'
  IntColumn get targetDurationMinutes => integer().withDefault(const Constant(25))();
  IntColumn get actualDurationSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}