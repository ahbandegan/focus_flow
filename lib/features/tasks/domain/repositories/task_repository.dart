import 'package:focus_flow/core/database/app_database.dart';

abstract class TaskRepository {
  Future<List<Task>> featchAll();
  Future<int> insertTask({
    required String title,
    required int priority,
    required bool isCompleted,
    required int estimatedPomodoros,
    required bool completedPomodoros,
    required int orderIndex,
    required bool isDeleted,
  });
  Future<bool> updateTask();
  Future<int> deleteTask(int id);
  Future<bool> compliteTask(int id);
  Future<bool> restoreTask();
  Stream<List<Task>> filterTask({
    int? priority,
    bool? isCompleted,
    String? searchQuery,
  });
}

/* 
OnLoadTasksEvent
OnAddTaskEvent
OnUpdateTaskEvent
OnDeleteTaskEvent
OnCompleteTaskEvent
OnRestoreTaskEvent
OnFilterTasksEvent
 */
