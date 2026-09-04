// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtasks_dao.dart';

// ignore_for_file: type=lint
mixin _$SubtasksDaoMixin on DatabaseAccessor<AppDatabase> {
  $TasksTable get tasks => attachedDatabase.tasks;
  $SubtasksTable get subtasks => attachedDatabase.subtasks;
  SubtasksDaoManager get managers => SubtasksDaoManager(this);
}

class SubtasksDaoManager {
  final _$SubtasksDaoMixin _db;
  SubtasksDaoManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
  $$SubtasksTableTableManager get subtasks =>
      $$SubtasksTableTableManager(_db.attachedDatabase, _db.subtasks);
}
