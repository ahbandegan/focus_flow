// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pomodoro_dao.dart';

// ignore_for_file: type=lint
mixin _$PomodoroDaoMixin on DatabaseAccessor<AppDatabase> {
  $TasksTable get tasks => attachedDatabase.tasks;
  $PomodoroSessionsTable get pomodoroSessions =>
      attachedDatabase.pomodoroSessions;
  PomodoroDaoManager get managers => PomodoroDaoManager(this);
}

class PomodoroDaoManager {
  final _$PomodoroDaoMixin _db;
  PomodoroDaoManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
  $$PomodoroSessionsTableTableManager get pomodoroSessions =>
      $$PomodoroSessionsTableTableManager(
        _db.attachedDatabase,
        _db.pomodoroSessions,
      );
}
