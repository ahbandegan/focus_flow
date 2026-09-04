import 'package:drift/drift.dart';
import 'package:focus_flow/core/database/tables/tags_table.dart';
import 'package:focus_flow/core/database/tables/task_table.dart';

class TaskTags extends Table {
  IntColumn get taskId =>
      integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {taskId, tagId};
}
