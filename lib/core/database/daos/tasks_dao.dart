import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/task_table.dart';
import '../tables/subtask_table.dart';
import '../tables/tags_table.dart';
import '../tables/tasktags_table.dart';

part 'tasks_dao.g.dart';

@DriftAccessor(tables: [Tasks, Subtasks, Tags, TaskTags])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  // 1. Streams / Watches
  Stream<List<Task>> watchAllTasks() {
    return (select(tasks)
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .watch();
  }

  Stream<List<Task>> watchActiveTasks() {
    return (select(tasks)
          ..where((t) => t.isDeleted.equals(false) & t.isCompleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.asc(t.orderIndex),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .watch();
  }

  Stream<List<Task>> watchCompletedTasks() {
    return (select(tasks)
          ..where((t) => t.isDeleted.equals(false) & t.isCompleted.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .watch();
  }

  Stream<List<Task>> watchTodayTasks() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return (select(tasks)
          ..where((t) =>
              t.isDeleted.equals(false) &
              t.isCompleted.equals(false) &
              t.dueDate.isBiggerOrEqualValue(startOfDay) &
              t.dueDate.isSmallerOrEqualValue(endOfDay))
          ..orderBy([(t) => OrderingTerm.asc(t.priority)]))
        .watch();
  }

  Stream<List<Task>> watchDeletedTasks() {
    return (select(tasks)
          ..where((t) => t.isDeleted.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Stream<Task?> watchTaskById(int id) {
    return (select(tasks)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  // 2. Single Queries
  Future<List<Task>> getAllTasks() => select(tasks).get();

  Future<Task?> getTaskById(int id) {
    return (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // 3. Search & Filter
  Stream<List<Task>> filterTasks({
    int? priority,
    bool? isCompleted,
    String? searchQuery,
  }) {
    final query = select(tasks)..where((t) => t.isDeleted.equals(false));

    if (priority != null) {
      query.where((t) => t.priority.equals(priority));
    }
    if (isCompleted != null) {
      query.where((t) => t.isCompleted.equals(isCompleted));
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query.where((t) => t.title.contains(searchQuery.trim()));
    }

    query.orderBy([(t) => OrderingTerm.asc(t.orderIndex)]);
    return query.watch();
  }

  // 4. Insert & Update
  Future<int> insertTask(TasksCompanion task) => into(tasks).insert(task);

  Future<bool> updateTask(Task task) => update(tasks).replace(task);

  Future<int> updateTaskCompanion(int id, TasksCompanion companion) {
    return (update(tasks)..where((t) => t.id.equals(id)))
        .write(companion.copyWith(updatedAt: Value(DateTime.now())));
  }

  // 5. Completion Toggle
  Future<int> toggleTaskCompletion(int id, bool isCompleted) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        isCompleted: Value(isCompleted),
        completedAt: isCompleted ? Value(DateTime.now()) : const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // 6. Pomodoro Counter Increment
  Future<int> incrementCompletedPomodoros(int id) async {
    final task = await getTaskById(id);
    if (task == null) return 0;

    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        completedPomodoros: Value(task.completedPomodoros + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // 7. Reorder
  Future<int> updateTaskOrder(int id, int orderIndex) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        orderIndex: Value(orderIndex),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // 8. Delete & Restore
  Future<int> softDeleteTask(int id) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> restoreTask(int id) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> permanentDeleteTask(int id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  Future<int> clearDeletedTasks() {
    return (delete(tasks)..where((t) => t.isDeleted.equals(true))).go();
  }
}
