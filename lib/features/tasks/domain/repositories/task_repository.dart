import 'package:focus_flow/core/database/app_database.dart';

abstract class TaskRepository {
  Future<List<Task>> featchAll();
  Future<int> insertTask({
    required String title,
    required int priority,
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
}
