import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/core/services/notification_service.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';
import 'package:focus_flow/features/tasks/presentation/bloc/tasks_bloc.dart';

class MockNotificationService implements NotificationService {
  int? scheduledId;
  String? scheduledTitle;
  DateTime? scheduledDate;
  int? cancelledId;

  @override
  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    scheduledId = id;
    scheduledTitle = title;
    this.scheduledDate = scheduledDate;
  }

  @override
  Future<void> cancelNotification(int id) async {
    cancelledId = id;
  }
}

class MockTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];
  int _nextId = 1;

  @override
  Future<List<Task>> featchAll() async => List.unmodifiable(_tasks);

  @override
  Future<Task?> getTaskById(int id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) return _tasks[index];
    return null;
  }

  @override
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
  }) async {
    final id = _nextId++;
    final task = Task(
      id: id,
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      isCompleted: isCompleted,
      estimatedPomodoros: estimatedPomodoros,
      completedPomodoros: completedPomodoros,
      orderIndex: orderIndex,
      isDeleted: isDeleted,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _tasks.add(task);
    return id;
  }

  @override
  Future<bool> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      return true;
    }
    return false;
  }

  @override
  Future<int> upsertTask(TasksCompanion task) async {
    return 1;
  }

  @override
  Future<void> upsertTasks(List<TasksCompanion> tasks) async {}

  @override
  Future<int> softDeleteTask(int id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isDeleted: true);
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteTask(int id) async => softDeleteTask(id);

  @override
  Future<int> compliteTask(int id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: true);
      return 1;
    }
    return 0;
  }

  @override
  Future<int> restoreTask(int id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isDeleted: false);
      return 1;
    }
    return 0;
  }

  @override
  Future<int> incrementCompletedPomodoros(int id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        completedPomodoros: _tasks[index].completedPomodoros + 1,
      );
      return 1;
    }
    return 0;
  }

  @override
  Stream<List<Task>> filterTask({
    int? priority,
    bool? isCompleted,
    String? searchQuery,
  }) {
    return Stream.value(_tasks);
  }

  @override
  Stream<List<Task>> watchActiveTasks() {
    return Stream.value(_tasks.where((t) => !t.isDeleted).toList());
  }
}

void main() {
  late MockTaskRepository taskRepository;
  late TasksBloc tasksBloc;

  setUp(() {
    taskRepository = MockTaskRepository();
    tasksBloc = TasksBloc(taskRepository: taskRepository);
  });

  tearDown(() async {
    await tasksBloc.close();
  });

  test('Initial state is TasksInitialState', () {
    expect(tasksBloc.state, isA<TasksInitialState>());
  });

  test('OnLoadTasksEvent loads tasks from local repository', () async {
    await taskRepository.insertTask(
      title: 'Local Task 1',
      priority: 1,
      isCompleted: false,
      estimatedPomodoros: 2,
      completedPomodoros: 0,
      orderIndex: 0,
      isDeleted: false,
    );

    tasksBloc.add(OnLoadTasksEvent());

    await expectLater(
      tasksBloc.stream,
      emitsThrough(
        predicate<TasksState>((state) {
          return state is TasksSuccessState &&
              state.data.length == 1 &&
              state.data.first.title == 'Local Task 1';
        }),
      ),
    );
  });

  test('OnAddTaskEvent inserts task into local database and updates state', () async {
    tasksBloc.add(
      const OnAddTaskEvent(
        title: 'New Local Task',
        description: 'No Supabase needed',
        priority: 2,
        isCompleted: false,
        estimatedPomodoros: 3,
        completedPomodoros: 0,
        orderIndex: 0,
        isDeleted: false,
        dueDate: null,
        dueTime: null,
      ),
    );

    await expectLater(
      tasksBloc.stream,
      emitsThrough(
        predicate<TasksState>((state) {
          return state is TasksSuccessState &&
              state.data.length == 1 &&
              state.data.first.title == 'New Local Task';
        }),
      ),
    );

    final allTasks = await taskRepository.featchAll();
    expect(allTasks.length, equals(1));
    expect(allTasks.first.title, equals('New Local Task'));
  });

  test('OnCompleteTaskEvent marks task as completed locally', () async {
    final id = await taskRepository.insertTask(
      title: 'Complete Me',
      priority: 1,
      isCompleted: false,
      estimatedPomodoros: 1,
      completedPomodoros: 0,
      orderIndex: 0,
      isDeleted: false,
    );

    tasksBloc.add(OnCompleteTaskEvent(id: id));

    await expectLater(
      tasksBloc.stream,
      emitsThrough(
        predicate<TasksState>((state) {
          return state is TasksSuccessState &&
              state.data.first.isCompleted == true;
        }),
      ),
    );

    final updated = await taskRepository.getTaskById(id);
    expect(updated?.isCompleted, isTrue);
  });

  test('OnSoftDeleteTaskEvent marks task as deleted locally', () async {
    final id = await taskRepository.insertTask(
      title: 'Delete Me',
      priority: 1,
      isCompleted: false,
      estimatedPomodoros: 1,
      completedPomodoros: 0,
      orderIndex: 0,
      isDeleted: false,
    );

    tasksBloc.add(OnSoftDeleteTaskEvent(id: id));

    await expectLater(
      tasksBloc.stream,
      emitsThrough(
        predicate<TasksState>((state) {
          return state is TasksSuccessState &&
              state.data.first.isDeleted == true;
        }),
      ),
    );

    final updated = await taskRepository.getTaskById(id);
    expect(updated?.isDeleted, isTrue);
  });

  test('Adding task with future dueDate schedules notification', () async {
    final mockNotification = MockNotificationService();
    final blocWithNotification = TasksBloc(
      taskRepository: taskRepository,
      notificationService: mockNotification,
    );
    final futureDate = DateTime.now().add(const Duration(hours: 2));

    blocWithNotification.add(
      OnAddTaskEvent(
        title: 'Notify Task',
        priority: 1,
        isCompleted: false,
        estimatedPomodoros: 2,
        completedPomodoros: 0,
        orderIndex: 0,
        isDeleted: false,
        dueDate: futureDate,
        dueTime: null,
      ),
    );

    await expectLater(
      blocWithNotification.stream,
      emitsThrough(isA<TasksSuccessState>()),
    );

    expect(mockNotification.scheduledTitle, contains('Notify Task'));
    expect(mockNotification.scheduledDate, equals(futureDate));

    await blocWithNotification.close();
  });

  test('Completing task cancels scheduled notification', () async {
    final mockNotification = MockNotificationService();
    final blocWithNotification = TasksBloc(
      taskRepository: taskRepository,
      notificationService: mockNotification,
    );

    final id = await taskRepository.insertTask(
      title: 'Cancel Me',
      priority: 1,
      isCompleted: false,
      estimatedPomodoros: 1,
      completedPomodoros: 0,
      orderIndex: 0,
      isDeleted: false,
    );

    blocWithNotification.add(OnCompleteTaskEvent(id: id));

    await expectLater(
      blocWithNotification.stream,
      emitsThrough(isA<TasksSuccessState>()),
    );

    expect(mockNotification.cancelledId, equals(id));

    await blocWithNotification.close();
  });
}
