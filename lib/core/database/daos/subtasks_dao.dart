import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/subtask_table.dart';

part 'subtasks_dao.g.dart';

@DriftAccessor(tables: [Subtasks])
class SubtasksDao extends DatabaseAccessor<AppDatabase>
    with _$SubtasksDaoMixin {
  SubtasksDao(super.db);

  // 1. Streams / Watches
  Stream<List<Subtask>> watchSubtasksForTask(int taskId) {
    return (select(subtasks)
          ..where((s) => s.taskId.equals(taskId))
          ..orderBy([(s) => OrderingTerm.asc(s.orderIndex)]))
        .watch();
  }

  // 2. Queries
  Future<List<Subtask>> getSubtasksForTask(int taskId) {
    return (select(subtasks)
          ..where((s) => s.taskId.equals(taskId))
          ..orderBy([(s) => OrderingTerm.asc(s.orderIndex)]))
        .get();
  }

  Future<Subtask?> getSubtaskById(int id) {
    return (select(subtasks)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  // 3. Insert & Update
  Future<int> insertSubtask(SubtasksCompanion subtask) =>
      into(subtasks).insert(subtask);

  Future<bool> updateSubtask(Subtask subtask) =>
      update(subtasks).replace(subtask);

  Future<int> toggleSubtaskCompletion(int id, bool isCompleted) {
    return (update(subtasks)..where((s) => s.id.equals(id))).write(
      SubtasksCompanion(
        isCompleted: Value(isCompleted),
      ),
    );
  }

  Future<int> updateSubtaskOrder(int id, int orderIndex) {
    return (update(subtasks)..where((s) => s.id.equals(id))).write(
      SubtasksCompanion(
        orderIndex: Value(orderIndex),
      ),
    );
  }

  // 4. Delete
  Future<int> deleteSubtask(int id) {
    return (delete(subtasks)..where((s) => s.id.equals(id))).go();
  }

  Future<int> deleteSubtasksForTask(int taskId) {
    return (delete(subtasks)..where((s) => s.taskId.equals(taskId))).go();
  }
}
