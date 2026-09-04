import 'package:drift/drift.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/core/database/daos/tasks_dao.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl extends TaskRepository {
  final TasksDao _tasksDao;

  TaskRepositoryImpl({required this._tasksDao});

  @override
  Future<int> compliteTask(int id) async =>
      await _tasksDao.toggleTaskCompletion(id, true);

  @override
  Future<int> deleteTask(int id) async => await _tasksDao.softDeleteTask(id);

  @override
  Future<List<Task>> featchAll() async => await _tasksDao.getAllTasks();

  @override
  Stream<List<Task>> filterTask({
    int? priority,
    bool? isCompleted,
    String? searchQuery,
  }) {
    return _tasksDao.filterTasks(
      isCompleted: false,
      priority: priority,
      searchQuery: "",
    );
  }

  @override
  Future<int> insertTask({
    required String title,
    required int priority,
    required bool isCompleted,
    required int estimatedPomodoros,
    required int completedPomodoros,
    required int orderIndex,
    required bool isDeleted,
  }) {
    _tasksDao.insertTask(
      TasksCompanion.insert(
        title: title,
        priority: Value(priority),
        isCompleted: Value(isCompleted),
        estimatedPomodoros: Value(estimatedPomodoros),
        completedPomodoros: Value(completedPomodoros),
        orderIndex: Value(orderIndex),
        isDeleted: Value(isDeleted),
      ),
    );
    throw UnimplementedError();
  }

  @override
  Future<int> restoreTask(int id) async => await _tasksDao.restoreTask(id);

  @override
  Future<int> incrementCompletedPomodoros(int id) async =>
      _tasksDao.incrementCompletedPomodoros(id);

  @override
  Future<int> softDeleteTask(int id) async =>
      await _tasksDao.softDeleteTask(id);

  @override
  Future<bool> updateTask(Task task) async => await _tasksDao.updateTask(task);
}
