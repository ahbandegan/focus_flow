import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/core/services/notification_service.dart';
import 'package:focus_flow/features/pomodoro/domain/repositories/pomodoro_repository.dart';
import 'package:focus_flow/features/pomodoro/presentation/bloc/pomodoro_bloc.dart';
import 'package:focus_flow/features/settings/domin/repositories/settings_repository.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';

class FakeTaskRepository implements TaskRepository {
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
  Future<int> compliteTask(int id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: true);
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
  Future<int> deleteTask(int id) async => 1;
  @override
  Future<int> restoreTask(int id) async => 1;
  @override
  Future<int> softDeleteTask(int id) async => 1;
  @override
  Future<int> upsertTask(TasksCompanion task) async => 1;
  @override
  Future<void> upsertTasks(List<TasksCompanion> tasks) async {}
  @override
  Stream<List<Task>> filterTask({int? priority, bool? isCompleted, String? searchQuery}) =>
      Stream.value(_tasks);
  @override
  Stream<List<Task>> watchActiveTasks() =>
      Stream.value(_tasks.where((t) => !t.isDeleted).toList());
}

class FakePomodoroRepository implements PomodoroRepository {
  final List<PomodoroSessionsCompanion> sessions = [];

  @override
  Future<int> insertSession(PomodoroSessionsCompanion session) async {
    sessions.add(session);
    return sessions.length;
  }

  @override
  Future<List<PomodoroSession>> getSessionsBetween(DateTime start, DateTime end) async => [];

  @override
  Future<int> getTotalFocusSecondsBetween(DateTime start, DateTime end) async => 0;

  @override
  Stream<int> watchTodayCompletedPomodoros() => Stream.value(sessions.length);

  @override
  Stream<int> watchTodayFocusSeconds() => Stream.value(0);

  @override
  Stream<List<PomodoroSession>> watchTodaySessions() => Stream.value([]);
}

class FakeSettingsRepository implements SettingsRepository {
  @override
  int focusDuration = 25;
  @override
  int shortBreak = 5;
  @override
  int longBreak = 15;
  @override
  int longBreakInterval = 4;
  @override
  int restDuration = 5;
  @override
  bool autoStartBreaks = false;
  @override
  bool autoStartPomodoros = false;
  @override
  bool soundEnabled = false;
  @override
  String soundName = 'bell';
  @override
  String themeMode = 'system';
  @override
  bool isLoggedIn = false;
  @override
  String? userEmail;

  @override
  Future<void> changeTheme(String newTheme) async {}
  @override
  Future<void> toggleSound(bool newValue) async {}
  @override
  Future<void> updateFocusDuration(int newDuration) async {}
  @override
  Future<void> updateRestDuration(int newDuration) async {}
  @override
  Future<void> saveUserSession({required String email, String? name, String? id}) async {}
  @override
  Future<void> logout() async {}
}

class FakeNotificationService implements NotificationService {
  @override
  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {}

  @override
  Future<void> requestPermissions() async {}

  String? lastTitle;
  String? lastBody;

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    lastTitle = title;
    lastBody = body;
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {}

  @override
  Future<void> cancelNotification(int id) async {}
}

class MockAudioPlayer extends AudioPlayer {
  @override
  Future<void> dispose() async {}
  @override
  Future<void> stop() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const globalChannel = MethodChannel('xyz.luan/audioplayers.global');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(globalChannel, (MethodCall call) async {
      return 1;
    });

    const channel = MethodChannel('xyz.luan/audioplayers');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      return 1;
    });
  });

  late FakeTaskRepository taskRepository;
  late FakePomodoroRepository pomodoroRepository;
  late FakeSettingsRepository settingsRepository;
  late FakeNotificationService notificationService;
  late MockAudioPlayer audioPlayer;
  late PomodoroBloc bloc;

  setUp(() {
    taskRepository = FakeTaskRepository();
    pomodoroRepository = FakePomodoroRepository();
    settingsRepository = FakeSettingsRepository();
    notificationService = FakeNotificationService();
    audioPlayer = MockAudioPlayer();

    bloc = PomodoroBloc(
      pomodoroRepository: pomodoroRepository,
      taskRepository: taskRepository,
      settingsRepository: settingsRepository,
      notificationService: notificationService,
      audioPlayer: audioPlayer,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  test('Selecting a task syncs cycles and sets selectedTask', () async {
    final taskId = await taskRepository.insertTask(
      title: 'Design Logo',
      priority: 1,
      isCompleted: false,
      estimatedPomodoros: 3,
      completedPomodoros: 1,
      orderIndex: 0,
      isDeleted: false,
    );
    final task = await taskRepository.getTaskById(taskId);

    bloc.add(PomodoroSelectTaskEvent(task));

    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<PomodoroState>((s) =>
            s.selectedTask?.id == taskId &&
            s.completedCycles == 1 &&
            s.targetCycles == 3),
      ),
    );
  });

  test('Unlinking a task clears selectedTask and resets cycles', () async {
    final taskId = await taskRepository.insertTask(
      title: 'Design Logo',
      priority: 1,
      isCompleted: false,
      estimatedPomodoros: 3,
      completedPomodoros: 2,
      orderIndex: 0,
      isDeleted: false,
    );
    final task = await taskRepository.getTaskById(taskId);

    bloc.add(PomodoroSelectTaskEvent(task));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<PomodoroState>((s) => s.selectedTask != null)),
    );

    bloc.add(const PomodoroSelectTaskEvent(null));
    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<PomodoroState>((s) => s.selectedTask == null && s.completedCycles == 0),
      ),
    );
  });

  test('Finishing focus session increments task completedPomodoros and updates state', () async {
    final taskId = await taskRepository.insertTask(
      title: 'Write Docs',
      priority: 2,
      isCompleted: false,
      estimatedPomodoros: 4,
      completedPomodoros: 1,
      orderIndex: 0,
      isDeleted: false,
    );
    final task = await taskRepository.getTaskById(taskId);

    bloc.add(PomodoroSelectTaskEvent(task));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<PomodoroState>((s) => s.selectedTask?.id == taskId)),
    );

    bloc.add(PomodoroFinishSessionEvent());

    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<PomodoroState>((s) =>
            s.selectedTask?.completedPomodoros == 2 &&
            s.completedCycles == 2 &&
            s.mode == PomodoroMode.shortBreak),
      ),
    );

    final updatedTask = await taskRepository.getTaskById(taskId);
    expect(updatedTask?.completedPomodoros, equals(2));
    expect(updatedTask?.isCompleted, isFalse);
    expect(notificationService.lastTitle, equals('Pomodoro Completed!'));
    expect(notificationService.lastBody, contains('Write Docs'));
  });

  test('Finishing final focus session auto-completes the task', () async {
    final taskId = await taskRepository.insertTask(
      title: 'Fix Critical Bug',
      priority: 3,
      isCompleted: false,
      estimatedPomodoros: 2,
      completedPomodoros: 1,
      orderIndex: 0,
      isDeleted: false,
    );
    final task = await taskRepository.getTaskById(taskId);

    bloc.add(PomodoroSelectTaskEvent(task));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<PomodoroState>((s) => s.selectedTask?.id == taskId)),
    );

    bloc.add(PomodoroFinishSessionEvent());

    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<PomodoroState>((s) =>
            s.selectedTask?.completedPomodoros == 2 &&
            s.selectedTask?.isCompleted == true &&
            s.isTaskFinished == true),
      ),
    );

    final updatedTask = await taskRepository.getTaskById(taskId);
    expect(updatedTask?.completedPomodoros, equals(2));
    expect(updatedTask?.isCompleted, isTrue);
    expect(notificationService.lastTitle, contains('Task Completed!'));
    expect(notificationService.lastBody, contains('Fix Critical Bug'));
  });

  test('Reset preserves task completed pomodoros as completedCycles', () async {
    final taskId = await taskRepository.insertTask(
      title: 'Review Code',
      priority: 1,
      isCompleted: false,
      estimatedPomodoros: 3,
      completedPomodoros: 2,
      orderIndex: 0,
      isDeleted: false,
    );
    final task = await taskRepository.getTaskById(taskId);

    bloc.add(PomodoroSelectTaskEvent(task));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<PomodoroState>((s) => s.selectedTask?.id == taskId)),
    );

    bloc.add(PomodoroResetEvent());

    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<PomodoroState>((s) =>
            s.status == PomodoroStatus.initial &&
            s.completedCycles == 2 &&
            s.selectedTask?.id == taskId),
      ),
    );
  });

  test('Skip increments task completed pomodoros when skipping focus', () async {
    final taskId = await taskRepository.insertTask(
      title: 'Refactor Code',
      priority: 1,
      isCompleted: false,
      estimatedPomodoros: 3,
      completedPomodoros: 1,
      orderIndex: 0,
      isDeleted: false,
    );
    final task = await taskRepository.getTaskById(taskId);

    bloc.add(PomodoroSelectTaskEvent(task));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<PomodoroState>((s) => s.selectedTask?.id == taskId)),
    );

    bloc.add(PomodoroSkipEvent());

    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<PomodoroState>((s) =>
            s.mode == PomodoroMode.shortBreak &&
            s.completedCycles == 2 &&
            s.selectedTask?.completedPomodoros == 2),
      ),
    );

    final updated = await taskRepository.getTaskById(taskId);
    expect(updated?.completedPomodoros, equals(2));
  });

  test('Skip does not increment task completed pomodoros when skipping break', () async {
    final taskId = await taskRepository.insertTask(
      title: 'Refactor Code',
      priority: 1,
      isCompleted: false,
      estimatedPomodoros: 3,
      completedPomodoros: 1,
      orderIndex: 0,
      isDeleted: false,
    );
    final task = await taskRepository.getTaskById(taskId);

    bloc.add(PomodoroSelectTaskEvent(task));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<PomodoroState>((s) => s.selectedTask?.id == taskId)),
    );

    // Switch to break mode first
    bloc.add(const PomodoroSwitchModeEvent(PomodoroMode.shortBreak));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<PomodoroState>((s) => s.mode == PomodoroMode.shortBreak)),
    );

    // Skip the break
    bloc.add(PomodoroSkipEvent());

    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<PomodoroState>((s) =>
            s.mode == PomodoroMode.focus &&
            s.completedCycles == 1 &&
            s.selectedTask?.completedPomodoros == 1),
      ),
    );

    final updated = await taskRepository.getTaskById(taskId);
    expect(updated?.completedPomodoros, equals(1));
  });

  test('Skipping final focus session completes task, enters completed status, and further skips are blocked', () async {
    final taskId = await taskRepository.insertTask(
      title: 'Complete Final Chapter',
      priority: 2,
      isCompleted: false,
      estimatedPomodoros: 2,
      completedPomodoros: 1,
      orderIndex: 0,
      isDeleted: false,
    );
    final task = await taskRepository.getTaskById(taskId);

    bloc.add(PomodoroSelectTaskEvent(task));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<PomodoroState>((s) => s.selectedTask?.id == taskId)),
    );

    // Skip the 2nd (final) focus session
    bloc.add(PomodoroSkipEvent());

    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<PomodoroState>((s) =>
            s.status == PomodoroStatus.completed &&
            s.isCompleted == true &&
            s.isTaskFinished == true &&
            s.selectedTask?.completedPomodoros == 2 &&
            s.selectedTask?.isCompleted == true &&
            s.canSkip == false &&
            s.canStart == false),
      ),
    );

    // Attempting to skip again must NOT advance cycles or alter task
    bloc.add(PomodoroSkipEvent());

    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<PomodoroState>((s) =>
            s.selectedTask?.completedPomodoros == 2 &&
            s.status == PomodoroStatus.completed),
      ),
    );

    final finalTask = await taskRepository.getTaskById(taskId);
    expect(finalTask?.completedPomodoros, equals(2));
    expect(finalTask?.isCompleted, isTrue);
  });

  test('Starting or resuming is blocked when task is completed', () async {
    final taskId = await taskRepository.insertTask(
      title: 'Already Finished Task',
      priority: 1,
      isCompleted: true,
      estimatedPomodoros: 2,
      completedPomodoros: 2,
      orderIndex: 0,
      isDeleted: false,
    );
    final task = await taskRepository.getTaskById(taskId);

    bloc.add(PomodoroSelectTaskEvent(task));
    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<PomodoroState>((s) =>
            s.selectedTask?.id == taskId &&
            s.status == PomodoroStatus.completed &&
            s.isCompleted == true &&
            s.canStart == false &&
            s.canSkip == false),
      ),
    );

    // Attempt to start
    bloc.add(PomodoroStartEvent());
    expect(bloc.state.status, equals(PomodoroStatus.completed));
    expect(bloc.state.isRunning, isFalse);

    // Attempt to resume
    bloc.add(PomodoroResumeEvent());
    expect(bloc.state.status, equals(PomodoroStatus.completed));
    expect(bloc.state.isRunning, isFalse);
  });

  test('Finishing 4th focus session without a task completes round at 4 pomodoros', () async {
    // Complete 3 focus sessions without a task
    for (int i = 0; i < 3; i++) {
      bloc.add(PomodoroFinishSessionEvent());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<PomodoroState>((s) => s.completedCycles == i + 1)),
      );
      // Switch back to focus if entered break
      if (bloc.state.mode != PomodoroMode.focus) {
        bloc.add(const PomodoroSwitchModeEvent(PomodoroMode.focus));
        await expectLater(
          bloc.stream,
          emitsThrough(predicate<PomodoroState>((s) => s.mode == PomodoroMode.focus)),
        );
      }
    }

    // Finish 4th focus session
    bloc.add(PomodoroFinishSessionEvent());

    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<PomodoroState>((s) =>
            s.completedCycles == 4 &&
            s.targetCycles == 4 &&
            s.status == PomodoroStatus.completed &&
            s.isCompleted == true &&
            s.canStart == false &&
            s.canSkip == false),
      ),
    );

    // Attempting to skip further is blocked
    bloc.add(PomodoroSkipEvent());
    expect(bloc.state.completedCycles, equals(4));
    expect(bloc.state.status, equals(PomodoroStatus.completed));
  });

  test('Skipping unlinked 4th focus session completes round and caps cycles at 4', () async {
    // Reset timer
    bloc.add(PomodoroResetEvent());
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<PomodoroState>((s) => s.completedCycles == 0)),
    );

    for (int i = 0; i < 3; i++) {
      bloc.add(PomodoroSkipEvent());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<PomodoroState>((s) => s.completedCycles == i + 1)),
      );
      if (bloc.state.mode != PomodoroMode.focus) {
        bloc.add(const PomodoroSwitchModeEvent(PomodoroMode.focus));
        await expectLater(
          bloc.stream,
          emitsThrough(predicate<PomodoroState>((s) => s.mode == PomodoroMode.focus)),
        );
      }
    }

    // Skip the 4th focus session
    bloc.add(PomodoroSkipEvent());

    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate<PomodoroState>((s) =>
            s.completedCycles == 4 &&
            s.status == PomodoroStatus.completed &&
            s.isCompleted == true &&
            s.canSkip == false),
      ),
    );
  });

  test('PomodoroSyncSettingsEvent updates timer duration in initial state', () async {
    // Switch to shortBreak mode
    bloc.add(const PomodoroSwitchModeEvent(PomodoroMode.shortBreak));
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<PomodoroState>((s) => s.mode == PomodoroMode.shortBreak && s.currentSeconds == 300)),
    );

    // Update settings repository
    settingsRepository.shortBreak = 10;
    settingsRepository.restDuration = 10;

    // Dispatch sync
    bloc.add(PomodoroSyncSettingsEvent());
    await expectLater(
      bloc.stream,
      emitsThrough(predicate<PomodoroState>((s) => s.currentSeconds == 600 && s.totalSeconds == 600)),
    );
  });
}
