import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/task_table.dart';
import 'tables/subtask_table.dart';
import 'tables/tags_table.dart';
import 'tables/tasktags_table.dart';
import 'tables/pomodoro_sessions_table.dart';
import 'daos/tasks_dao.dart';
import 'daos/subtasks_dao.dart';
import 'daos/tags_dao.dart';
import 'daos/pomodoro_dao.dart';
export 'supabase_mappers.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Tasks,
    Subtasks,
    Tags,
    TaskTags,
    PomodoroSessions,
  ],
  daos: [
    TasksDao,
    SubtasksDao,
    TagsDao,
    PomodoroDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'focus_flow_db');
  }
}
