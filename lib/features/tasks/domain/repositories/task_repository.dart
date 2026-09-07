import 'package:focus_flow/core/database/app_database.dart';

abstract class TaskRepository {
  Future<List<Task>> featchAll();
  Future<int> insertTask({
    required String title,
    String? description,
    required int priority,
    DateTime? dueDate,
    required bool isCompleted,
    required int estimatedPomodoros,
    required int completedPomodoros,
    required int orderIndex,
    required bool isDeleted,
  });
  Future<bool> updateTask(Task task);
  Future<int> deleteTask(int id);
  Future<int> compliteTask(int id);
  Future<int> restoreTask(int id);
  Stream<List<Task>> filterTask({
    int? priority,
    bool? isCompleted,
    String? searchQuery,
  });
  Future<int> incrementCompletedPomodoros(int id);
  Future<int> softDeleteTask(int id);
  Future<Task?> getTaskById(int id);
  Future<int> upsertTask(TasksCompanion task);
  Future<void> upsertTasks(List<TasksCompanion> tasks);
  Stream<List<Task>> watchActiveTasks();
}
