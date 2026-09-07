import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_flow/core/database/app_database.dart';
import 'package:focus_flow/core/services/connectivity_service.dart';
import 'package:focus_flow/core/services/sync_queue_service.dart';
import 'package:focus_flow/core/supabase/supabase_database_repository.dart';
import 'package:focus_flow/features/settings/domin/repositories/settings_repository.dart';
import 'package:focus_flow/features/tasks/domain/repositories/task_repository.dart';
import 'package:focus_flow/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    return Stream.value(
      _tasks.where((t) => !t.isCompleted && !t.isDeleted).toList(),
    );
  }
}

class FakeSettingsRepository implements SettingsRepository {
  bool _isLoggedIn = false;
  String? _userEmail;

  @override
  bool get isLoggedIn => _isLoggedIn;
  set isLoggedIn(bool val) => _isLoggedIn = val;

  @override
  String? get userEmail => _userEmail;

  @override
  int get focusDuration => 25;
  @override
  int get restDuration => 5;
  @override
  int get shortBreak => 5;
  @override
  int get longBreak => 15;
  @override
  int get longBreakInterval => 4;
  @override
  bool get autoStartBreaks => false;
  @override
  bool get autoStartPomodoros => false;
  @override
  bool get soundEnabled => true;
  @override
  String get soundName => 'bell';
  @override
  String get themeMode => 'system';

  @override
  Future<void> changeTheme(String newTheme) async {}
  @override
  Future<void> toggleSound(bool newValue) async {}
  @override
  Future<void> updateFocusDuration(int newDuration) async {}
  @override
  Future<void> updateRestDuration(int newDuration) async {}
  @override
  Future<void> saveUserSession({
    required String email,
    String? name,
    String? id,
  }) async {
    _isLoggedIn = true;
    _userEmail = email;
  }

  @override
  Future<void> logout() async {
    _isLoggedIn = false;
    _userEmail = null;
  }
}

class FakeConnectivityService implements ConnectivityService {
  bool connected = true;
  final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void emitConnectivity(bool status) {
    connected = status;
    _controller.add(status);
  }

  @override
  Future<bool> checkInternetConnection() async => connected;

  @override
  void dispose() {
    _controller.close();
  }
}

class FakeSupabaseDatabaseRepository implements SupabaseDatabaseRepository {
  final List<Map<String, dynamic>> upserted = [];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #upsert) {
      final data = invocation.positionalArguments[1] as Map<String, dynamic>;
      upserted.add(data);
      return Future.value(data);
    }
    if (invocation.memberName == #getAll) {
      return Future.value(<Map<String, dynamic>>[]);
    }
    if (invocation.memberName == #client) {
      return _FakeSupabaseClient();
    }
    return super.noSuchMethod(invocation);
  }
}

class _FakeSupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #auth) {
      return _FakeGoTrueClient();
    }
    return super.noSuchMethod(invocation);
  }
}

class _FakeGoTrueClient implements GoTrueClient {
  @override
  User? get currentUser => const User(
        id: 'fake-user-id-123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-09-07T00:00:00Z',
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTaskRepository taskRepository;
  late FakeSettingsRepository settingsRepository;
  late FakeConnectivityService connectivityService;
  late FakeSupabaseDatabaseRepository supabaseRepository;
  late SyncQueueService syncQueueService;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    syncQueueService = SyncQueueService(prefs);
    taskRepository = MockTaskRepository();
    settingsRepository = FakeSettingsRepository();
    connectivityService = FakeConnectivityService();
    supabaseRepository = FakeSupabaseDatabaseRepository();
  });

  test('Offline mode queues task sync when logged in', () async {
    settingsRepository.isLoggedIn = true;
    connectivityService.connected = false;

    final bloc = TasksBloc(
      taskRepository: taskRepository,
      settingsRepository: settingsRepository,
      supabaseDatabaseRepository: supabaseRepository,
      connectivityService: connectivityService,
      syncQueueService: syncQueueService,
    );

    bloc.add(
      const OnAddTaskEvent(
        title: 'Offline Task',
        priority: 1,
        isCompleted: false,
        estimatedPomodoros: 2,
        completedPomodoros: 0,
        orderIndex: 0,
        isDeleted: false,
        dueDate: null,
        dueTime: null,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 100));

    // 1. Task saved to local Drift repository
    final allTasks = await taskRepository.featchAll();
    expect(allTasks.length, 1);
    expect(allTasks.first.title, 'Offline Task');

    // 2. Pending queue in SyncQueueService has 1 item
    expect(syncQueueService.hasPendingItems, isTrue);
    final pending = syncQueueService.getPendingItems();
    expect(pending.length, 1);
    expect(pending.first.action, SyncAction.create);
    expect(pending.first.payload['title'], 'Offline Task');

    // 3. Supabase was not called directly because offline
    expect(supabaseRepository.upserted.isEmpty, isTrue);

    await bloc.close();
  });

  test('Reconnecting network auto-syncs pending queue to Supabase', () async {
    settingsRepository.isLoggedIn = true;
    connectivityService.connected = false;

    // Simulate pre-existing pending queue
    await syncQueueService.enqueue(
      action: SyncAction.create,
      taskId: 10,
      payload: {
        'id': 10,
        'title': 'Queued Task',
        'is_completed': false,
      },
    );

    expect(syncQueueService.hasPendingItems, isTrue);

    final bloc = TasksBloc(
      taskRepository: taskRepository,
      settingsRepository: settingsRepository,
      supabaseDatabaseRepository: supabaseRepository,
      connectivityService: connectivityService,
      syncQueueService: syncQueueService,
    );

    // Trigger reconnect!
    connectivityService.emitConnectivity(true);

    await Future.delayed(const Duration(milliseconds: 200));

    // Supabase received the upsert!
    expect(supabaseRepository.upserted.isNotEmpty, isTrue);
    expect(supabaseRepository.upserted.first['title'], 'Queued Task');

    // Queue has been successfully drained
    expect(syncQueueService.hasPendingItems, isFalse);

    await bloc.close();
  });

  test('Logged out user saves locally without queuing to Supabase', () async {
    settingsRepository.isLoggedIn = false;
    connectivityService.connected = false;

    final bloc = TasksBloc(
      taskRepository: taskRepository,
      settingsRepository: settingsRepository,
      supabaseDatabaseRepository: supabaseRepository,
      connectivityService: connectivityService,
      syncQueueService: syncQueueService,
    );

    bloc.add(
      const OnAddTaskEvent(
        title: 'Local Only Task',
        priority: 0,
        isCompleted: false,
        estimatedPomodoros: 1,
        completedPomodoros: 0,
        orderIndex: 0,
        isDeleted: false,
        dueDate: null,
        dueTime: null,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 100));

    // Saved to local
    final all = await taskRepository.featchAll();
    expect(all.length, 1);

    // Not queued because not logged in
    expect(syncQueueService.hasPendingItems, isFalse);

    await bloc.close();
  });
}
