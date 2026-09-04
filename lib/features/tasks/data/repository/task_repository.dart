import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/core/database/daos/tasks_dao.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl extends TaskRepository {
  final TasksDao _tasksDao;

  TaskRepositoryImpl({required this._tasksDao});

  @override
  Future<bool> compliteTask(int id) async {
    final target = await _tasksDao.getTaskById(id);
    if (target != null) {
      return await _tasksDao.updateTask(target.copyWith(isCompleted: true));
    }
    return false;
  }

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
      priority: 1,
      searchQuery: "",
    );
  }

  @override
  Future<int> insertTask({
    required String title,
    required int priority,
    required bool isCompleted,
    required int estimatedPomodoros,
    required bool completedPomodoros,
    required int orderIndex,
    required bool isDeleted,
  }) {
    _tasksDao.insertTask(
      TasksCompanion.insert(title: title, priority: priority,
isCompleted: isCompleted,
estimatedPomodoros: estimatedPomodoros,
completedPomodoros: completedPomodoros,
orderIndex: orderIndex,
isDeleted: isDeleted,
)
    );
    throw UnimplementedError();
  }

  @override
  Future<bool> restoreTask() {
    // TODO: implement restoreTask
    throw UnimplementedError();
  }

  @override
  Future<bool> updateTask() {
    // TODO: implement updateTask
    throw UnimplementedError();
  }
}
